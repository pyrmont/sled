(def- psep "/")
(def- wsep "\\")

(def sep (get {:windows wsep :cygwin wsep :mingw wsep} (os/which) psep))

(def pathg ~{:main    (* (+ :abspath :relpath) (? :sep) -1)
             :abspath (* :root (any :relpath))
             :relpath (* :part (any (* :sep :part)))
             :root    (+ (* ,sep (constant ""))
                         (* '(* :a ":") ,wsep))
             :sep     (some ,sep)
             :part    '(some (* (! :sep) 1))})

(def posix-pathg ~{:main     (* (+ :abspath :relpath) (? :sep) -1)
                   :abspath  (* :root (any :relpath))
                   :relpath  (* :part (any (* :sep :part)))
                   :root     (* ,psep (constant ""))
                   :sep      (some ,psep)
                   :part     '(some (* (! :sep) 1))})

(defn abspath?
  [path]
  (if (= :windows (os/which))
    (not (nil? (peg/match ~(* (? (* :a ":")) ,wsep) path)))
    (string/has-prefix? psep path)))

(defn abspath
  [path]
  (if (abspath? path)
    path
    (string (os/cwd) sep path)))

(defn apart
  [path &opt posix?]
  (if (empty? path)
    []
    (or (peg/match (if posix? posix-pathg pathg) path)
        (error "invalid path"))))

(defn parent
  [path &opt level posix?]
  (default level 1)
  (def parts (apart path posix?))
  (when (empty? parts)
    (break parts))
  (def s (if posix? psep sep))
  (def joined (string/join (array/slice parts 0 (- -1 level)) s))
  (if (= "" joined)
    sep
    joined))
