(use judge)
(use sh)
(use ./lib)

(def dir-1 "/tmp/merp/test-dir")
(def file-1 (string dir-1 "/test-file-content"))
(def file-2 (string dir-1 "/test-file-https"))
(def file-4 (string dir-1 "/test-file-https-fails")) # will never be created
(def file-3 (string dir-1 "/test-file-from"))
(def file-5 (string dir-1 "/test-file-struct-1"))
(def file-6 (string dir-1 "/test-file-kvp"))

(test (absent? dir-1) true)
(test (absent? file-1) true)

# Directory for test files
(test (apply-changes (resource "directory/ensure" dir-1)) 1)

(def file-1-spec-1 (resource "file/ensure" file-1
                             :owner "bin"
                             :group "bin"
                             :mode "0600"
                             :content "contents of file"))

# Noop should not make a file
(test (apply-changes-noop file-1-spec-1) 1)
(test (absent? file-1) true)

# Second apply should make no change
(test (apply-changes file-1-spec-1) 1)
(test (present? file-1) true)
(test (metadata file-1) "bin:bin -rw-------\n")
(test (slurp file-1) @"contents of file")
(test (apply-changes file-1-spec-1) 0)
(test (present? file-1) true)
(test (metadata file-1) "bin:bin -rw-------\n")
(test (slurp file-1) @"contents of file")

# Change the group and mode
(test
  (apply-changes (resource "file/ensure" file-1
                           :owner "bin"
                           :group "daemon"
                           :mode "0640"
                           :content "timestamp\nline2\nline3"))
  1)
(test (slurp file-1) @"timestamp\nline2\nline3")
(test (metadata file-1) "bin:daemon -rw-r-----\n")

# Change the owner and the content
(test
  (apply-changes (resource "file/ensure" file-1
                           :owner "daemon"
                           :group "daemon"
                           :mode "0640"
                           :content "timestamp\nline4\nline5"))
  1)
(test (slurp file-1) @"timestamp\nline4\nline5")
(test (metadata file-1) "daemon:daemon -rw-r-----\n")

# When only the "timestamp" line changes, we don't need to rewrite the file
(test
  (apply-changes (resource "file/ensure" file-1
                           :owner "daemon"
                           :group "daemon"
                           :mode "0640"
                           :ignore-pattern ".*stamp$"
                           :content "new-timestamp\nline4\nline5"))
  0)
(test (slurp file-1) @"timestamp\nline4\nline5")

# Noop remove should do nothing
(test (apply-changes-noop (resource "file/remove" file-1)) 1)
(test (present? file-1) true)

# Remove it
(test (apply-changes (resource "file/remove" file-1)) 1)
(test (absent? file-1) true)

# Make a new file from an https source
(test
  (apply-changes (resource "file/ensure" file-2
                           :owner "uucp"
                           :group "uucp"
                           :mode "0444"
                           :with-checksum "561a47aa1d1bfc3a95ce45345639f9ce2d9ad332b05cfe5da74ad77f2842ee16"
                           :from-url "https://raw.githubusercontent.com/snltd/gurp/refs/heads/main/LICENSE.txt"))
  1)
(test (present? file-2) true)
(test (metadata file-2) "uucp:uucp -r--r--r--\n")
(test (string/find "All rights" (slurp file-2)) 33)

# Fail because an https file has the wrong checksum
(test
  (apply-fails (resource "file/ensure" file-4
                         :with-checksum "000000000000000000000000000000000000000000000000000000000000000"
                         :from-url "https://raw.githubusercontent.com/snltd/gurp/refs/heads/main/LICENSE.txt")

               "Remote file has incorrect checksum")
  true)
(test (absent? file-4) true)

# Fail because the directory doesn't exist
(test
  (apply-fails
    (resource "file/ensure" "/cannot/make/this/file" :content "irrelevant")
    "No such file or directory")
  true)

# Make a new file from an existing one
(test
  (apply-changes (resource "file/ensure" file-3
                           :owner "lp"
                           :group "lp"
                           :mode "4755"
                           :from "/etc/profile"))
  1)
(test (present? file-3) true)
(test (metadata file-3) "lp:lp -rwsr-xr-x\n")
(test (string/find "CDDL HEADER START" (slurp file-3)) 4)

# Create a file with the following struct as JSON
(def struct-1 {:a 1 :b 2 :c "string" :d @[1 2 3 4]})
(def backup-file-5 (string file-5 ".bak"))
(test
  (apply-changes (resource "file/ensure" file-5
                           :from-struct struct-1
                           :to-format "json"
                           :backup-suffix "bak"))
  1)
(test (present? file-5) true)
(test
  (slurp file-5)
  @"{\n  \"a\": 1,\n  \"b\": 2,\n  \"c\": \"string\",\n  \"d\": [\n    1,\n    2,\n    3,\n    4\n  ]\n}")
# No backup file, because this is a new file
(test (absent? backup-file-5) true)

# Replace it with the same struct as YAML. This time there is a backup
(test
  (apply-changes (resource "file/ensure" file-5
                           :from-struct struct-1
                           :to-format "yaml"
                           :backup-suffix "bak"))
  1)
(test (present? file-5) true)
(test (slurp file-5) @"a: 1\nb: 2\nc: string\nd:\n- 1\n- 2\n- 3\n- 4\n")
(test (present? backup-file-5) true)
# Backup files are 0400, owned by root:root
(test (metadata backup-file-5) "root:root -r--------\n")
(test
  (slurp backup-file-5)
  @"{\n  \"a\": 1,\n  \"b\": 2,\n  \"c\": \"string\",\n  \"d\": [\n    1,\n    2,\n    3,\n    4\n  ]\n}")

# now TOML
(test
  (apply-changes (resource "file/ensure" file-5
                           :from-struct struct-1
                           :to-format "toml"
                           :backup-suffix "bak"))
  1)
(test (present? file-5) true)
(test (present? backup-file-5) true)
(test (slurp file-5) @"a = 1\nb = 2\nc = \"string\"\nd = [1, 2, 3, 4]\n")
(test (metadata backup-file-5) "root:root -r--------\n")
(test (slurp backup-file-5) @"a: 1\nb: 2\nc: string\nd:\n- 1\n- 2\n- 3\n- 4\n")

# A file cannot clobber a directory
(def blocker (string dir-1 "/blocker"))
(test (apply-changes (resource "directory/ensure" blocker)) 1)
(test (present? blocker) true)
(test (os/stat blocker :mode) :directory)
(test (apply-fails
        (resource "file/ensure" blocker :content "abc")
        "/tmp/merp/test-dir/blocker exists and is not a file") true)
(test (present? blocker) true)
(test (os/stat blocker :mode) :directory)

# Tidy up
(test (apply-changes (resource "directory/remove" dir-1)) 1)
