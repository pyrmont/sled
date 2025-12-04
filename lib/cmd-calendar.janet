(import ../deps/churlish :as http)
(import ../deps/lemongrass :as lg)
(import ./formatter)
(import ./util)

(def config
  ```
  The configuration for the calendar subcommand
  ```
  {:rules ["--year" {:kind    :single
                     :short   "y"
                     :default util/default-year
                     :help    "The year of the calendar."}
           "-------------------------------------------"
           "--no-color" {:kind  :flag
                         :short "C"
                         :help  "Disable color."}
           "-------------------------------------------"]
   :short "c"
   :info {:about "Displays the Advent of Code calendar."}
   :help "Display the calendar."})

(defn- rgb
  ```
  Converts hex colour to RGB values
  ```
  [hex]
  (def h (if (string/has-prefix? "#" hex) (string/slice hex 1) hex))
  (def six-hex (case (length h)
                 3
                 (string/from-bytes (get h 0) (get h 0)
                                    (get h 1) (get h 1)
                                    (get h 2) (get h 2))
                 6
                 h
                 # default
                 (error "invalid hex value")))
  [(scan-number (string/slice six-hex 0 2) 16)
   (scan-number (string/slice six-hex 2 4) 16)
   (scan-number (string/slice six-hex 4 6) 16)])

(defn- ansi256
  ```
  Converts RGB values to closest ANSI 256-colour code
  ```
  [r g b]
  # Check if it's greyscale
  (if (and (= r g) (= g b))
    # Use greyscale ramp (232-255)
    (cond
      (< r 8)
      16
      (> r 247)
      231
      # default
      (+ 232 (math/floor (/ (- r 8) 10))))
    # Use 6x6x6 RGB cube (16-231)
    (do
      (def ri (math/floor (/ r 51)))
      (def gi (math/floor (/ g 51)))
      (def bi (math/floor (/ b 51)))
      (+ 16 (* 36 ri) (* 6 gi) bi))))

(defn- download-calendar
  ```
  Downloads the calendar page for a given year
  ```
  [session year]
  (def url (string "https://adventofcode.com/" year))
  (def headers {"Cookie" (string "session=" session)})
  (print "Retrieving calendar for " year "...")
  (def response (http/get url :headers headers))
  (def status (response :status))
  (unless (= status 200)
    (error (string "Failed to download calendar. Status: " status)))
  (response :body))

(defn- extract-text
  ```
  Extracts text content from an HTML tree and decodes HTML entities
  ```
  [tree colours]
  (def b @"")
  (defn walker [n &opt completion k]
    (cond
      (string? n)
      (do
        (when k
          (buffer/push-string b (string/format "\e[38;5;%dm" k)))
        (buffer/push b n)
        (when k
          (buffer/push-string b "\e[0m")))
      (indexed? n)
      (do
        (def tag (get n 0))
        (def attrs (get n 1))
        (def classes (or (when (dictionary? attrs) (attrs :class)) ""))
        (def status (cond
                      (string/find "very" classes)
                      :full
                      (string/find "complete" classes)
                      :partial))
        # Check if this element has a colour class
        (var colour k)
        # Colour completion stars gold
        (if (string/find "mark" classes)
          (set colour 220)
          (eachk name colours
            (when (string/find name classes)
              (set colour (colours name)))))
        (each el (array/slice n (if (dictionary? attrs) 2 1))
          (if (and (= "*" el) (= 220 colour))
            (cond
              (and (= :partial status) completion)
              (walker el nil colour)
              (and (= :full status) (= :full completion))
              (walker el nil colour))
            (walker el status colour))))))
  (walker tree)
  # Decode HTML entities
  (def entities {"&lt;" "<"
                 "&gt;" ">"
                 "&amp;" "&"
                 "&quot;" "\""
                 "&apos;" "'"})
  (def res @"")
  (var found? false)
  (var i 0)
  (while (def c (get b i))
    (when (= (chr "&") c)
      (eachp [entity char] entities
        (def len (length entity))
        (when (and (<= (+ i len) (length b))
                   (= entity (string/slice b i (+ i len))))
          (buffer/push-string res char)
          (+= i len)
          (set found? true)
          (break))))
    (unless found?
      (buffer/push-byte res c)
      (++ i))
    (set found? false))
  (string res))

(defn- parse-calendar-colours
  ```
  Parses CSS colour definitions into a mapping of class names to ANSI codes
  ```
  [html]
  (def colours @{})
  (def style-start (string/find "<style>" html))
  (def style-end (when style-start (string/find "</style>" html style-start)))
  (when (and style-start style-end)
    (def styles (string/slice html style-start style-end))
    # Match patterns like: .calendar .calendar-color-w { color: #ccc; }
    (def pattern ~(* ".calendar .calendar-color-"
                     '(some (+ :w (set "-")))
                     (any :s) "{" (any :s) "color:" (any :s)
                     '(* "#" (between 3 6 :h))
                     (thru "}")))
    (var i 0)
    (while (< i (length styles))
      (if (def m (peg/match pattern (string/slice styles i)))
        (do
          (def [suf hex] m)
          (def [r g b] (rgb hex))
          (def ansi (ansi256 r g b))
          (put colours (string "calendar-color-" suf) ansi)
          (+= i (length (first m))))
        (++ i))))
  colours)

(defn- parse-calendar
  ```
  Parses the calendar HTML and (optionally) extracts the ASCII art with colours
  ```
  [input colour?]
  (def colours (parse-calendar-colours input))
  (def cal-beg (string/find "<pre class=\"calendar\">" input))
  (assert cal-beg "no calendar in page")
  (def cal-end (-?> (string/find "</pre>" input cal-beg) (+ 6)))
  (assert cal-end "no calendar in page")
  (def script-beg (or (string/find "<script" input cal-beg) 0))
  (def script-end (or (-?> (string/find "</script>" input script-beg) (+ 9)) 0))
  (def html (if (and script-beg
                     script-end
                     (< cal-beg script-beg)
                     (< script-end cal-end))
              (string (string/slice input cal-beg script-beg)
                     (string/slice input script-end cal-end))
              (string/slice input cal-beg cal-end)))
  (def tree (lg/markup->janet html))
  (extract-text tree (if colour? colours {})))

(defn run
  ```
  Displays the Advent of Code calendar
  ```
  [session args]
  (def opts (args :opts))
  (def year (scan-number (opts "year")))
  (def colour? (not (opts "no-color")))
  (def calendar (-> (download-calendar session year)
                    (parse-calendar colour?)))
  (print calendar))
