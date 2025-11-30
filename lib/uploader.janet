(import ../deps/churlish :as http)

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

(defn- parse-response
  ```
  Parses the HTML response from submitting an answer

  Returns a table with :result and :message keys.
  Result can be: :correct, :incorrect, :rate-limited, :already-solved, :unknown
  ```
  [html]
  (cond
    # Check for correct answer
    (string/find "That's the right answer" html)
    {:result :correct
     :message "Your answer is correct!"}
    # Check for incorrect - too low
    (string/find "too low" html)
    {:result :incorrect
     :message "Your answer is incorrect. It is too low."}
    # Check for incorrect - too high
    (string/find "too high" html)
    {:result :incorrect
     :message "Your answer is incorrect. It is too high."}
    # Check for incorrect - generic
    (string/find "That's not the right answer" html)
    {:result :incorrect
     :message "Your answer is incorrect."}
    # Check for rate limiting
    (string/find "too recently" html)
    {:result :rate-limited
     :message (string "You gave an answer too recently. Please try again later.")}
    # Check for already completed
    (string/find "right level" html)
    {:result :already-solved
     :message "You've already completed this puzzle."}
    # Unknown response
    {:result :unknown
     :message "Unable to parse response. Try submitting manually."}))

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
