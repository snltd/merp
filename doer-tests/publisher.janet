(use judge)
(use sh)
(use ./lib)
(import ./site)

(def publisher-name "localhostomnios")
(def publisher-uri "https://sfe.opencsw.org/localhostomnios")

(def publisher-resource (resource "publisher/ensure" publisher-name
                                  :uri publisher-uri))

(deftest initial
  (test (publisher-exists? publisher-name) false))

(deftest noop-does-nothing
  (test (apply-changes-noop publisher-resource) 1)
  (test (publisher-exists? publisher-name) false))

(deftest ensure
  (test (apply-changes publisher-resource) 1)
  (test (publisher-exists? publisher-name) true))

(deftest idempotent-1
  (test (apply-changes publisher-resource) 0))

(deftest noop-remove-does-nothing
  (test (apply-changes-noop (resource "publisher/remove" publisher-name)) 1)
  (test (publisher-exists? publisher-name) true))

(deftest remove
  (test (apply-changes (resource "publisher/remove" publisher-name)) 1)
  (test (publisher-exists? publisher-name) false))

(deftest idempotent-2
  (test (apply-changes (resource "publisher/remove" publisher-name)) 0)
  (test (publisher-exists? publisher-name) false))
