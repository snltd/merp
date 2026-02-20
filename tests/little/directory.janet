(use judge)
(use sh)
(use ./lib)

(def dir-1 "/tmp/merp/test-dir")
(def dir-2 "/tmp/merp/test-dir/inner")

(test (absent? dir-1) true)
(test (absent? dir-2) true)

# Noop should not make a directory
(test (apply-changes-noop (resource "directory/ensure" dir-1)) 1)
(test (absent? dir-1) true)

# Defaults will make directory root:root 0755
(test (apply-changes (resource "directory/ensure" dir-1)) 1)
(test (metadata dir-1) "root:root drwxr-xr-x\n")

# Change owner and mode. Noop should do nothing, and re-apply should have no
# effect
(def dir-spec (resource "directory/ensure" dir-1 :owner "adm" :mode "0700"))
(test (apply-changes-noop dir-spec) 1)
(test (metadata dir-1) "root:root drwxr-xr-x\n")
(test (apply-changes dir-spec) 1)
(test (metadata dir-1) "adm:root drwx------\n")
(test (apply-changes dir-spec) 0)
(test (metadata dir-1) "adm:root drwx------\n")

# Make a second directory inside the first, fully specced
(test
  (apply-changes
    (resource "directory/ensure" dir-2 :owner "lp" :group "lp" :mode "2700")) 1)

(test (metadata dir-2) "lp:lp drwx--S---\n")

# A noop remove doesn't remove
(test (apply-changes-noop (resource "directory/remove" dir-1)) 1)
(test (present? dir-1) true)
(test (present? dir-2) true)

# The removal of dir-1 will remove dir-2, which is inside it
(test (apply-changes (resource "directory/remove" dir-1)) 1)
(test (absent? dir-1) true)
(test (absent? dir-2) true)

# This will be left behind
(test (present? "/tmp/merp") true)

# Tidy up
(test (apply-changes (resource "directory/remove" "/tmp/merp")) 1)
(test (absent? "/tmp/merp") true)
