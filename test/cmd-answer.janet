(use ../deps/testament)

(defn without-tty []
  (def env (make-env))
  (put-in env ['os/isatty :value] (fn [&] false))
  env)

(review ../lib/cmd-answer :as cmd :with-dyns [:module-make-env without-tty])

(deftest parse-response-correct
  (def html "That's the right answer! You are one star closer")
  (def result (cmd/parse-response html))
  (is (= :correct (result :result)))
  (is (== "Your answer is correct!" (result :message))))

(deftest parse-response-incorrect-too-low
  (def html "That's not the right answer; your answer is too low")
  (def result (cmd/parse-response html))
  (is (= :incorrect (result :result)))
  (is (== "Your answer is incorrect. It is too low." (result :message))))

(deftest parse-response-incorrect-too-high
  (def html "That's not the right answer; your answer is too high")
  (def result (cmd/parse-response html))
  (is (= :incorrect (result :result)))
  (is (== "Your answer is incorrect. It is too high." (result :message))))

(deftest parse-response-incorrect-generic
  (def html "That's not the right answer")
  (def result (cmd/parse-response html))
  (is (= :incorrect (result :result)))
  (is (== "Your answer is incorrect." (result :message))))

(deftest parse-response-rate-limited
  (def html "You gave an answer too recently")
  (def result (cmd/parse-response html))
  (is (= :rate-limited (result :result)))
  (is (== "You gave an answer too recently. Please try again later." (result :message))))

(deftest parse-response-already-solved
  (def html "Did you already complete it? [Return to Day X]"
             "You don't seem to be solving the right level")
  (def result (cmd/parse-response html))
  (is (= :already-solved (result :result)))
  (is (== "You've already completed this puzzle." (result :message))))

(deftest parse-response-unknown
  (def html "Some unexpected response")
  (def result (cmd/parse-response html))
  (is (= :unknown (result :result)))
  (is (== "Unable to parse response. Try submitting manually." (result :message))))

(run-tests!)
