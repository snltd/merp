(use judge)
(use sh)
(use ./lib)

# The various file generation types and comparisongs are well tested in the
# Rust code, so here we'll focus on higher-level behaviour.

(def dir-1 "/example/file")
(def file-1 (pathcat dir-1 "from-content")) # ensure-from-content.janet
(def file-2 (pathcat dir-1 "from-url")) # ensure-from-url-with-checksum.janet
(def file-3 (pathcat dir-1 "from-local-file")) # ensure-from-path
(def file-5 (pathcat dir-1 "test-file-struct-1"))
(def file-6 (pathcat dir-1 "test-file-kvp"))

(deftest setup
  (test (absent? dir-1) true)
  (test (absent? file-1) true)
  (test (apply-changes (resource "directory/ensure" dir-1)) 1)
  (test (present? dir-1) true))

(deftest noop-ensure-does-nothing
  (test (apply-changes-noop (gurp-example "file/ensure-from-content")) 1)
  (test (absent? file-1) true))

(deftest create-from-content
  (test (apply-changes (gurp-example "file/ensure-from-content")) 1)
  (test (present? file-1) true)
  (test (metadata file-1) "sys:root -rw-------\n")
  (test (slurp file-1) @"words\n and\nstuff\n"))

(deftest idempotent-1
  (test (apply-changes (gurp-example "file/ensure-from-content")) 0))

(deftest change-content
  (test (apply-changes
          (->> (gurp-example "file/ensure-from-content")
               (string/replace "stuff" "whatnot")))
        1)
  (test (slurp file-1) @"words\n and\nwhatnot\n")
  (test (metadata file-1) "sys:root -rw-------\n"))

(deftest change-group-and-mode
  (test (apply-changes
          (->> (gurp-example "file/ensure-from-content")
               (string/replace "sys" "daemon")
               (string/replace "0600" "0640")))
        1)
  (test (metadata file-1) "daemon:root -rw-r-----\n"))

(deftest noop-remove-does-nothing
  (test (apply-changes-noop (resource "file/remove" file-1)) 1)
  (test (present? file-1) true))

(deftest remove
  (test (apply-changes (resource "file/remove" file-1)) 1)
  (test (present? file-1) false))

(deftest create-from-url
  (test (apply-changes (gurp-example "file/ensure-from-url-with-checksum")) 1)
  (test (present? file-2) true)
  (test (metadata file-2) "root:root -rw-r--r--\n")
  (test (os/stat file-2 :size) 1297))

(deftest idempotent-2
  (test (apply-changes (gurp-example "file/ensure-from-url-with-checksum")) 0))

(deftest create-from-url-fails-on-checksum
  (test (apply-fails
          (->> (gurp-example "file/ensure-from-url-with-checksum")
               (string/replace "LICENSE.txt" "README.md"))
          "Remote file has incorrect checksum")
        true))

(deftest create-from-url-fails-on-404
  (test (apply-fails
          (->> (gurp-example "file/ensure-from-url-with-checksum")
               (string/replace "LICENSE.txt" "NO-SUCH-THING"))
          "http status: 404")
        true))

(deftest fails-if-parent-is-not-a-dir
  (test (apply-fails
          (resource "file/ensure" "/parent/does-not/exist/file" :content "irrelevant")
          "parent dir does not exist") true))

(deftest fails-if-path-is-relative
  (test (apply-fails
          (resource "file/ensure" "relative-path" :content "irrelevant")
          "path must be absolute") true))

(deftest create-from-file
  (test (apply-changes (gurp-example "file/ensure-from-path")) 1)
  (test (present? file-3) true)
  (test (metadata file-3) "root:daemon -rwsr-xr-x\n")
  (test (string/find "line1" (slurp file-3)) 158)
  (test (string/find "line2" (slurp file-3)) 164))

(deftest idempotent-3
  (test (apply-changes (gurp-example "file/ensure-from-path")) 0))

(deftest ignore-line-when-comparing
  (test
    (apply-changes-noop
      (resource "file/ensure" file-3
                :group "daemon"
                :mode "4755"
                :content (string/replace "1772718091" "1772712000"
                                         (slurp "files/file-dir/example"))))
    1)

  (test
    (apply-changes
      (resource "file/ensure" file-3
                :group "daemon"
                :mode "4755"
                :ignore-pattern "^serial"
                :content (string/replace "1772718091" "1772712000"
                                         (slurp "files/file-dir/example"))))
    0))

(deftest create-file-from-struct
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
  (test (slurp backup-file-5) @"a: 1\nb: 2\nc: string\nd:\n- 1\n- 2\n- 3\n- 4\n"))

(deftest file-cannot-clobber-directory
  (def blocker (pathcat dir-1 "blocker"))
  (test (apply-changes (resource "directory/ensure" blocker)) 1)
  (test (present? blocker) true)
  (test (os/stat blocker :mode) :directory)
  (test (apply-fails
          (resource "file/ensure" blocker :content "abc")
          "blocker exists and is not a file") true)
  (test (present? blocker) true)
  (test (os/stat blocker :mode) :directory))

(deftest cleanup
  (test (apply-changes (resource "directory/remove" dir-1)) 1)
  (test (absent? dir-1) true))
