(use judge)
(use sh)
(use ./lib)
(import ./site)

(def vlan-id 2)

(def vlan-1
  (string
    (string/slice site/physical
                  0
                  (inc (last (peg/find-all :a site/physical)))) "1002"))

(def vlan-object (resource "vlan/ensure" vlan-1
                           :over site/physical
                           :vlan-tag 2))

(deftest setup
  (test (vlan-object-exists? vlan-1) false))

(deftest noop-does-nothing
  (test (apply-changes-noop vlan-object) 1)
  (test (vlan-object-exists? vlan-1) false))

(deftest create-vlan-object
  (test (apply-changes vlan-object) 1)
  (test (vlan-object-exists? vlan-1) true)
  (def dladm-output ($< dladm show-vlan -p -o "link,vid,over" ,vlan-1))
  (test (= dladm-output (string/format "%s:2:%s\n" vlan-1 site/physical)) true))

(deftest idempotent-1
  (test (apply-changes vlan-object) 0))

(deftest remove-noop-does-nothing
  (test (apply-changes-noop (resource "vlan/remove" vlan-1)) 1)
  (test (vlan-object-exists? vlan-1) true)
  (def dladm-output ($< dladm show-vlan -p -o "link,vid,over" ,vlan-1))
  (test (= dladm-output (string/format "%s:2:%s\n" vlan-1 site/physical)) true))

(deftest remove-vlan-object
  (test (apply-changes (resource "vlan/remove" vlan-1)) 1)
  (test (vlan-object-exists? vlan-1) false))

(deftest idempotent-2
  (test (apply-changes (resource "vlan/remove" vlan-1)) 0))
