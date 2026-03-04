(use judge)
(use sh)
(use ./lib)
(import ./site)

(def original-scheduler-class
  (->> ($< dispadmin -d) (string/split "\t") (first)))
(def new-scheduler-class
  (if (= "FSS" original-scheduler-class) "FX" "FSS"))

(comment
(deftest scheduler-class-noop-does-nothing
  (test (apply-changes-noop
          (resource "misc/ensure" :scheduler new-scheduler-class)) 1)
  (test (string/has-prefix? original-scheduler-class ($< dispadmin -d)) true))

(deftest scheduler-class-change
  (test (apply-changes
          (resource "misc/ensure" :scheduler new-scheduler-class)) 1)
  (test (string/has-prefix? new-scheduler-class ($< dispadmin -d)) true))

(deftest scheduler-class-change-idempotent
  (test (apply-changes
          (resource "misc/ensure" :scheduler new-scheduler-class)) 0)
  (test (string/has-prefix? new-scheduler-class ($< dispadmin -d)) true))

(deftest scheduler-class-reset
  (test (apply-changes
          (resource "misc/ensure" :scheduler original-scheduler-class)) 1)
  (test (string/has-prefix? original-scheduler-class ($< dispadmin -d)) true))
  )

# TODO nfs domain and smbuser

# (deftest nfs-domain
#   (test (string/trim ($< sharectl get -p nfsmapid_domain nfs))))
