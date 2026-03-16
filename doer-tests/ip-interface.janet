(use judge)
(use sh)
(import ./site)
(use ./lib)

(def vnic-1 "example1")
(def if-1 vnic-1)
(def example-file "ip-interface/ensure-interface-with-options-and-label")

(deftest setup
  (test (apply-changes (resource "vnic/ensure" vnic-1 :over site/physical)) 1)
  (test (vnic-exists? vnic-1) true)
  (test (ip-interface-exists? if-1) false))

(deftest noop-create-does-nothing
  (test (apply-changes-noop (gurp-example example-file)) 1)
  (test (ip-interface-exists? if-1) false))

(deftest create-interface
  (test (apply-changes (gurp-example example-file)) 1)
  (test (ip-interface-exists? if-1) true)
  (test
    ($< ipadm show-ifprop -c -o "property,proto,current" ,if-1)
    "arp:ipv4:on\nforwarding:ipv4:on\nmetric:ipv4:0\nmtu:ipv4:1500\nexchange_routes:ipv4:on\nusesrc:ipv4:none\nforwarding:ipv6:off\nmetric:ipv6:0\nmtu:ipv6:1500\nnud:ipv6:on\nexchange_routes:ipv6:on\nusesrc:ipv6:none\nstandby:ip:off\n"))

(deftest idempotent-create
  (test (apply-changes (gurp-example example-file)) 0))

(deftest change-property
  (test (apply-changes
          (->> (gurp-example example-file)
               (string/replace-all "true" "false"))) 1)
  (test
    ($< ipadm show-ifprop -c -o "property,proto,current" ,if-1)
    "arp:ipv4:on\nforwarding:ipv4:off\nmetric:ipv4:0\nmtu:ipv4:1500\nexchange_routes:ipv4:on\nusesrc:ipv4:none\nforwarding:ipv6:off\nmetric:ipv6:0\nmtu:ipv6:1500\nnud:ipv6:on\nexchange_routes:ipv6:on\nusesrc:ipv6:none\nstandby:ip:off\n"))

(deftest noop-remove-does-nothing
  (test (apply-changes-noop (resource "ip-interface/remove" if-1)) 1)
  (test (ip-interface-exists? if-1) true))

(deftest cleanup
  (test
    (apply-changes
      (cat (resource "ip-interface/remove" if-1)
           (resource "vnic/remove" vnic-1)))
    2)

  (test (ip-interface-exists? if-1) false)
  (test (vnic-exists? vnic-1) false))

(deftest idempotent-remove
  (test (apply-changes (resource "ip-interface/remove" if-1)) 0))
