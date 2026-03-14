(use judge)
(use sh)
(use ./lib)

(def user-1 "gurpuser")
(def grep-pattern (string/format "^%s:" user-1))

(deftest setup
  (test (user-exists? user-1) false))

(deftest noop-does-nothing
  (test (apply-changes-noop (gurp-example "user/ensure-user-gurpuser")) 1)
  (test (user-exists? user-1) false))

(deftest create-user
  (test (apply-changes (gurp-example "user/ensure-user-gurpuser")) 1)
  (test (user-exists? user-1) true)
  (def shadow-pattern (string/format "^%s:" user-1))
  (test ($< grep ,grep-pattern /etc/shadow)
        "gurpuser:w0934cm-4i5c-42u5cn492hrc97h234ui:::::::\n"))

(deftest idempotent-1
  (test (apply-changes (gurp-example "user/ensure-user-gurpuser")) 0)
  (test (user-exists? user-1) true))

(deftest modify-hash-and-shell-noop-does-nothing
  (test
    (apply-changes-noop
      (->> (gurp-example "user/ensure-user-gurpuser")
           (string/replace "/bin/zsh" "/bin/false")
           (string/replace "w0934cm-4i5c-42u5cn492hrc97h234ui" "*LK")))
    1))

(deftest modify-hash-and-shell
  (test
    (apply-changes
      (->> (gurp-example "user/ensure-user-gurpuser")
           (string/replace "/bin/zsh" "/bin/false")
           (string/replace "w0934cm-4i5c-42u5cn492hrc97h234ui" "*LK*")))
    2)
  (test ($< grep ,grep-pattern /etc/shadow)
        "gurpuser:*LK*:::::::\n")
  (test ($< grep ,grep-pattern /etc/passwd)
        "gurpuser:x:1264:14:Gurp Managed User:/home/gurpuser:/bin/false\n"))

(deftest remove-noop-does-nothing
  (test (apply-changes-noop (resource "user/remove" user-1)) 1)
  (test (user-exists? user-1) true))

(deftest remove-user
  (test (apply-changes (resource "user/remove" user-1)) 1)
  (test (user-exists? user-1) false))

(deftest idempotent-2
  (test (apply-changes (resource "user/remove" user-1)) 0)
  (test (user-exists? user-1) false))
