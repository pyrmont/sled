//! A narrow HTTP transport for Sled, built against Wattle's public module API.
//! Requests run on a worker thread so other Wattle fibers can continue.
const std = @import("std");
const wattle = @import("wattle");

const Job = struct {
    arena: std.heap.ArenaAllocator,
    thread: ?std.Thread,
    loop: *wattle.Loop,
    fiber: wattle.Value,
    method: std.http.Method,
    url: []const u8,
    headers: []std.http.Header,
    body: ?[]const u8,
    status: u16 = 0,
    response_body: []const u8 = "",
    failure: ?[]const u8 = null,
};

fn jobGc(job: *Job, _: usize) void {
    if (job.thread) |thread| thread.join();
    job.arena.deinit();
}

const job_type = wattle.define(Job, .{ .name = "sled_http/job", .gc = jobGc });

fn copy(arena: std.mem.Allocator, bytes: []const u8) wattle.Error![]const u8 {
    return arena.dupe(u8, bytes) catch wattle.panic("out of memory preparing HTTP request");
}

fn worker(job: *Job) void {
    defer wattle.post(job.loop, &done, job);

    var threaded: std.Io.Threaded = .init(std.heap.page_allocator, .{});
    defer threaded.deinit();
    var client: std.http.Client = .{
        .allocator = std.heap.page_allocator,
        .io = threaded.io(),
    };
    defer client.deinit();

    var output: std.Io.Writer.Allocating = .init(job.arena.allocator());
    defer output.deinit();
    const result = client.fetch(.{
        .location = .{ .url = job.url },
        .method = job.method,
        .payload = job.body,
        .extra_headers = job.headers,
        .redirect_behavior = .unhandled,
        .response_writer = &output.writer,
    }) catch |err| {
        job.failure = @errorName(err);
        return;
    };
    job.status = @intFromEnum(result.status);
    job.response_body = output.toOwnedSlice() catch {
        job.failure = "out of memory reading HTTP response";
        return;
    };
}

fn done(wake: *wattle.Wake, raw: *anyopaque) callconv(.c) void {
    const job: *Job = @ptrCast(@alignCast(raw));
    job.thread.?.join();
    job.thread = null;

    const result = if (job.failure) |message|
        wattle.mapOf(&.{.{ .key = wattle.keyword("error"), .value = wattle.string(message) }})
    else
        wattle.mapOf(&.{
            .{ .key = wattle.keyword("status"), .value = wattle.number(@floatFromInt(job.status)) },
            .{ .key = wattle.keyword("body"), .value = wattle.string(job.response_body) },
        });
    _ = wattle.wake(wake, job.fiber, result);
    _ = wattle.gcunroot(job.fiber);
    _ = wattle.gcunroot(wattle.abstract(job));
}

fn request(argv: []wattle.Value) wattle.Error!wattle.Value {
    try wattle.arity(argv, 2, 4);
    const method_text = try wattle.getBytes(argv, 0);
    const method: std.http.Method = if (std.mem.eql(u8, method_text, "GET"))
        .GET
    else if (std.mem.eql(u8, method_text, "POST"))
        .POST
    else if (std.mem.eql(u8, method_text, "PUT"))
        .PUT
    else
        return wattle.panic("HTTP method must be GET, POST, or PUT");
    const url = try wattle.getBytes(argv, 1);
    const loop = try wattle.loop();
    const fiber = try wattle.rootFiber();

    const job = wattle.new(Job, &job_type, null);
    job.* = .{
        .arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),
        .thread = null,
        .loop = loop,
        .fiber = fiber,
        .method = method,
        .url = "",
        .headers = &.{},
        .body = null,
    };
    const allocator = job.arena.allocator();
    job.url = try copy(allocator, url);

    if (argv.len >= 3 and !wattle.isNil(argv[2])) {
        var headers = try wattle.getDictionary(argv, 2);
        job.headers = allocator.alloc(std.http.Header, headers.count) catch
            return wattle.panic("out of memory preparing HTTP headers");
        var i: usize = 0;
        while (try headers.next()) |kv| : (i += 1) {
            const name = wattle.bytesView(kv.key) orelse
                return wattle.panic("HTTP header names must be strings");
            const value = wattle.bytesView(kv.value) orelse
                return wattle.panic("HTTP header values must be strings");
            job.headers[i] = .{
                .name = try copy(allocator, name),
                .value = try copy(allocator, value),
            };
        }
    }
    if (argv.len >= 4 and !wattle.isNil(argv[3])) {
        job.body = try copy(allocator, try wattle.getBytes(argv, 3));
    }

    wattle.gcroot(job.fiber);
    wattle.gcroot(wattle.abstract(job));
    job.thread = std.Thread.spawn(.{}, worker, .{job}) catch {
        _ = wattle.gcunroot(job.fiber);
        _ = wattle.gcunroot(wattle.abstract(job));
        return wattle.panic("could not start HTTP worker thread");
    };
    return wattle.await();
}

fn defs(env: *wattle.Env) wattle.Error!void {
    wattle.nfuns(env, "sled_http", &.{
        wattle.reg("request", &request, "(sled_http/request method url &opt headers body)", "Send an HTTP request and return a map with :status and :body, or :error."),
    });
}

comptime {
    wattle.entry(defs);
}
