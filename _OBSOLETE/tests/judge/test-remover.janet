(use sh)
(use judge)

(deftest "directory-remove"
  (test (os/stat "/var/krb5") nil)
  (test (os/stat "/var/yp/binding") nil))

(deftest "file-remove"
  (test (truthy? (os/stat "/etc/passwd")) true) # Protected file
  (test (os/stat "/var/yp/alises") nil)
  (test (os/stat "/var/yp/nicknames") nil))

(deftest "group-remove"
  (test ($? grep -q ^daemon: /etc/group) true)
  (test ($? grep ^gdm: /etc/group) false)
  (test ($? grep ^upnp: /etc/group) false))

(deftest "pkg-remove"
  (test ($? pkg list compress/unzip :> [stderr :null]) false))

(deftest "publisher-remove"
  (test ($? pkg publisher |grep extra.omnios) false))

(deftest "smf-remove"
  (test ($? svcs svc:/network/ssh:default) false))

(deftest "symlink-remove"
  (test (os/stat "/var/ld/64") nil))

(deftest "user-remove"
  (test ($? grep -q ^sys: /etc/passwd) true)  # Protected user
  (test ($? grep ^zfssnap: /etc/passwd) false)
  (test ($? grep ^upnp: /etc/passwd) false))
