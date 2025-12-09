(use ../deps/testament)

(defn without-tty []
  (def env (make-env))
  (put-in env ['os/isatty :value] (fn [&] false))
  env)

## Helpers

(defn copy-file
  [src-path dst-path]
  (def buf-size 4096)
  (def buf (buffer/new buf-size))
  (with [src (file/open src-path :rb)]
    (with [dst (file/open dst-path :wb)]
      (while (def bytes (file/read src buf-size buf))
        (file/write dst bytes)
        (buffer/clear buf)))))

(defn- rmrf
  [path]
  (def sep (get {:windows "\\" :cygwin "\\" :mingw "\\"} (os/which) "/"))
  (case (os/lstat path :mode)
    :directory (do
                 (each subpath (os/dir path)
                   (rmrf (string path sep subpath)))
                 (os/rmdir path))
    nil nil # do nothing if file does not exist
    (os/rm path)))

(defn- shell-capture [cmd]
  (let [x (os/spawn cmd : {:in :pipe :out :pipe :err :pipe})
        o (:read (x :out) :all)
        e (:read (x :err) :all)]
    (:wait x)
    [(get x :return-code) o e]))

## Tests

(deftest cli-no-args
  (def [exit-code test-out test-err]
    (shell-capture ["./_build/sled"]))
  (def msg
    ```
    sled: no subcommand provided
    Try 'sled --help' for more information.
    ```)
  (is (== 1 exit-code))
  (is (== nil test-out))
  (is (== (string msg "\n") test-err)))

(deftest cli-bad-option
  (def [exit-code test-out test-err]
    (shell-capture ["./_build/sled" "--bad-option"]))
  (def msg
    ```
    sled: unrecognized option '--bad-option'
    Try 'sled --help' for more information.
    ```)
  (is (== 1 exit-code))
  (is (== nil test-out))
  (is (== (string msg "\n") test-err)))

(deftest cli-help
  (def [exit-code test-out test-err]
    (shell-capture ["./_build/sled" "--help"]))
  (def msg
    ```
    Usage: sled [--session <file>] <subcommand> [<args>]

    Seasonal Linear Enigma Device, a command-line utility for Advent of Code.

    Options:

     -s, --session <file>    A file that contains the session ID for the user's logged in session. (Default: session.txt)
     -h, --help              Show this help message.

    Subcommands:

     a, answer       Submit an answer.
     c, calendar     Display the calendar.
     p, puzzle       Download a puzzle.

    For more information on each subcommand, type 'sled help <subcommand>'.
    ```)
  (is (== 0 exit-code))
  (is (== (string msg "\n") test-out))
  (is (== nil test-err)))

(deftest cli-missing-session
  (def [exit-code test-out test-err]
    (shell-capture ["./_build/sled" "--session" "nonexistent.txt" "calendar"]))
  (is (== 1 exit-code))
  (is (== nil test-out))
  (is (string/find "error:" test-err))
  (is (string/find "no file 'nonexistent.txt'" test-err)))

(defer (rmrf "_build")
  (print "building ./_build/sled...")
  (def info (-> (slurp "info.jdn") parse))
  (def bundle (require "../bundle"))
  (with-dyns [:out @"" :err @"" :module-make-env without-tty]
    (def build (module/value bundle 'build))
    (build {:info info}))
  (run-tests!))
