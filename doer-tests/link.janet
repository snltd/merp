(use judge)
(use sh)
(use ./lib)

(def dir-1 "/tmp/merp/link-test-dir")
(def file-1 (string dir-1 "/file-1"))
(def file-2 (string dir-1 "/file-2"))
(def file-3 (string dir-1 "/file-3"))
(def link-1 (string dir-1 "/link-1"))
(def link-2 (string dir-1 "/link-2"))
(def source-1 "/etc/release")

(deftest setup
  (test (apply-changes
          (cat (resource "directory/ensure" dir-1)
               (resource "file/ensure" file-1 :content "file-1")
               (resource "file/ensure" file-2 :content "file-2")
               (resource "file/ensure" file-3 :content "file-3"))) 4)
  (test (present? dir-1) true)
  (test (present? file-1) true)
  (test (present? file-2) true)
  (test (present? file-3) true)
  (test (absent? link-1) true))

(deftest noop-does-nothing
  (test (apply-changes-noop (resource "link/ensure" link-1 :source source-1)) 1)
  (test (absent? link-1) true))

(deftest create-new-symlink
  (test (apply-changes (resource "link/ensure" link-1 :source source-1)) 1)
  (test (present? link-1) true)
  (test ($< readlink -f ,link-1) "/etc/release\n"))

(deftest idempotent-1
  (test (apply-changes (resource "link/ensure" link-1 :source source-1)) 0)
  (test (present? link-1) true)
  (test ($< readlink -f ,link-1) "/etc/release\n"))

(deftest create-link-when-file-exists-fails-sensibly
  (test
    (apply-fails
      (resource "link/ensure" file-1 :source file-2)
      (string "link target [" file-1 "] is a file, and force-link is not set"))
    true))

(deftest create-link-when-file-exists-can-be-forced
  (test
    (apply-changes (resource "link/ensure" file-3
                             :source file-2
                             :force-link true)) 1)
  (test ($< readlink -f ,file-3) "/tmp/merp/link-test-dir/file-2\n")
  (test (slurp file-3) @"file-2"))


(deftest cross-device-hard-link-fails-sensibly
  (test (apply-fails (resource "link/ensure" link-2
                               :source source-1
                               :type "hard")
                     "Cross-device link") true))

(deftest create-new-hard-link
  (test (absent? link-2) true)
  (test (apply-changes (resource "link/ensure" link-2
                                 :source file-1
                                 :type "hard")) 1)
  (test (present? link-2) true)
  (test (= (os/stat file-1 :inode) (os/stat link-2 :inode)) true)
  (test (slurp link-2) @"file-1"))

(deftest idempotent-2
  (test (apply-changes (resource "link/ensure" link-2
                                 :source file-1
                                 :type "hard")) 0))

(deftest clean-up
  (test (apply-changes (resource "directory/remove" dir-1)) 1)
  (test (absent? dir-1) true))
