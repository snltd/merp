(use judge)
(use sh)
(use ./lib)

(deftest create-noop-does-nothing
  (test (group-exists? "new-group") false)
  (test (apply-changes-noop (gurp-example "group/ensure-new-group")) 1)
  (test (group-exists? "new-group") false))

(deftest create-group
  (test (apply-changes (gurp-example "group/ensure-new-group")) 1)
  (test (group-exists? "new-group" 264) true))

(deftest idempotent-create
  (test (apply-changes (gurp-example "group/ensure-new-group")) 0))

(deftest change-gid
  (test (apply-changes (resource "group/ensure" "new-group" :gid 1991)) 1)
  (test (group-exists? "new-group" 1991) true))

(deftest remove-with-noop-does-nothing
  (test (apply-changes-noop (resource "group/remove" "new-group")) 1)
  (test (group-exists? "new-group" 1991) true))

(deftest remove-group
  (test (apply-changes (resource "group/remove" "new-group")) 1)
  (test (group-exists? "new-group") false))

(deftest idempotent-remove
  (test (apply-changes (resource "group/remove" "new-group")) 0)
  (test (group-exists? "new-group") false))

(deftest cannot-remove-protected-group
  # You're doing this somewhere safe, right?
  (test (apply-fails (resource "group/remove" "root")
                     "protected resource: root") true))
