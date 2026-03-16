(use judge)
(use sh)
(use ./lib)

(def pkg-1 "system/management/ipmitool")
(def pkg-2 "system/management/pcitool")

(deftest initial-check
  (test (pkg-is-installed? pkg-1) false)
  (test (pkg-is-installed? pkg-2) false))

(deftest noop-does-nothing
  (test (apply-changes-noop
          (cat
            (resource "pkg/ensure" pkg-1)
            (resource "pkg/ensure" pkg-2)))
        2)
  (test (pkg-is-installed? pkg-1) false)
  (test (pkg-is-installed? pkg-2) false))

(deftest install-packages
  (test (apply-changes
          (cat
            (resource "pkg/ensure" pkg-1)
            (resource "pkg/ensure" pkg-2)))
        2)
  (test (pkg-is-installed? pkg-1) true)
  (test (pkg-is-installed? pkg-2) true))

(deftest idempotent-1
  (test (apply-changes
          (cat
            (resource "pkg/ensure" pkg-1)
            (resource "pkg/ensure" pkg-2)))
        0)
  (test (pkg-is-installed? pkg-1) true)
  (test (pkg-is-installed? pkg-2) true))

(deftest remove-noop-does-nothing
  (test (apply-changes-noop
          (cat
            (resource "pkg/remove" pkg-1)
            (resource "pkg/remove" pkg-2)))
        2)
  (test (pkg-is-installed? pkg-1) true)
  (test (pkg-is-installed? pkg-2) true))

(deftest remove
  (test (apply-changes
          (cat
            (resource "pkg/remove" pkg-1)
            (resource "pkg/remove" pkg-2)))
        2)
  (test (pkg-is-installed? pkg-1) false)
  (test (pkg-is-installed? pkg-2) false))
  

(deftest idempotent-2
  (test (apply-changes
          (cat
            (resource "pkg/remove" pkg-1)
            (resource "pkg/remove" pkg-2)))
        0)
  (test (pkg-is-installed? pkg-1) false)
  (test (pkg-is-installed? pkg-2) false))
