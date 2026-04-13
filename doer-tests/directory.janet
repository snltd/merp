(use judge)
(use sh)
(use ./lib)

(def dir-1 "/example/dir_1")
(def dir-2 "/example/dir_2")
(def dir-3 "/example/dir_3")

(deftest noop-does-not-create
  (test (apply-changes-noop (gurp-example "directory/ensure-default-dir")) 1)
  (test (absent? dir-1) true))

(deftest all-defaults
  (test (apply-changes (gurp-example "directory/ensure-default-dir")) 1)
  (test (present? dir-1) true)
  (test (metadata dir-1) "root:root drwxr-xr-x\n"))

(deftest change-owner-and-mode
  (test (apply-changes
          (resource "directory/ensure" dir-1 :owner "adm" :mode "0700")) 1)
  (test (metadata dir-1) "adm:root drwx------\n"))

(deftest noop-does-not-remove
  (test (apply-changes-noop (resource "directory/remove" dir-1)) 1)
  (test (present? dir-1) true))

(deftest create-with-names
  (test (apply-changes (gurp-example "directory/ensure-with-names")) 1)
  (test (present? dir-2) true)
  (test (metadata dir-2) "adm:sys drwx------\n"))

(deftest idempotent-1
  (test (apply-changes (gurp-example "directory/ensure-with-names")) 0))

(deftest create-with-ids
  (test (apply-changes (gurp-example "directory/ensure-with-ids")) 1)
  (test (present? dir-3) true)
  (test (metadata dir-3) "adm:daemon drwxr-s---\n"))

(deftest idempotent-2
  (test (apply-changes (gurp-example "directory/ensure-with-ids")) 0))

(deftest directory-cannot-clobber-file
  (def blocker (pathcat dir-3 "blocker"))
  (test (apply-changes (resource "file/ensure" blocker :content "abc")) 1)
  (test (present? blocker) true)
  (test (os/stat blocker :mode) :file)
  (test
    (apply-fails
      (resource "directory/ensure" blocker)
      (string blocker " exists and is not a directory")) true)
  (test (present? blocker) true)
  (test (os/stat blocker :mode) :file))

(deftest removal-is-recursive
  (test (apply-changes (gurp-example "directory/remove-dir")) 1)
  (test (absent? "/example") true)
  (test (absent? dir-1) true)
  (test (absent? dir-2) true)
  (test (absent? dir-3) true))
