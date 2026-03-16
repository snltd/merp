(use judge)
(use sh)
(use ./lib)

(test (in-global) nil)

(def stub-1 "newstub0")

(deftest noop-create-does-nothing
  (test (etherstub-exists? stub-1) false)
  (test (apply-changes-noop (gurp-example "etherstub/ensure-stub")) 1)
  (test (etherstub-exists? stub-1) false))

(deftest create-stub
  (test (apply-changes (gurp-example "etherstub/ensure-stub")) 1)
  (test (etherstub-exists? stub-1) true))

(deftest idempotent
  (test (apply-changes (gurp-example "etherstub/ensure-stub")) 0))

(deftest noop-remove-does-nothing
  (test (etherstub-exists? stub-1) true)
  (test (apply-changes-noop (resource "etherstub/remove" stub-1)) 1)
  (test (etherstub-exists? stub-1) true))

(deftest cleanup
  (test (apply-changes (resource "etherstub/remove" stub-1)) 1)
  (test (etherstub-exists? stub-1) false))

(deftest remove-nothing-does-nothing
  (test (apply-changes (resource "etherstub/remove" stub-1)) 0))

(deftest fail-with-invalid-name
  (test
    (apply-fails (resource "etherstub/ensure" "stubby")
                 "dladm: invalid link name 'stubby'")
    true))
