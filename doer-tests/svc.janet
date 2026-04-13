(use judge)
(use sh)
(use ./lib)
(import ./site)

(def svc-1 "svc:/system/name-service-cache:default")
(def trigger-file "/tmp/trigger")

(deftest service-is-running
  (apply-changes (resource "svc/ensure" svc-1 :state "online"))
  (test ($< svcs -Hostate ,svc-1) "online\n"))

(deftest idempotent-1
  (test (apply-changes (resource "svc/ensure" svc-1 :state "online")) 0)
  (test ($< svcs -Hostate ,svc-1) "online\n"))

(deftest noop-does-nothing
  (test (apply-changes-noop (resource "svc/ensure" svc-1 :state "disabled")) 1)
  (test ($< svcs -Hostate ,svc-1) "online\n"))

(deftest restarted-by
  (def original-start-time ($< svcs -vHo stime ,svc-1))
  (def unique-content (quoted (os/time)))
  (test
    (apply-changes
      (cat
        (resource "file/ensure" trigger-file
                  :content unique-content
                  :label "trigger")
        (resource "svc/ensure" svc-1
                  :state "online"
                  :restarted-by @["/NO-ROLE/file/trigger"])))
    2)
  (os/sleep 1)
  (def new-start-time ($< svcs -vHo stime ,svc-1))
  (test (= original-start-time new-start-time) false))

(deftest online-clears-state
  ($ /usr/sbin/svcadm mark maintenance ,svc-1)
  (os/sleep 1)
  (test ($< svcs -Hostate ,svc-1) "maintenance\n")
  (test (apply-changes (resource "svc/ensure" svc-1 :state "online")) 1)
  (os/sleep 1)
  (test ($< svcs -Hostate ,svc-1) "online\n"))

(deftest offline-svc
  (test (apply-changes (resource "svc/ensure" svc-1 :state "disabled")) 1)
  (os/sleep 1)
  (test ($< svcs -Hostate ,svc-1) "disabled\n"))

(deftest online-svc
  (test (apply-changes (resource "svc/ensure" svc-1 :state "online")) 1)
  (os/sleep 1)
  (test ($< svcs -Hostate ,svc-1) "online\n"))
