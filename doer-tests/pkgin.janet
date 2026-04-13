(use judge)
(use sh)
(use ./lib)

(def pkg-1 "ripgrep")
(def pkg-2 "rust")

(deftest initial-check
  (test (pkgin-is-installed? pkg-1) false)
  (test (pkgin-is-installed? pkg-2) false))

(deftest noop-does-nothing
  (test (apply-changes-noop
          (cat
            (resource "pkgin/ensure" pkg-1)
            (resource "pkgin/ensure" pkg-2)))
        2)
  (test (pkgin-is-installed? pkg-1) false)
  (test (pkgin-is-installed? pkg-2) false))

(deftest install-packages
  (test (apply-changes
          (cat
            (resource "pkgin/ensure" pkg-1)
            (resource "pkgin/ensure" pkg-2)))
        2)
  (test (pkgin-is-installed? pkg-1) true)
  (test (pkgin-is-installed? pkg-2) true))

(deftest idempotent-1
  (test (apply-changes
          (cat
            (resource "pkgin/ensure" pkg-1)
            (resource "pkgin/ensure" pkg-2)))
        0)
  (test (pkgin-is-installed? pkg-1) true)
  (test (pkgin-is-installed? pkg-2) true))

(deftest remove-noop-does-nothing
  (test (apply-changes-noop
          (cat
            (resource "pkgin/remove" pkg-1)
            (resource "pkgin/remove" pkg-2)))
        2)
  (test (pkgin-is-installed? pkg-1) true)
  (test (pkgin-is-installed? pkg-2) true))

(deftest remove
  (test (apply-changes
          (cat
            (resource "pkgin/remove" pkg-1)
            (resource "pkgin/remove" pkg-2)))
        2)
  (test (pkgin-is-installed? pkg-1) false)
  (test (pkgin-is-installed? pkg-2) false))
  

(deftest idempotent-2
  (test (apply-changes
          (cat
            (resource "pkgin/remove" pkg-1)
            (resource "pkgin/remove" pkg-2)))
        0)
  (test (pkgin-is-installed? pkg-1) false)
  (test (pkgin-is-installed? pkg-2) false))
