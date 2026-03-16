(use judge)
(use sh)
(use ./lib)
(import ./site)

(def zfs-0 site/zfs-root) # rpool/example
(def zfs-1 (string site/zfs-root "/filesystem"))
(def zfs-2 (string site/zfs-root "/volume"))

(deftest setup
  (test (zfs-exists? zfs-0) false)
  (test (apply-changes (resource "zfs/ensure" zfs-0
                                 :properties {:mountpoint false})) 1)
  (test (zfs-exists? zfs-0) true)
  (test ($< zfs get -Ho value mountpoint ,zfs-0) "none\n"))

(deftest noop-create-does-nothing
  (test
    (apply-changes-noop
      (gurp-example "zfs/ensure-filesystem-with-properties"))
    1)
  (test (zfs-exists? zfs-1) false))

(deftest create-filesystem
  (test
    (apply-changes
      (gurp-example "zfs/ensure-filesystem-with-properties"))
    1)
  (test (zfs-exists? zfs-1) true)
  (test ($< zfs get -Ho value "mountpoint,compression,dedup,devices" ,zfs-1)
        "/example/mountpoint\ngzip-9\non\noff\n"))

(deftest idempotent-1
  (test
    (apply-changes
      (gurp-example "zfs/ensure-filesystem-with-properties"))
    0))

(deftest change-compression-and-dedup
  (test (apply-changes
          (->>
            (gurp-example "zfs/ensure-filesystem-with-properties")
            (string/replace-all "gzip-9" "lz4")
            (string/replace-all "true" "\"off\""))) # we already tested "false"
        1)
  (test ($< zfs get -Ho value "mountpoint,compression,dedup,devices" ,zfs-1)
        "/example/mountpoint\nlz4\noff\noff\n"))

(deftest idempotent-2
  (test (apply-changes
          (->>
            (gurp-example "zfs/ensure-filesystem-with-properties")
            (string/replace-all "gzip-9" "lz4")
            (string/replace-all "true" "\"off\""))) # we already tested "false"
        0))

(deftest create-volume
  (test
    (apply-changes
      (gurp-example "zfs/ensure-volume-with-label"))
    1)
  (test (zfs-exists? zfs-2) true)
  (test ($< zfs get -Ho value "mountpoint,compression,dedup,devices" ,zfs-2)
        "-\non\noff\n-\n"))

(deftest noop-remove-does-nothing
  (test (apply-changes-noop (resource "zfs/remove" zfs-1)) 1)
  (test (zfs-exists? zfs-1) true))

(deftest removal-is-recursive
  (test (apply-changes (resource "zfs/remove" zfs-0)) 1)
  (test (zfs-exists? zfs-0) false)
  (test (zfs-exists? zfs-1) false)
  (test (zfs-exists? zfs-2) false))
