(import ../deps/argy-bargy/argy-bargy :as argy)

(import ./cmd-puzzle :as cmd/puzzle)
(import ./cmd-answer :as cmd/answer)
(import ./cmd-calendar :as cmd/calendar)

(def config
  ```
  The configuration for sled
  ```
  {:rules ["--session"    {:kind    :single
                           :short   "s"
                           :proxy   "file"
                           :default "session.txt"
                           :help    "A file that contains the session ID for the user's logged in session."}]
   :subs ["answer" cmd/answer/config
          "calendar" cmd/calendar/config
          "puzzle" cmd/puzzle/config]
   :info {:about "Seasonal Linear Enigma Device, a command-line utility for Advent of Code."}})

(def file-env (curenv))

(defn run
  []
  (def parsed (argy/parse-args "sled" config))
  (def err (parsed :err))
  (def help (parsed :help))
  (def opts (parsed :opts))
  (def sub (parsed :sub))
  (cond
    (not (empty? help))
    (do
      (prin help)
      (os/exit (if (opts "help") 0 1)))
    (not (empty? err))
    (do
      (eprin err)
      (os/exit 1))
    # default
    (do
      (def name (symbol "cmd/" (sub :cmd) "/run"))
      (def sub/run (module/value file-env name true))
      (try
        (do
          (def filename (opts "session"))
          (assertf (= :file (os/stat filename :mode)) "no file '%s'" filename)
          (def session (-> (slurp filename)
                           (string/trim)))
          (sub/run session sub))
        ([e f]
         (eprint "error: " e)
         (debug/stacktrace f)
         (os/exit 1))))))

# for testing in development
(defn- main [& args] (run))
