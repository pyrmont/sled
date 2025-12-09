(use ../deps/testament)

(defn without-tty []
  (def env (make-env))
  (put-in env ['os/isatty :value] (fn [&] false))
  env)

(review ../lib/util :as u :with-dyns [:module-make-env without-tty])

(deftest colour-green-with-terminal
  (def input "test")
  (def expect "\e[32mtest\e[0m")
  (is (= expect (u/colour :green input true))))

(deftest colour-red-with-terminal
  (def input "test")
  (def expect "\e[31mtest\e[0m")
  (is (= expect (u/colour :red input true))))

(deftest colour-without-terminal
  (def input "test")
  (def expect "test")
  (is (= expect (u/colour :green input false))))

(deftest colour-unknown-with-terminal
  (def input "test")
  (def expect "\e[0mtest\e[0m")
  (is (= expect (u/colour :unknown input true))))

(deftest default-day-is-string
  (is (string? (u/default-day))))

(deftest default-day-is-valid
  (def day (scan-number (u/default-day)))
  (is (and (>= day 1) (<= day 25))))

(deftest default-year-is-string
  (is (string? (u/default-year))))

(deftest default-year-is-reasonable
  (def year (scan-number (u/default-year)))
  (is (and (>= year 2015) (<= year 2030))))

(run-tests!)
