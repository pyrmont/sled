(import ../deps/churlish :as http)
(import ../deps/lemongrass :as lg)
(import ./formatter)
(import ./util)

(def config
  ```
  The configuration for the puzzle subcommand
  ```
  {:rules ["--day" {:kind    :single
                    :short   "d"
                    :default util/default-day
                    :help    "The day of the puzzle."}
           "--year" {:kind    :single
                     :short   "y"
                     :default util/default-year
                     :help    "The year of the puzzle."}
           "-------------------------------------------"
           "--no-subdirs" {:kind  :flag
                           :short "S"
                           :help  "Save files without creating subdirectories for each day."}
           "--wrap" {:kind  :single
                     :short "w"
                     :help  "Wrap puzzle text at specified column width."}
           "-------------------------------------------"]
   :short "p"
   :info {:about "Downloads a puzzle from Advent of Code."}
   :help "Download a puzzle."})

(defn- download-explanation
  ```
  Downloads puzzle explanation for a given year and day
  ```
  [session year day]
  (def url (string (dyn :base-url) "/" year "/day/" day))
  (def headers {"Cookie" (string "session=" session)})
  (print "Downloading puzzle explanation for day " day " of " year "...")
  (def response (http/get url :headers headers))
  (def status (response :status))
  (unless (= status 200)
    (error (string "Failed to download puzzle explanation. Status: " status)))
  (response :body))

(defn- download-input
  ```
  Downloads puzzle input for a given year and day
  ```
  [session year day]
  (def url (string (dyn :base-url) "/" year "/day/" day "/input"))
  (def headers {"Cookie" (string "session=" session)})
  (print "Downloading puzzle input for day " day " of " year "...")
  (def response (http/get url :headers headers))
  (def status (response :status))
  (unless (= status 200)
    (error (string "Failed to download puzzle input. Status: " status)))
  (response :body))

(defn- parse-explanation
  [input &opt width]
  (def p1-beg (string/find "<article" input))
  (def p1-end (string/find "</article>" input (or p1-beg 0)))
  (assert (and p1-beg p1-end) "no <article> in HTML")
  (def p1 (-> (string/slice input p1-beg (+ p1-end 10))
              (lg/markup->janet)
              (formatter/markdown width)))
  (def p2-beg (string/find "<article" input (or p1-end 0)))
  (def p2-end (string/find "</article>" input (or p2-beg 0)))
  (def p2 (when (and p2-beg p2-end)
            (-> (string/slice input p2-beg (+ p2-end 10))
                (lg/markup->janet)
                (formatter/markdown width))))
  (string p1 p2))

(defn- save-file
  ```
  Saves content to a file

  Saves content to a file with a path based on name. If subdir? is true,
  creates a day subdirectory and puts the file inside it.
  ```
  [year day content name subdir?]
  (def day-label (string "day" (string/format "%02d" day)))
  (def file-path
    (if subdir?
      (do
        (os/mkdir day-label)
        (def s "/")
        (string day-label s name ".txt"))
      (string day-label "." name)))
  (spit file-path content)
  (print "Saved to " file-path))

(defn run
  ```
  Downloads and saves an Advent of Code puzzle
  ```
  [session args]
  (def opts (args :opts))
  (def year (scan-number (opts "year")))
  (def day (scan-number (opts "day")))
  (def subdirs? (not (opts "no-subdirs")))
  (def width (when (opts "wrap") (scan-number (opts "wrap"))))
  (setdyn :page-url (string (dyn :base-url) "/" year "/day/" day))
  (def explanation (-> (download-explanation session year day)
                       (parse-explanation width)))
  (save-file year day explanation "puzzle" subdirs?)
  (def input (download-input session year day))
  (save-file year day input "input" subdirs?)
  (print "Done!"))
