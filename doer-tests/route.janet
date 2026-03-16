(use judge)
(use sh)
(use ./lib)
(import ./site)

(def stub-1 "mstub1")
(def vnic-1 "vnic1")
(def vnic-2 "vnic2")
(def addr-obj1 "vnic1/v4")
(def addr-obj2 "vnic2/v4")
(def addr-1 "10.99.0.1")
(def addr-2 "10.99.1.1")

(def blackhole-address "203.0.113.10")

(deftest setup
  (test
    (apply-changes
      (cat (resource "vnic/ensure" vnic-1 :over stub-1)
           (resource "vnic/ensure" vnic-2 :over stub-1)
           (resource "etherstub/ensure" stub-1)
           (resource "ip-interface/ensure" vnic-1)
           (resource "ip-interface/ensure" vnic-2)
           (resource "ip-address/ensure" addr-obj1
                     :type "static"
                     :address (string addr-1 "/24"))
           (resource "ip-address/ensure" addr-obj2
                     :type "static"
                     :address (string addr-2 "/24"))))
    7))

(deftest noop-does-nothing
  (test (apply-changes-noop (gurp-example "route/ensure-blackhole")) 1))

(deftest ping-blackhole-addr-no-answer-1
  (def buf @"")
  (try
    ($< ping ,blackhole-address 1 > [stdout buf])
    ([e]))
  (test (truthy? (string/find "Net Unreachable from gateway" buf)) true))

(deftest create-blackhole-route
  (test (apply-changes (gurp-example "route/ensure-blackhole")) 1)
  (test ($< netstat -nr |grep "^203.0.113.0")
        "203.0.113.0          127.0.0.1            UB        1          0 lo0       \n")
  (def buf @"")
  (try
    ($< ping ,blackhole-address 1 > [stdout buf])
    ([e]))
  (test buf @"no answer from 203.0.113.10\n"))

(deftest remove-blackhole-noop-does-nothing
  (test (apply-changes-noop (gurp-example "route/remove-blackhole")) 1)
  (test ($< netstat -nr |grep "^203.0.113.0")
        "203.0.113.0          127.0.0.1            UB        1          1 lo0       \n"))

(deftest remove-blackhole
  (test (apply-changes (gurp-example "route/remove-blackhole")) 1)

  (def buf @"")
  (try
    ($< ping ,blackhole-address 1 > [stdout buf])
    ([e]))
  (test (truthy? (string/find "Net Unreachable from gateway" buf)) true))

(deftest clean-up
  (test (apply-changes
          (cat (resource "vnic/remove" vnic-1)
               (resource "etherstub/remove" stub-1)
               (resource "ip-interface/remove" vnic-1)
               (resource "ip-interface/remove" vnic-2)
               (resource "ip-address/remove" addr-obj1)
               (resource "ip-address/remove" addr-obj2)
               (resource "vnic/remove" vnic-2)))
        7))
