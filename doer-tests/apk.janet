(use judge)
(use sh)
(use ./lib)

(def apk-1 "grafana")
(def apk-2 "helix")

(deftest initial-check
  (test (apk-is-installed? apk-1) false)
  (test (apk-is-installed? apk-2) false))

(deftest noop-does-nothing
  (test (apply-changes-noop
          (cat
            (resource "apk/ensure" apk-1)
            (resource "apk/ensure" apk-2)))
        2)
  (test (apk-is-installed? apk-1) false)
  (test (apk-is-installed? apk-2) false))

(deftest install-packages
  (test (apply-changes
          (cat
            (resource "apk/ensure" apk-1)
            (resource "apk/ensure" apk-2)))
        2)
  (test (apk-is-installed? apk-1) true)
  (test (apk-is-installed? apk-2) true))

(deftest idempotent-1
  (test (apply-changes
          (cat
            (resource "apk/ensure" apk-1)
            (resource "apk/ensure" apk-2)))
        0)
  (test (apk-is-installed? apk-1) true)
  (test (apk-is-installed? apk-2) true))

(deftest remove-noop-does-nothing
  (test (apply-changes-noop
          (cat
            (resource "apk/remove" apk-1)
            (resource "apk/remove" apk-2)))
        2)
  (test (apk-is-installed? apk-1) true)
  (test (apk-is-installed? apk-2) true))

(deftest remove
  (test (apply-changes
          (cat
            (resource "apk/remove" apk-1)
            (resource "apk/remove" apk-2)))
        2)
  (test (apk-is-installed? apk-1) false)
  (test (apk-is-installed? apk-2) false))
  

(deftest idempotent-2
  (test (apply-changes
          (cat
            (resource "apk/remove" apk-1)
            (resource "apk/remove" apk-2)))
        0)
  (test (apk-is-installed? apk-1) false)
  (test (apk-is-installed? apk-2) false))
