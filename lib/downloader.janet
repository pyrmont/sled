(import ../deps/churlish :as http)
(import ./formatter)

(defn- download-explanation
  ```
  Downloads puzzle explanation for a given year and day
  ```
  [session year day]
  (def url (string "https://adventofcode.com/" year "/day/" day))
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
  (def url (string "https://adventofcode.com/" year "/day/" day "/input"))
  (def headers {"Cookie" (string "session=" session)})
  (print "Downloading puzzle input for day " day " of " year "...")
  (def response (http/get url :headers headers))
  (def status (response :status))
  (unless (= status 200)
    (error (string "Failed to download puzzle input. Status: " status)))
  (response :body))

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

(defn puzzle
  ```
  Downloads and saves an Advent of Code puzzle

  Takes a year and day number and downloads the corresponding puzzle explanation
  and test input from Advent of Code for the user with the given session.
  ```
  [session year day &opt subdirs?]
  (def explanation (-> (download-explanation session year day)
                       (formatter/markdown)))
  (save-file year day explanation "puzzle" subdirs?)
  (def input (download-input session year day))
  (save-file year day input "input" subdirs?)
  (print "Done!"))
