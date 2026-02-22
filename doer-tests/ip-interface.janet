(use judge)
(use sh)
(import ./site)
(use ./lib)

(def vnic-1 "mvnic1")
(def if-1 vnic-1)

# setup
(test (apply-changes (resource "vnic/ensure" vnic-1 :over site/physical)) 1)
(test (vnic-exists? vnic-1) true)
(test (ip-interface-exists? if-1) false)

(def spec
  (resource "ip-interface/ensure" if-1
            :ipv4 {:forwarding true
                   :mtu 1234}
            :ipv6 {:forwarding false
                   :nud false}))

# noop should not create the interface
(test (apply-changes-noop spec) 1)
(test (ip-interface-exists? if-1) false)

# Second apply should do nothing
(test (apply-changes spec) 1)
(test (ip-interface-exists? if-1) true)
(test (apply-changes spec) 0)

# noop remove should not remove the interface
(test (apply-changes-noop (resource "ip-interface/remove" if-1)) 1)
(test (ip-interface-exists? if-1) true)
(test
  ($< ipadm show-ifprop -c -o "property,proto,current" ,if-1)
  "arp:ipv4:on\nforwarding:ipv4:on\nmetric:ipv4:0\nmtu:ipv4:1234\nexchange_routes:ipv4:on\nusesrc:ipv4:none\nforwarding:ipv6:off\nmetric:ipv6:0\nmtu:ipv6:1500\nnud:ipv6:off\nexchange_routes:ipv6:on\nusesrc:ipv6:none\nstandby:ip:off\n")

# Remove if and tidy up
(test
  (apply-changes
    (cat (resource "ip-interface/remove" if-1)
         (resource "vnic/remove" vnic-1))) 2)

(test (ip-interface-exists? if-1) false)
(test (vnic-exists? vnic-1) false)
