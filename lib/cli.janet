(import ../deps/argy-bargy/argy-bargy :as argy)
(import ./downloader :as dl)
(import ./uploader :as ul)

(def- now
  (do
    (def time (os/time))
    {:year (scan-number (os/strftime "%Y" time))
     :month (scan-number (os/strftime "%m" time))
     :day (scan-number (os/strftime "%d" time))
     :hour (scan-number (os/strftime "%H" time))}))

(def- default-year
  (string (cond
            (< (now :month) 12)
            (dec (now :year))
            (> (now :day) 1)
            (now :year)
            (< (now :hour) 5)
            (dec (now :year))
            # default
            (now :year))))

(def config
  ```
  The configuration for Argy-Bargy
  ```
  {:rules [:answer  {:req? false
                     :help "The answer for the given puzzle."}
           "--part" {:kind    :single
                     :short   "p"
                     :default "1"
                     :help    "The part of the puzzle."}
           "--day"  {:kind  :single
                     :short "d"
                     :help  "The day of the puzzle."}
           "--year" {:kind    :single
                     :short   "y"
                     :default default-year
                     :help    "The year of the puzzle."}
           "-------------------------------------------"
           "--no-subdirs" {:kind  :flag
                           :short "S"
                           :help  "Save files without creating subdirectories for each day."}
           "--session"    {:kind    :single
                           :short   "s"
                           :proxy   "file"
                           :default "session.txt"
                           :help    "A file that contains the session ID for the user's logged in session."}
           "-------------------------------------------"]
   :info {:about "Seasonal Linear Enigma Device, a command-line utility for Advent of Code."}})

(defn current-year
  []
  "2025")

(defn current-day
  []
  "01")

(defn run
  []
  (def parsed (argy/parse-args "sled" config))
  (def err (parsed :err))
  (def help (parsed :help))
  (def params (parsed :params))
  (def opts (parsed :opts))
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
      (def [ok? res]
        (protect
          (def id (string/trim (slurp (get opts "session"))))
          (def year (scan-number (get opts "year")))
          (def day (scan-number (get opts "day")))
          (def subdirs? (not (get opts "no-subdirs")))
          (if (has-key? params :answer)
            (do
              (def part (opts "part"))
              (assert (or (= "1" part) (= "2" part)) "part must be 1 or 2")
              (ul/answer id year day part (params :answer)))
            (dl/puzzle id year day subdirs?))))
      (unless ok?
        (print res)
        (os/exit 1)))))

# for testing in development
(defn- main [& args] (run))
