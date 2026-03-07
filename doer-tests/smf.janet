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
                      :content "python3 -m http.server")
            (resource "file/ensure" (string dir-1 "/data")
                      :mode "0755"
                      :content "hello")
            (resource "user/ensure" user-1
                      :uid 8888
                      :home-dir dir-1
                      :gecos "merp test app user"
                      :primary-group "daemon"
                      :shell "/bin/false"))) 4)
  (test (present? dir-1) true)
  (test (user-exists? user-1) true)
  (test (service-exists? svc-1) false))

(deftest noop-does-nothing
  (test (apply-changes-noop (gurp-example "smf/ensure-daemon-with-privs")) 1)
  (test (service-exists? svc-1) false))

(deftest create-service
  (test (apply-changes (gurp-example "smf/ensure-daemon-with-privs")) 1)
  (os/sleep 5)
  (test (service-exists? svc-1) true)
  (test ($< svcs -Ho state ,svc-1) "online\n")
  (test ($< curl --connect-timeout=1 -s http://localhost:8000/data) "hello"))

(deftest cleanup
  (test (apply-changes
          (cat
            (resource "smf/remove" svc-1)
            (resource "file/remove" manifest-path)
            (resource "directory/remove" dir-1)
            (resource "user/remove" user-1))) 4)
  (test (absent? dir-1) true)
  (test (user-exists? user-1) false))

