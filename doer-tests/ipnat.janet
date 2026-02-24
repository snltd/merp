(use judge)
(use sh)
(use ./lib)
(import ./site)

(def ipnat-conf "/etc/ipf/ipnat.conf")

(def curl-cmd
  '[curl --connect-timeout=1 -s --interface "10.77.0.1" -o /dev/null http://example.com])

# This test assumes there are no NAT rules. Even if you start off with
# some, you'll end up with none!
#
# It sets up an interface on the loopback and defines a catch-all NAT rule which
# we then test with curl.
# 
(deftest initial-state
  (test (absent? ipnat-conf) true)
  (test
    ($< ipnat -l)
    "List of active MAP/Redirect filters:\n\nList of active sessions:\n")
  (test ($? ;curl-cmd) false))

# Make something to NAT through
(deftest setup
  (test (apply-changes
          (resource "ip-address/ensure" "lo0/merp"
                    :type "static"
                    :address "10.77.0.1/24")) 1))

(deftest noop-does-nothing
  (test (apply-changes-noop
          (resource "ipnat/ensure" "https"
                    :priority 10
                    :content "map e1000g0 10.77.0.0/24 -> 0/32")) 1)
  (test (absent? ipnat-conf) true)
  (test ($? ;curl-cmd) false))

(deftest create-nat-rule
  (test
    (apply-changes
      (resource "ipnat/ensure" "https"
                :priority 10
                :content (string "map " site/physical " 10.77.0.0/24 -> 0/32"))) 1)
  (test ($? ;curl-cmd) true))

(deftest idempotent
  (test (apply-changes-noop
          (resource "ipnat/ensure" "https"
                    :priority 10
                    :content "map e1000g0 10.77.0.0/24 -> 0/32")) 0)
  (test ($? ;curl-cmd) true))

(deftest noop-remove-does-nothing
  (test (apply-changes-noop
          (resource "ipnat/remove" "just-kidding")) 1)
  (test ($? ;curl-cmd) true)
  (test (present? ipnat-conf) true))

(deftest remove-all-rules-and-interface
  (test (apply-changes
          (cat (resource "ip-address/remove" "lo0/merp")
               (resource "ipnat/remove" "just-kidding")))
        2)
  (test ($? ;curl-cmd) false)
  (test (absent? ipnat-conf) true))

(deftest remove-does-nothing
  (test (apply-changes
          (resource "ip-address/remove" "lo0/merp")) 0))
