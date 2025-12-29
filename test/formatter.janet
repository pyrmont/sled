(use ../deps/testament)

(import ../lib/formatter :as f)

(deftest markdown-plain-text
  (def input [:p "hello world"])
  (def expect "hello world\n\n")
  (is (== expect (f/markdown input))))

(deftest markdown-emphasis
  (def input [:p [:em "hello"]])
  (def expect "_hello_\n\n")
  (is (== expect (f/markdown input))))

(deftest markdown-code
  (def input [:p [:code "foo"]])
  (def expect "`foo`\n\n")
  (is (== expect (f/markdown input))))

(deftest markdown-link-external
  (def input [:p [:a {:href "https://example.com"} "link"]])
  (def expect "[link](https://example.com)\n\n")
  (is (== expect (f/markdown input))))

(deftest markdown-link-internal
  (def input [:p [:a {:href "/2025/day/1"} "link"]])
  (def expect "[link](https://example.org/2025/day/1)\n\n")
  (is (== expect (with-dyns [:base-url "https://example.org"]
                   (f/markdown input)))))

(deftest markdown-link-relative
  (def input [:p [:a {:href "baz"} "link"]])
  (def expect "[link](https://example.org/foo/baz)\n\n")
  (is (== expect (with-dyns [:base-url "https://example.org"
                             :page-url "https://example.org/foo/bar"]
                   (f/markdown input)))))

(deftest markdown-heading
  (def input [:h2 "Section"])
  (def expect "Section\n\n")
  (is (== expect (f/markdown input))))

(deftest markdown-list
  (def input [:ul [:li "foo"] [:li "bar"]])
  (def expect "- foo\n- bar\n\n")
  (is (== expect (f/markdown input))))

(deftest markdown-list-item-wrapping
  (def input [:ul [:li "this is a very long list item that should wrap"]])
  (def expect "- this is a very\n  long list item\n  that should wrap\n\n")
  (is (== expect (f/markdown input 20))))

(deftest markdown-preformatted
  (def input [:pre [:code "code block"]])
  (def expect "code block\n\n")
  (is (== expect (f/markdown input))))

(deftest markdown-paragraph-wrapping
  (def input [:p "this is a very long paragraph that should wrap at the specified width"])
  (def expect "this is a very long\nparagraph that\nshould wrap at the\nspecified width\n\n")
  (is (== expect (f/markdown input 20))))

(deftest markdown-nested
  (def input [:p "hello " [:em "world"] " " [:code "test"]])
  (def expect "hello _world_ `test`\n\n")
  (is (== expect (f/markdown input))))

(deftest markdown-article
  (def input [:article [:p "content"]])
  (def expect "content\n\n")
  (is (== expect (f/markdown input))))

(deftest markdown-span
  (def input [:p [:span "text"]])
  (def expect "text\n\n")
  (is (== expect (f/markdown input))))

(run-tests!)
