(use judge)
(use sh)
(use ./lib)
(import ../../config/site)

(def new-publisher-name "localhostomnios")
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

# Manipulate an existing publisher. This assumes you've got a standard OmniOS setup
# of the given revision
# extra.omnios                origin   online F https://pkg.omnios.org/r151056/extra/
# extra.omnios                mirror   online F https://us-west.mirror.omnios.org/r151056/extra/

(def modify-publisher-name "extra.omnios")
(def modify-origin-uri "https://pkg.omnios.org/r151056/extra/")
(def modify-mirror-uri "https://us-west.mirror.omnios.org/r151056/extra/")

(def modify-publisher-resource-with-mirror
  (string/format `(publisher/ensure "%s" (publisher/origin "%s") (publisher/mirror "%s"))`
                 modify-publisher-name modify-origin-uri modify-mirror-uri))

(def modify-publisher-resource-without-mirror
  (string/format `(publisher/ensure "%s" (publisher/origin "%s"))`
                 modify-publisher-name modify-origin-uri))

(deftest modify-initial
  (test ($< pkg publisher extra.omnios) "\n            Publisher: extra.omnios\n                Alias: \n           Origin URI: https://pkg.omnios.org/r151056/extra/\n        Origin Status: Online\n              SSL Key: None\n             SSL Cert: None\n           Mirror URI: https://us-west.mirror.omnios.org/r151056/extra/\n           Mirror Status: Online\n              SSL Key: None\n             SSL Cert: None\n          Client UUID: 3dec0b2e-4f82-11f1-a156-94c691ae17bc\n      Catalog Updated: Fri May 15 16:05:19 2026\n    Publisher enabled: Yes\n           Properties:\n                       signature-policy = require-signatures\n"))

(deftest modify-idempotent-1
  (test (apply-changes modify-publisher-resource-with-mirror) 0))

(deftest modify-remove-mirror
  (test
    (apply-changes modify-publisher-resource-without-mirror) 1)
  (test ($< pkg publisher extra.omnios)
        "\n            Publisher: extra.omnios\n                Alias: \n           Origin URI: https://pkg.omnios.org/r151056/extra/\n        Origin Status: Online\n              SSL Key: None\n             SSL Cert: None\n          Client UUID: 3dec0b2e-4f82-11f1-a156-94c691ae17bc\n      Catalog Updated: Fri May 15 16:05:19 2026\n    Publisher enabled: Yes\n           Properties:\n                       signature-policy = require-signatures\n"))

(deftest modify-idempotent-2
  (test
    (apply-changes modify-publisher-resource-without-mirror) 0))

(deftest modify-replace-mirror
  (test
    (apply-changes modify-publisher-resource-with-mirror) 1)
  (test ($< pkg publisher extra.omnios)
        "\n            Publisher: extra.omnios\n                Alias: \n           Origin URI: https://pkg.omnios.org/r151056/extra/\n        Origin Status: Online\n              SSL Key: None\n             SSL Cert: None\n           Mirror URI: https://us-west.mirror.omnios.org/r151056/extra/\n           Mirror Status: Online\n              SSL Key: None\n             SSL Cert: None\n          Client UUID: 3dec0b2e-4f82-11f1-a156-94c691ae17bc\n      Catalog Updated: Fri May 15 16:05:19 2026\n    Publisher enabled: Yes\n           Properties:\n                       signature-policy = require-signatures\n"))
