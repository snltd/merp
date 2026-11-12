(use judge)
(use sh)
(import ../../config/site)
(use ./lib)

(def ipmp "ipmp0")
(def vnic-1 "mvnic1")
(def vnic-2 "mvnic2")

(deftest setup
  (test
    (apply-changes
      (cat (resource "vnic/ensure" vnic-1 :over site/physical)
           (resource "vnic/ensure" vnic-2 :over site/physical)
           (resource "ip-interface/ensure" vnic-1)
           (resource "ip-interface/ensure" vnic-2)))
    4))

(deftest noop-create-does-nothing
  (test (ipmp-group-exists? ipmp) false)

  (test (apply-changes-noop
          (resource "ipmp/ensure" ipmp
                    :interfaces @[vnic-1 vnic-2]))
        1)
  (test (ipmp-group-exists? ipmp) false))

(deftest create
  (test (ipmp-group-exists? ipmp) false)
  (test (apply-changes
          (resource "ipmp/ensure" ipmp
                    :interfaces @[vnic-1 vnic-2]))
        1)
  (test (ipmp-group-exists? ipmp) true)
  (test ($< ipmpstat -g |grep ,ipmp) "ipmp0       ipmp0       ok        --        mvnic1 mvnic2\n"))

(deftest noop-remove-does-nothing
  (test (ipmp-group-exists? ipmp) true)
  (test (apply-changes-noop
          (resource "ipmp/remove" ipmp))
        1)
  (test (ipmp-group-exists? ipmp) true))

(deftest remove
  (test (ipmp-group-exists? ipmp) true)
  (test (apply-changes
          (resource "ipmp/remove" ipmp))
        1)
  (test (ipmp-group-exists? ipmp) false))

(deftest cleanup
  (test
    (apply-changes
      (cat (resource "vnic/remove" vnic-1)
           (resource "ip-interface/remove" vnic-1)
           (resource "ip-interface/remove" vnic-2)
           (resource "vnic/remove" vnic-2)))
    4))
