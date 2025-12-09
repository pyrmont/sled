(use ../deps/testament)

(review ../lib/cmd-calendar :as cmd)

(deftest rgb-six-digit-hex
  (def input "#ff0000")
  (def expect [255 0 0])
  (is (== expect (cmd/rgb input))))

(deftest rgb-six-digit-no-hash
  (def input "00ff00")
  (def expect [0 255 0])
  (is (== expect (cmd/rgb input))))

(deftest rgb-three-digit-hex
  (def input "#abc")
  (def expect [170 187 204])
  (is (== expect (cmd/rgb input))))

(deftest rgb-three-digit-no-hash
  (def input "abc")
  (def expect [170 187 204])
  (is (== expect (cmd/rgb input))))

(deftest rgb-black
  (def input "#000000")
  (def expect [0 0 0])
  (is (== expect (cmd/rgb input))))

(deftest rgb-white
  (def input "#ffffff")
  (def expect [255 255 255])
  (is (== expect (cmd/rgb input))))

(deftest ansi256-black
  (def result (cmd/ansi256 0 0 0))
  (is (= 16 result)))

(deftest ansi256-white
  (def result (cmd/ansi256 255 255 255))
  (is (= 231 result)))

(deftest ansi256-red
  (def result (cmd/ansi256 255 0 0))
  (is (= 196 result)))

(deftest ansi256-green
  (def result (cmd/ansi256 0 255 0))
  (is (= 46 result)))

(deftest ansi256-blue
  (def result (cmd/ansi256 0 0 255))
  (is (= 21 result)))

(deftest ansi256-greyscale
  (def result (cmd/ansi256 128 128 128))
  (is (and (>= result 232) (<= result 255))))

(deftest parse-calendar-colours-with-styles
  (def html
    ```
    <style>
    .calendar .calendar-color-a { color: #ff0000; }
    .calendar .calendar-color-b { color: #00ff00; }
    </style>
    ```)
  (def expect {"calendar-color-a" 196 "calendar-color-b" 46})
  (is (== expect (cmd/parse-calendar-colours html))))

(deftest parse-calendar-colours-no-styles
  (def html "<html><body>No styles here</body></html>")
  (def result (cmd/parse-calendar-colours html))
  (is (and (dictionary? result) (empty? result))))

(run-tests!)
