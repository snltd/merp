(use judge)
(use sh)
(use ./lib)
(import ./site)

# Origin Tests

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

# Mirror tests

(def mirror-publisher "extra.omnios")
(def mirror-uri "https://us-west.mirror.omnios.org/r151050/extra/")

(deftest initial-mirror
  (test (publisher-mirror-exists? mirror-publisher mirror-uri) true))

(deftest mirror-remove-noop-does-nothing
  (test
    (apply-changes-noop
      (resource "publisher/remove" mirror-publisher :mirror mirror-uri)) 1)
  (test (publisher-mirror-exists? mirror-publisher mirror-uri) true))

(deftest mirror-remove
  (test
    (apply-changes
      (resource "publisher/remove" mirror-publisher :mirror mirror-uri)) 1)
  (test (publisher-mirror-exists? mirror-publisher mirror-uri) false))

(deftest mirror-remove-idempotent
  (test
    (apply-changes
      (resource "publisher/remove" mirror-publisher :mirror mirror-uri)) 0)
  (test (publisher-mirror-exists? mirror-publisher mirror-uri) false))

(deftest mirror-add-noop-does-nothing
  (test
    (apply-changes-noop
      (resource "publisher/ensure" mirror-publisher :type "mirror" :uri mirror-uri)) 1)
  (test (publisher-mirror-exists? mirror-publisher mirror-uri) false))

(deftest mirror-add
  (test
    (apply-changes
      (resource "publisher/ensure" mirror-publisher :type "mirror" :uri mirror-uri)) 1)
  (test (publisher-mirror-exists? mirror-publisher mirror-uri) true))

(deftest mirror-add-idempotent
  (test
    (apply-changes
      (resource "publisher/ensure" mirror-publisher :type "mirror" :uri mirror-uri)) 0)
  (test (publisher-mirror-exists? mirror-publisher mirror-uri) true))
