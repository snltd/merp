(use judge)
(use sh)
(import ./site)
(use ./lib)

# Not using examples here, because we don't know what our address range might be

(def vnic-1 "mvnic1")
(def if-1 vnic-1)
(def addr-1 (string vnic-1 "/v4"))

(deftest setup
  (test (apply-changes
          (cat
            (resource "vnic/ensure" vnic-1 :over site/physical)
            (resource "ip-interface/ensure" if-1))) 2))

(deftest noop-create-does-nothing
  (test (ip-address-exists? addr-1) false)
  (test (apply-changes-noop
          (resource "ip-address/ensure" addr-1
                    :address (string site/doer-addr-1 "/" site/doer-mask)
                    :type "static")) 1)
  (test (ip-address-exists? addr-1) false))

(deftest create-address
  (test (apply-changes
          (resource "ip-address/ensure" addr-1
                    :address (string site/doer-addr-1 "/" site/doer-mask)
                    :type "static")) 1)
  (test (ip-address-exists? addr-1) true)
  (test (apply-changes
          (resource "ip-address/ensure" addr-1
                    :address (string site/doer-addr-1 "/" site/doer-mask)
                    :type "static")) 0)
  (test (ip-address-exists? addr-1) true)
  (test (ping? site/doer-addr-1) true))

(deftest change-address-and-property
  (test ($< ipadm show-addrprop ,addr-1 -c -o current -p private) "off\n")
  (test (apply-changes
          (resource "ip-address/ensure" addr-1
                    :address (string site/doer-addr-2 "/" site/doer-mask)
                    :properties {:private true}
                    :type "static")) 1)
  (test ($< ipadm show-addrprop ,addr-1 -c -o current -p private) "on\n")
  (test (ping? site/doer-addr-1) false)
  (test (ping? site/doer-addr-2) true))

(deftest noop-remove-does-nothing
  (test (apply-changes-noop (resource "ip-address/remove" addr-1)) 1)
  (test (ip-address-exists? addr-1) true))

(deftest clean-up
  (test (apply-changes
          (cat
            (resource "vnic/remove" vnic-1)
            (resource "ip-interface/remove" if-1)
            (resource "ip-address/remove" addr-1))) 3)
  (test (vnic-exists? vnic-1) false)
  (test (ip-interface-exists? if-1) false)
  (test (ip-address-exists? addr-1) false))
