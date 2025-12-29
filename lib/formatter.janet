
(def nl 10)

(defn- wrap-text
  [text width &opt indent]
  (unless width
    (break text))
  (default indent 0)
  (def res @"")
  (def word @"")
  (var col indent)
  (var i 0)
  (while (def c (get text i))
    (++ col)
    (if (or (= (chr " ") c) (= (chr "\n") c))
      (do
        (when (> col width)
          (when (= (chr " ") (last res))
            (buffer/popn res 1))
          (buffer/push res nl)
          (buffer/push res (string/repeat " " indent))
          (set col (+ indent (length word))))
        (when (= (chr " ") c)
          (buffer/push word c))
        (buffer/push res word)
        (buffer/clear word))
      (buffer/push word c))
    (++ i))
  (when (> col width)
    (buffer/push res nl)
    (buffer/push res (string/repeat " " indent)))
  (buffer/push res word))

(defn markdown
  [tree &opt width indent]
  (default indent 0)
  (def b @"")
  (defn convert-els
    [node b &opt indent]
    (each el (array/slice node 1)
      (cond
        (string? el)
        (buffer/push b el)
        (indexed? el)
        (buffer/push b (markdown el width indent)))))
  (case (first tree)
    :a
    (do
      (buffer/push b "[")
      (convert-els tree b)
      (def href (get-in tree [1 :href]))
      (def base-url (dyn :base-url))
      (def page-url (dyn :page-url))
      (def url
        (cond
          (string/has-prefix? "http" href)
          href
          (string/has-prefix? "/" href)
          (string base-url href)
          (string (->> (string/find-all "/" page-url)
                       (last)
                       (inc)
                       (string/slice page-url 0))
                  href)))
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
      (def content @"")
      (convert-els tree content)
      (buffer/push b "- ")
      (buffer/push b (wrap-text content width 2))
      (buffer/push b nl))
    :p
    (do
      (def content @"")
      (convert-els tree content)
      (buffer/push b (wrap-text content width indent))
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
