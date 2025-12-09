(use ../deps/testament)

(review ../lib/cmd-puzzle :as cmd)

(deftest parse-explanation-single-part
  (def html
    ```
    <html>
    <body>
    <article class="day-desc">
    <h2>--- Day 1: Problem Title ---</h2>
    <p>This is the problem description.</p>
    </article>
    </body>
    </html>
    ```)
  (def expect
    ```
    --- Day 1: Problem Title ---

    This is the problem description.
    ```)
  (def actual (cmd/parse-explanation html))
  (is (== (string expect "\n\n") actual)))

(deftest parse-explanation-two-parts
  (def html
    ```
    <html>
    <body>
    <article class="day-desc">
    <h2>--- Day 1: Part One ---</h2>
    <p>Part one description.</p>
    <h2>--- Day 1: Part Two ---</h2>
    <p>Part two description.</p>
    </article>
    </body>
    </html>
    ```)
  (def expect
    ```
    --- Day 1: Part One ---

    Part one description.

    --- Day 1: Part Two ---

    Part two description.
    ```)
  (def actual (cmd/parse-explanation html))
  (is (== (string expect "\n\n") actual)))

(deftest parse-explanation-with-wrapping
  (def html
    ```
    <html>
    <body>
    <article class="day-desc">
    <h2>--- Day 1 ---</h2>
    <p>This is a very long paragraph that should be wrapped when the width parameter is specified.</p>
    </article>
    </body>
    </html>
    ```)
  (def expect
    ```
    --- Day 1 ---

    This is a very long
    paragraph that
    should be wrapped
    when the width
    parameter is 
    specified.
    ```)
  (def actual (cmd/parse-explanation html 20))
  (is (== (string expect "\n\n") actual)))

(deftest parse-explanation-no-article-fails
  (def html "<html><body>No article here</body></html>")
  (assert-thrown-message "no <article> in HTML" (cmd/parse-explanation html)))

(run-tests!)
