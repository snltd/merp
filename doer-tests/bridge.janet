(use judge)
(use sh)
(use ./lib)
(import ./site)

(test (in-global) nil)

(def basic-bridge "basic")
(def bridge-with-links "with_links")
(def stub-1 "stub1")
(def stub-2 "stub2")

(deftest setup
  (test (bridge-exists? basic-bridge) false)
  (test (etherstub-exists? stub-1) false))

(deftest noop-does-nothing
  (test (apply-changes-noop (gurp-example "bridge/ensure-basic-bridge")) 1)
  (test (bridge-exists? basic-bridge) false))

(deftest create-bridge
  (test (apply-changes (gurp-example "bridge/ensure-basic-bridge")) 1)
  (test (bridge-exists? basic-bridge) true)
  (test ($< dladm show-bridge ,basic-bridge -p) "basic:stp::32768:\n")
  (test ($< dladm show-bridge -l ,basic-bridge -p) ""))

(deftest add-etherstub-link
  (test
    (apply-changes
      (cat
        (resource "bridge/ensure" basic-bridge :links @[stub-1])
        (resource "etherstub/ensure" stub-1)))
    2)
  (test
    # The other fields take time to settle, so just check the link is there
    (string/has-prefix? "stub1:" ($< dladm show-bridge -lp ,basic-bridge))
    true))

(deftest idempotent-1
  (test
    (apply-changes
      (resource "bridge/ensure" basic-bridge :links @[stub-1]))
    0))

(deftest remove-link-change-max-age
  (test
    (apply-changes (resource "bridge/ensure" basic-bridge :priority 8192))
    1)
  (test ($< dladm show-bridge -lp ,basic-bridge) "")
  (test
    ($< dladm show-bridge ,basic-bridge -p)
    "basic:stp:8192/0\\:0\\:0\\:0\\:0\\:0:8192:32768/0\\:0\\:0\\:0\\:0\\:0\n"))

(deftest remove-noop-does-nothing
  (test (apply-changes-noop (resource "bridge/remove" basic-bridge)) 1)
  (test (bridge-exists? basic-bridge) true))

(deftest remove-and-tidy-up
  (test (apply-changes
          (cat (resource "bridge/remove" basic-bridge)
               (resource "etherstub/remove" stub-1)))
        2)
  (test (bridge-exists? basic-bridge) false)
  (test (etherstub-exists? stub-1) false))

(deftest create-bridge-with-links-and-props
  (test
    (apply-changes
      (cat (resource "etherstub/ensure" stub-1)
           (resource "etherstub/ensure" stub-2)
           (gurp-example "bridge/ensure-bridge-with-links-and-props")))
    3)
  (test (bridge-exists? bridge-with-links) true)
  (test (etherstub-exists? stub-1) true)
  (test
    ($< dladm show-bridge
        -o "protect,priority,bhellotime,bfwddelay,forceproto,bmaxage"
        ,bridge-with-links -p)
    "stp:32768:2:15:2:20\n")
  (test
    ($< dladm show-bridge -l ,bridge-with-links -p |cut -d: -f1) "stub1\nstub2\n"))

(deftest idempotent-2
  (test
    (apply-changes (gurp-example "bridge/ensure-bridge-with-links-and-props"))
    0))

(deftest tidy-up
  (test
    (apply-changes
      (cat (resource "bridge/remove" bridge-with-links)
           (resource "etherstub/remove" stub-1)
           (resource "etherstub/remove" stub-2)))
    3)
  (test (bridge-exists? bridge-with-links) false)
  (test (etherstub-exists? stub-1) false)
  (test (etherstub-exists? stub-2) false))
