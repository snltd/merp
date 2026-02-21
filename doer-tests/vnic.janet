(use judge)
(use sh)
(use ./lib)

(test (in-global) nil)

(def physical "e1000g0")
(def vnic-1 "mvnic1")
(def ip-interface-1 vnic-1)

(test (vnic-exists? vnic-1) false)

# A noop should do nothing
(test (apply-changes-noop (resource "vnic/ensure" vnic-1 :over physical)) 1)
(test (vnic-exists? vnic-1) false)

# Create a vnic. Second apply should show no change
(test (apply-changes (resource "vnic/ensure" vnic-1 :over physical)) 1)
(test (vnic-exists? vnic-1) true)
(test (apply-changes (resource "vnic/ensure" vnic-1 :over physical)) 0)

# Noop remove should do nothing but show a change
(test (apply-changes-noop (resource "vnic/remove" vnic-1)) 1)
(test (vnic-exists? vnic-1) true)

# Remove
(test (apply-changes (resource "vnic/remove" vnic-1)) 1)
(test (vnic-exists? vnic-1) false)

# Create with an ip-interface
(test (ip-interface-exists? ip-interface-1) false)
(test (apply-changes (resource "vnic/ensure" vnic-1
                               :over physical
                               :with-interface true)) 1)
(test (vnic-exists? vnic-1) true)
(test (ip-interface-exists? ip-interface-1) true)

# It's the user's responsibility to remove the ip-interface
(test (apply-fails (resource "vnic/remove" vnic-1)
                   "vnic deletion failed: link busy")
      true)
(test (apply-changes (resource "ip-interface/remove" ip-interface-1)) 1)
(test (apply-changes (resource "vnic/remove" vnic-1)) 1)
(test (vnic-exists? vnic-1) false)
(test (ip-interface-exists? ip-interface-1) false)

# Create a VNIC with a VLAN tag
(test (apply-changes (resource "vnic/ensure" vnic-1
                               :over physical
                               :vlan-tag 33)) 1)
(test ($< dladm show-vnic -p -o "link,over,vid" ,vnic-1) "mvnic1:e1000g0:33\n")
(test (apply-changes (resource "vnic/remove" vnic-1)) 1)
(test (vnic-exists? vnic-1) false)

# Fail with an invalid name
(test (apply-fails (resource "vnic/ensure" "niccy-nic-nic" :over physical)
                   "dladm: invalid link name 'niccy-nic-nic'")
      true)
