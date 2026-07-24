*out* (use judge)
(use sh)
(use ./lib)
(import ../../config/site)

(def omnios-version "r151058")
(def new-publisher-name "localhostomnios")
# If this goes away, the tests will break
(def new-origin-uri "https://sfe.opencsw.org/localhostomnios/")

(def new-publisher-resource
  (string/format `(publisher/ensure "%s" (publisher/origin "%s"))`
                 new-publisher-name new-origin-uri))

(deftest new-initial
  (test (publisher-exists? new-publisher-name) false))

(deftest new-noop-does-nothing
  (test (apply-changes-noop new-publisher-resource) 1)
  (test (publisher-exists? new-publisher-name) false))

(deftest new-ensure
  (test (apply-changes new-publisher-resource) 1)
  (test (publisher-exists? new-publisher-name) true))

(deftest new-idempotent-1
  (test (apply-changes new-publisher-resource true) 0))

(deftest new-noop-remove-does-nothing
  (test (apply-changes-noop (resource "publisher/remove" new-publisher-name)) 1)
  (test (publisher-exists? new-publisher-name) true))

(deftest new-remove
  (test (apply-changes (resource "publisher/remove" new-publisher-name)) 1)
  (test (publisher-exists? new-publisher-name) false))

(deftest new-idempotent-2
  (test (apply-changes (resource "publisher/remove" new-publisher-name)) 0)
  (test (publisher-exists? new-publisher-name) false))

# Manipulate an existing publisher. Something like:
# extra.omnios   origin   online F https://pkg.omnios.org/r151056/extra/
# extra.omnios   mirror   online F https://us-west.mirror.omnios.org/r151056/extra/

(let [publisher-name "extra.omnios"
      origin-uri (string/format "https://pkg.omnios.org/%s/extra/" omnios-version)
      mirror-uri (string/format "https://us-west.mirror.omnios.org/%s/extra/" omnios-version)

      publisher-with-mirror
      (string/format
        `(publisher/ensure "%s" (publisher/origin "%s") (publisher/mirror "%s"))`
        publisher-name
        origin-uri
        mirror-uri)

      publisher-without-mirror
      (string/format
        `(publisher/ensure "%s" (publisher/origin "%s"))`
        publisher-name
        origin-uri)]

  (deftest publisher-with-mirror
    # We can't be sure what publisher setup the zone begins with, do don't check
    # how many changes this makes.
    (test (truthy? (apply-changes publisher-with-mirror)) true)

    (let [publisher-output ($< pkg publisher extra.omnios)]
      (test (truthy? (string/find (string "Origin URI: " origin-uri) publisher-output)) true)
      (test (truthy? (string/find (string "Mirror URI: " mirror-uri) publisher-output)) true)))

  (deftest modify-idempotent-1
    (test (apply-changes publisher-with-mirror) 0))

  (deftest publisher-without-mirror
    (test (apply-changes publisher-without-mirror) 1)

    (let [publisher-output ($< pkg publisher ,publisher-name)]
      (test (truthy? (string/find (string "Origin URI: " origin-uri) publisher-output)) true)
      (test (truthy? (string/find (string "Mirror URI: " mirror-uri) publisher-output)) false)))

  (deftest publisher-with-mirror-revert
    (test (apply-changes publisher-with-mirror) 1)

    (let [publisher-output ($< pkg publisher ,publisher-name)]
      (test (truthy? (string/find (string "Origin URI: " origin-uri) publisher-output)) true)
      (test (truthy? (string/find (string "Mirror URI: " mirror-uri) publisher-output)) true))))
