(use judge)
(use sh)
(use ./lib)
(import ./site)

(def guinea-pig "svc:/system/name-service-cache:default")
(def trigger-file "/tmp/trigger")

(deftest setup
  (apply-changes (resource "svc/ensure" guinea-pig :state "online"))
  (test ($< svcs -Hostate ,guinea-pig) "online\n"))

(deftest idempotent-1
  (test (apply-changes (resource "svc/ensure" guinea-pig :state "online")) 0)
  (test ($< svcs -Hostate ,guinea-pig) "online\n"))

(deftest noop-does-nothing
  (test (apply-changes-noop (resource "svc/ensure" guinea-pig :state "disabled")) 1)
  (test ($< svcs -Hostate ,guinea-pig) "online\n"))

(deftest restarted-by
  (def original-start-time ($< svcs -vHo stime ,guinea-pig))
  (def unique-content (quoted (os/time)))
  (test
    (apply-changes
      (cat
        (resource "file/ensure" trigger-file
                  :content unique-content
                  :label "trigger")
        (resource "svc/ensure" guinea-pig
                  :state "online"
                  :restarted-by @["/NO-ROLE/file/trigger"])))
    2)
  (def new-start-time ($< svcs -vHo stime ,guinea-pig))
  (test (= original-start-time new-start-time) false))

(deftest online-clears-state
  ($ svcadm mark maintenance ,guinea-pig)
  (os/sleep 1)
  (test ($< svcs -Hostate ,guinea-pig) "maintenance\n")
  (test (apply-changes (resource "svc/ensure" guinea-pig :state "online")) 1)
  (os/sleep 1)
  (test ($< svcs -Hostate ,guinea-pig) "online\n"))

(deftest offline-svc
  (test (apply-changes (resource "svc/ensure" guinea-pig :state "disabled")) 1)
  (os/sleep 1)
  (test ($< svcs -Hostate ,guinea-pig) "disabled\n"))

(deftest online-svc
  (test (apply-changes (resource "svc/ensure" guinea-pig :state "online")) 1)
  (os/sleep 1)
  (test ($< svcs -Hostate ,guinea-pig) "online\n"))
