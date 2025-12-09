(import ./util)

(def- platforms
  ["linux-aarch64"
   "linux-x86_64"
   "macos-aarch64"])

(defn- get-sha256
  [ver platform]
  (def url (string "https://github.com/pyrmont/sled/releases/download/v"
                   ver "/sled-v" ver "-" platform ".tar.gz"))
  (print "fetching " url "...")
  (def cmd (string "curl -sL " url " | shasum -a 256"))
  (def proc (os/spawn ["sh" "-c" cmd] :p {:out :pipe}))
  (def output (:read (proc :out) :all))
  (os/proc-wait proc)
  (def exit-code (proc :return-code))
  (unless (zero? exit-code)
    (error (string "failed to download and hash " url)))
  (first (string/split " " (string/trim output))))

(defn- update-hash
  [path ver platform new-sha]
  (def contents (slurp path))
  (def pattern-prefix
    (case platform
      "linux-aarch64" '(* (thru (* `linux-aarch64.tar.gz"` :s+ `sha256 "`)) '(to `"`))
      "linux-x86_64" '(* (thru (* `linux-x86_64.tar.gz"` :s+ `sha256 "`)) '(to `"`))
      "macos-aarch64" '(* (thru (* `macos-aarch64.tar.gz"` :s+ `sha256 "`)) '(to `"`))))
  (def curr-sha (first (peg/match pattern-prefix contents)))
  (assert curr-sha (string path " missing sha256 for " platform))
  (def updated (string/replace curr-sha new-sha contents))
  (spit path updated)
  (print "updated " platform " sha256 to " new-sha))

(defn- update-version
  [path ver]
  (def contents (slurp path))
  (def curr-ver (first (peg/match '(* (thru "version \"") '(to `"`)) contents)))
  (assert curr-ver (string path " missing version line"))
  (def curr-line (string `version "` curr-ver `"`))
  (def new-line (string `version "` ver `"`))
  (def updated (string/replace curr-line new-line contents))
  (spit path updated)
  (print "updated version to " ver))

(defn main
  [command ver & args]
  (def parent (-> (dyn :current-file) (util/abspath) (util/parent 3)))
  (def formula (string parent "/sled.rb"))
  (unless (= :file (os/stat formula :mode))
    (error (string "formula not found at " formula)))
  (update-version formula ver)
  (each platform platforms
    (def sha (get-sha256 ver platform))
    (update-hash formula ver platform sha)))
