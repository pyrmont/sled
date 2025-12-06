(def- colours {:green "\e[32m" :red "\e[31m"})

(defn- now
  [unit &opt offset]
  (def utc (os/time))
  (def t (if offset (+ utc (* offset 60 60)) utc))
  (case unit
    :year (scan-number (os/strftime "%Y" t))
    :month (scan-number (os/strftime "%m" t))
    :day (scan-number (os/strftime "%d" t))
    :hour (scan-number (os/strftime "%H" t))))

# Public functions

(defn colour
  ```
  Adds colour to text
  ```
  [c text &opt force?]
  (default force? false)
  (if (or (os/isatty) force?)
    (string (get colours c "\e[0m") text "\e[0m")
    text))

(def default-day
  (string
    (if (= (now :month -5) 12)
      (min (now :day -5) 25)
      1)))

(def default-year
  (string
    (if (< (now :month -5) 12)
      (dec (now :year -5))
      (now :year -5))))
