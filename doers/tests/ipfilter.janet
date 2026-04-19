(use judge)
(use sh)
(use ./lib)

# This test assumes there are no firewall rules. Even if you start off with
# some, you'll end up with none!
# 
# The test will block ping on the loopback and https egress

(def curl-https
  '[curl --connect-timeout=1 -s -o /dev/null https://omnios.org])
(def curl-http
  '[curl --connect-timeout=1 -s -o /dev/null http://example.com])
(def ping-command
  ~[/usr/sbin/ping google.com 1 :> [,stdout :null] :> [,stderr :null]])
(def ipf-conf "/etc/ipf/ipf.conf")

# Put the ping rules in a file. I don't care about predictable paths here.
(def ping-block-file "/tmp/ping-block")
(spit ping-block-file
      "block out quick proto icmp from any to any icmp-type echo")

# The HTTPS rules will be content:
(def https-rules
  `block out quick proto tcp from any to any port = 443
block out quick proto udp from any to any port = 443`)

# Check initial state
(deftest initial-state
  (test (absent? ipf-conf) true)

  (deftest initial-rules
    (def buffer @"")
    ($< ipfstat -io :> [stderr buffer])
    (test buffer
          @"empty list for ipfilter(out)\nempty list for ipfilter(in)\n"))

  (test ($? ;curl-http) true)
  (test ($? ;curl-https) true)
  (test ($? ;ping-command) true))

(deftest noop-does-nothing
  (test
    (apply-changes-noop
      (cat (resource "ipfilter/ensure" "https-rule"
                     :priority 20
                     :content https-rules)
           (resource "ipfilter/ensure" "ping-rule"
                     :priority 10
                     :from ping-block-file))) 1)

  (test (absent? ipf-conf) true)
  (test ($? ;curl-https) true)
  (test ($? ;ping-command) true))

(deftest apply-rules-and-block-ping-and-https
  (test
    (apply-changes
      (cat (resource "ipfilter/ensure" "https-rule"
                     :priority 20
                     :content https-rules)
           (resource "ipfilter/ensure" "ping-rule"
                     :priority 10
                     :from ping-block-file))) 1)

  (test (present? ipf-conf) true)
  (test ($? ;curl-https) false)
  (test ($? ;ping-command) false))

(deftest noop-change-does-nothing
  (test
    (apply-changes-noop
      (resource "ipfilter/ensure" "https-rule"
                :priority 20
                :content https-rules)) 1)
  (test ($? ;curl-https) false)
  (test ($? ;ping-command) false))

(deftest re-enable-ping-only
  (test
    (apply-changes-noop
      (resource "ipfilter/ensure" "https-rule"
                :priority 20
                :content https-rules)) 1)
  # curl should still fail
  (test ($? ;curl-https) false)
  # ping should now work again
  (test ($? ;ping-command) false))

(deftest ignore-rules-changed-on-the-fly
  # Block http access. Re-running without :always-reload WILL NOT make it work
  # again.
  (test ($? echo "block out quick proto tcp from any to any port = 80" | ipf -f -) true)
  (test ($? ;curl-http) false)
  (test
    (apply-changes
      (cat (resource "ipfilter/ensure" "https-rule"
                     :priority 20
                     :content https-rules)
           (resource "ipfilter/ensure" "ping-rule"
                     :priority 10
                     :from ping-block-file))) 0)
  (test ($? ;curl-http) false))

(deftest reset-rules-changed-on-the-fly
  # Re-running with :always-reload WILL make it work again. (And always shows
  # a change.)
  (test
    (apply-changes
      (cat (resource "ipfilter/ensure" "https-rule"
                     :priority 20
                     :always-reload true
                     :content https-rules)
           (resource "ipfilter/ensure" "ping-rule"
                     :priority 10
                     :from ping-block-file))) 1)
  (test ($? ;curl-http) true))

(deftest remove-noop-does-nothing
  (test
    (apply-changes-noop
      (resource "ipfilter/remove" "just-kidding")) 1)
  (test (absent? ipf-conf) false)
  # curl should still fail
  (test ($? ;curl-https) false))

(deftest remove-all-rules
  (test
    (apply-changes
      (resource "ipfilter/remove" "really")) 1)

  # File flushed, everything working again
  (test (absent? ipf-conf) true)
  (test ($? ;curl-https) true)
  (test ($? ;ping-command) true))

(deftest remove-with-no-rules-does-nothing
  (test
    (apply-changes
      (resource "ipfilter/remove" "really")) 0))
