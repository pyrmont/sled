
(def nl 10)

(defn markdown
  [tree]
  (def b @"")
  (defn convert-els
    [node b]
    (each el (array/slice node 1)
      (cond
        (string? el)
        (buffer/push b el)
        (indexed? el)
        (buffer/push b (markdown el)))))
  (case (first tree)
    :a
    (do
      (buffer/push b "[")
      (convert-els tree b)
      (def href (get-in tree [1 :href]))
      (def domain "https://adventofcode.com")
      (def url (if (string/has-prefix? "http" href) href (string domain href)))
      (buffer/push b "](" url ")"))
    :article
    (convert-els tree b)
    :code
    (do
      (buffer/push b "`")
      (convert-els tree b)
      (buffer/push b "`"))
    :em
    (do
      (buffer/push b "_")
      (convert-els tree b)
      (buffer/push b "_"))
    :h2
    (do
      (convert-els tree b)
      (buffer/push b nl nl))
    :li
    (do
      (buffer/push b "- ")
      (convert-els tree b)
      (buffer/push b nl))
    :p
    (do
      (convert-els tree b)
      (buffer/push b nl nl))
    :pre
    (do
      (assert (= :code (get-in tree [1 0])) "<pre> not followed by <code>")
      (convert-els (get tree 1) b)
      (unless (= nl (last b))
        (buffer/push b nl))
      (buffer/push b nl))
    :span
    (convert-els tree b)
    :ul
    (do
      (convert-els tree b)
      (buffer/push b nl))
    # default
    (error (string "unrecognised tag :" (first tree))))
  b)
