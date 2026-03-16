(use judge)
(use sh)
(use ./lib)
(import ./site)

(def dir-1 "/app")
(def user-1 "appuser")
(def svc-1 "snltd/example")
(def manifest-path "/opt/site/lib/smf/manifest/gurp-example.xml")

(deftest setup
  (test (apply-changes
          (cat
            (resource "directory/ensure" dir-1)
            (resource "file/ensure" (string dir-1 "/method.sh")
                      :mode "0755"
                      :content "python3 -m http.server $(svcprop -p application/port snltd/example:default)\n")
            (resource "file/ensure" (string dir-1 "/data")
                      :mode "0755"
                      :content "hello")
            (resource "user/ensure" user-1
                      :uid 8888
                      :home-dir dir-1
                      :gecos "merp test app user"
                      :primary-group "daemon"
                      :shell "/bin/false")
            (gurp-example "smf/ensure-daemon-with-privs")))
        5)
  (os/sleep 1) # Give the service time to come up
  (test (present? dir-1) true)
  (test (user-exists? user-1) true)
  (test (service-exists? svc-1) true)
  (test ($< svcs -Ho state ,svc-1) "online\n")
  (test ($< curl --connect-timeout=1 -s http://localhost:8080/data) "hello"))

# We get two changes here because Gurp will create the property group
(deftest change-property-noop-does-nothing
  (test (apply-changes-noop
          (resource "svcprop/ensure" (string svc-1 ":default")
                    :on-change "restart"
                    :property-groups {:application "application"}
                    :properties {:application/port 9999})) 2)
  (os/sleep 2)
  (test ($< curl --connect-timeout=1 -s http://localhost:8080/data) "hello"))

(deftest change-property
  (test (apply-changes
          (resource "svcprop/ensure" (string svc-1 ":default")
                    :on-change "restart"
                    :property-groups {:application "application"}
                    :properties {:application/port 9999})) 2)
  (os/sleep 2)
  (test ($< curl --connect-timeout=1 -s http://localhost:9999/data) "hello"))

(deftest idempotent-1
  (test (apply-changes
          (resource "svcprop/ensure" (string svc-1 ":default")
                    :on-change "restart"
                    :property-groups {:application "application"}
                    :properties {:application/port 9999})) 0))

(deftest remove-property-which-does-not-exist
  (test (apply-changes
          (resource "svcprop/remove" svc-1
                    :properties @["nosuch/thing"])) 0))

(deftest remove-property
  (test ($< svcprop -p other_group/other_prop ,svc-1) "\\\"abc123\\\"\n")
  (test (apply-changes
          (resource "svcprop/remove" svc-1
                    :properties @["other_group/other_prop"])) 1)
  (test ($? svcprop -p other_group/other_prop ,svc-1 :> [stderr :null]) false))

(deftest cleanup
  (test (apply-changes
          (cat
            (resource "smf/remove" svc-1)
            (resource "file/remove" manifest-path)
            (resource "directory/remove" dir-1)
            (resource "user/remove" user-1)))
        4)
  (test (absent? dir-1) true)
  (test (service-exists? svc-1) false)
  (test (user-exists? user-1) false))
