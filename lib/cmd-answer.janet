(import ../deps/churlish :as http)
(import ./util)

(def config
  ```
  The configuration for the answer subcommand
  ```
  {:rules [:answer  {:req? true
                     :help "The answer for the given puzzle."}
           "--part" {:kind    :single
                     :short   "p"
                     :default "1"
                     :help    "The part of the puzzle."}
           "--day"  {:kind    :single
                     :short   "d"
                     :default util/default-day
                     :help    "The day of the puzzle."}
           "--year" {:kind    :single
                     :short   "y"
                     :default util/default-year
                     :help    "The year of the puzzle."}
           "-------------------------------------------"]
   :short "a"
   :info {:about "Submits an answer to Advent of Code."}
   :help "Submit an answer."})

(defn- parse-response
  ```
  Parses the HTML response from submitting an answer

  Returns a table with :result and :message keys.
  Result can be: :correct, :incorrect, :rate-limited, :already-solved, :unknown
  ```
  [html]
  (cond
    # Check for already completed
    (string/find "right level" html)
    {:result :already-solved
     :message "You've already completed this puzzle."}
    # Check for correct answer
    (string/find "That's the right answer" html)
    {:result :correct
     :message (string "Your answer is " (util/colour :green "correct") "!")}
    # Check for incorrect - too low
    (string/find "too low" html)
    {:result :incorrect
     :message (string "Your answer is " (util/colour :red "incorrect") ". It is too low.")}
    # Check for incorrect - too high
    (string/find "too high" html)
    {:result :incorrect
     :message (string "Your answer is " (util/colour :red "incorrect") ". It is too high.")}
    # Check for incorrect - generic
    (string/find "That's not the right answer" html)
    {:result :incorrect
     :message (string "Your answer is " (util/colour :red "incorrect") ".")}
    # Check for rate limiting
    (string/find "too recently" html)
    {:result :rate-limited
     :message (string "You gave an answer too recently. Please try again later.")}
    # Unknown response
    {:result :unknown
     :message "Unable to parse response. Try submitting manually."}))

(defn- submit-answer
  ```
  Submits an answer to Advent of Code

  Makes an HTTP POST request to submit an answer for a specific part
  of a puzzle.
  ```
  [session year day part answer]
  (def url (string "https://adventofcode.com/" year "/day/" day "/answer"))
  (def headers {"Cookie" (string "session=" session)
                "Content-Type" "application/x-www-form-urlencoded"})
  (def body (string "level=" part "&answer=" answer))
  (print "Submitting answer for part " part " of day " day " of " year "...")
  (def response (http/post url :headers headers :body body))
  (def status (response :status))
  (assertf (= status 200) "Submission failed, status %d" status)
  (response :body))

(defn answer
  ```
  Submits an answer to an Advent of Code puzzle

  Takes a session cookie, year, day, part (1 or 2), and answer string.
  Submits the answer and reports whether it was correct or not.
  ```
  [session year day part answer]
  (def html (submit-answer session year day part answer))
  (def result (parse-response html))
  (print (result :message))
  (result :result))

(defn run
  ```
  Submits an answer to an Advent of Code puzzle
  ```
  [session args]
  (def opts (args :opts))
  (def params (args :params))
  (def year (scan-number (opts "year")))
  (def day (scan-number (opts "day")))
  (def part (opts "part"))
  (assert (or (= "1" part) (= "2" part)) "part must be 1 or 2")
  (def answer (params :answer))
  (def html (submit-answer session year day part answer))
  (def result (parse-response html))
  (print (result :message)))
