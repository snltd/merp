(use judge)
(use sh)
(use ./lib)

# This is one of the few doers that can be tested thoroughly in the Rust code.
# We only need to do the basics here.

(def dir-1 "/tmp/merp/file-line-test")
(def file-1 (string dir-1 "/test-file"))
(def original-content
  `header
-------
Gibbus the weasel
Chubb the pig
`)

# Error if the file does not exist
(test
  (apply-fails
    (resource "file-line/ensure" file-1 :line "rah")
    (string file-1 " does not exist: file-line cannot ensure its contents"))
  true)

# Error if the "file" isn't a file
(test (apply-changes (resource "directory/ensure" dir-1)) 1)
(test
  (apply-fails
    (resource "file-line/ensure" dir-1 :line "rah")
    (string dir-1 " is not a regular file"))
  true)

# Setup
(test (apply-changes (resource "file/ensure" file-1 :content original-content)) 1)

# No changes
(test (apply-changes (resource "file-line/ensure" file-1 :line "Chubb the pig")) 0)
(test (= (string (slurp file-1)) original-content) true)

# Add a line
(test (apply-changes (resource "file-line/ensure" file-1 :line "The Owl")) 1)
(test
  (= `header
-------
Gibbus the weasel
Chubb the pig
The Owl
`)
  true)

# Change the thes
(test (apply-changes (resource "file-line/ensure" file-1
                               :replace "the" :with "is a" :apply-to "all")) 1)
(test
  (= `header
-------
Gibbus is a weasel
Chubb is a pig
The Owl
`)
  true)

# Tidy up
(test (apply-changes (resource "directory/remove" dir-1)) 1)
