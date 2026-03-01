(use judge)
(use sh)
(use ./lib)
(import ./site)

(test (in-global) nil)

(def test-flow "merp-flow")
(def vnic-1 "vnic1")

(deftest setup
  (test (apply-changes (resource "vnic/ensure" vnic-1 :over site/physical)) 1)
  (test (network-flow-exists? "tls-throttle") false)
  (test (vnic-exists? vnic-1) true))

(deftest noop-does-nothing
  (test
    (apply-changes-noop (gurp-example "network-flow/ensure-01")) 1)
  (test (network-flow-exists? "tls-throttle") false))

(deftest create-example-flow-1
  (test
    (apply-changes (gurp-example "network-flow/ensure-01")) 1)
  (test (network-flow-exists? "tls-throttle") true))

(deftest idempotent-1
  (test
    (apply-changes (gurp-example "network-flow/ensure-01")) 0)
  (test (network-flow-exists? "tls-throttle") true))

(deftest remove-noop-does-nothing
  (test (apply-changes-noop (resource "network-flow/remove" "tls-throttle")) 1)
  (test (network-flow-exists? "tls-throttle") true))

(deftest clean-up
  (test (apply-changes
          (cat (resource "network-flow/remove" "tls-throttle")
               (resource "vnic/remove" vnic-1))) 2)
  (test (network-flow-exists? "tls-throttle") false)
  (test (vnic-exists? vnic-1) false))
