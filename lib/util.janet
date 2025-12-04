(def- colours {:green "\e[32m" :red "\e[31m"})

(def- now
  (do
    (def time (os/time))
    {:year (scan-number (os/strftime "%Y" time))
     :month (scan-number (os/strftime "%m" time))
     :day (scan-number (os/strftime "%d" time))
     :hour (scan-number (os/strftime "%H" time))}))

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
    (if (= (now :month) 12)
      (min (now :day) 25)
      1)))

(def default-year
  (string
    (cond
      (< (now :month) 12)
      (dec (now :year))
      (> (now :day) 1)
      (now :year)
      (< (now :hour) 5)
      (dec (now :year))
      # default
      (now :year))))
