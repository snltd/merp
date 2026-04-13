(use judge)
(use sh)
(use ./lib)

(def cert-file "/etc/ssl/certs/merp-cert.pem")
(def cert-hash-link "/etc/ssl/certs/ce275665.0")

(deftest setup
  (test (absent? cert-hash-link) true)
  (test (absent? cert-file) true))

(deftest noop-creates-nothing
  (test
    (apply-changes-noop
      (resource "system-cert/ensure" "merp-cert.pem"
                :from "certs/cert.pem"))
    1)
  (test (absent? cert-file) true))

(deftest create-from-file
  (test
    (apply-changes
      (resource "system-cert/ensure" "merp-cert.pem"
                :from "certs/cert.pem"))
    1)
  (test (present? cert-file) true)

  (test
    ($< readlink ,cert-hash-link)
    "merp-cert.pem\n"))

(deftest idempotent-ensure
  (test
    (apply-changes
      (resource "system-cert/ensure" "merp-cert.pem"
                :from "certs/cert.pem"))
    0))

(deftest noop-remove-does-nothing
  (test
    (apply-changes-noop (resource "system-cert/remove" "merp-cert.pem")) 1)
  (test (present? cert-hash-link) true)
  (test (present? cert-file) true))

(deftest remove-cert
  (test
    (apply-changes (resource "system-cert/remove" "merp-cert.pem")) 1)
  (test (absent? cert-hash-link) true)
  (test (absent? cert-file) true))

(deftest idempotent-remove
  (test
    (apply-changes (resource "system-cert/remove" "merp-cert.pem")) 0))
