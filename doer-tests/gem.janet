(use "judge")
(use "sh")
(use "./lib")

(def gem-1 "webscale")
(def gem-2 "wavefront-sdk")
(def gem-2-ver "7.0.0")

# Test using the default /opt/ooce/bin/gem

(def system-gem "/opt/ooce/bin/gem")

(deftest setup
  (test (truthy? (apply-changes (resource "pkg/ensure" "ruby-34"))) true))

(deftest noop-does-nothing
  (test (gem-exists? gem-1) false)
  (test (apply-changes-noop (resource "gem/ensure" gem-1)) 1)
  (test (gem-exists? gem-1) false))

(deftest install-two-gems-in-one-go
  (test (gem-exists? gem-1) false)
  (test (gem-exists? gem-2) false)
  (test (apply-changes
          (cat (resource "gem/ensure" gem-1)
               (resource "gem/ensure" gem-2 :version gem-2-ver))) 2)
  (test (gem-exists? gem-1) true)
  (test (gem-exists? gem-2) true)
  (def grep-pattern (string/format "^%s (%s)" gem-2 gem-2-ver))

  (test
    ($? ,system-gem list ,gem-2 |grep -q ,grep-pattern) true))

(deftest idempotent-1
  (test (apply-changes
          (cat (resource "gem/ensure" gem-1)
               (resource "gem/ensure" gem-2 :version gem-2-ver))) 0))

(deftest remove-noop-does-nothing
  (test (gem-exists? gem-1) true)
  (test (apply-changes-noop (resource "gem/remove" gem-1)) 1)
  (test (gem-exists? gem-1) true))

(deftest remove-gems
  (test (gem-exists? gem-1) true)
  (test (gem-exists? gem-2) true)
  (test (apply-changes
          (cat (resource "gem/remove" gem-1)
               (resource "gem/remove" gem-2))) 2)
  (test (gem-exists? gem-1) false)
  (test (gem-exists? gem-2) false))

(deftest idempotent-2
  (test (apply-changes
          (cat (resource "gem/remove" gem-1)
               (resource "gem/remove" gem-2))) 0))
