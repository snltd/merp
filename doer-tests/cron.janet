(use judge)
(use sh)
(use ./lib)

(deftest noop-does-nothing
  (test (apply-changes-noop (gurp-example "cron/ensure-print-cron-job")) 1)
  (test ($? crontab -l -u "lp" :> [stderr :null]) false))

(deftest create-jobs
  (test
    (apply-changes
      (cat (gurp-example "cron/ensure-root-cron-job")
           (gurp-example "cron/ensure-print-cron-job")))
    2)
  (test ($< crontab -l -u "root" |tail -2)
        "# gurp managed ID /NO-ROLE/cron/root-cron-job\n6 * * * * /bin/thing arg1 arg2 arg3\n")
  (test ($< crontab -l -u "lp")
        "# gurp managed ID /NO-ROLE/cron/print-cron-job\n6 4 * * 5 /bin/thing arg1 arg2 arg3\n"))

(deftest modify-job
  (test (apply-changes
          (resource
            "cron/ensure" "root-cron-job"
            :minute 33
            :day-of-week 2
            :command "/bin/thing arg1 arg3")) 1)
  (test ($< crontab -l -u "root" |tail -2)
        "# gurp managed ID /NO-ROLE/cron/root-cron-job\n33 * * * 2 /bin/thing arg1 arg3\n"))

(deftest remove-noop-does-nothing
  (test
    (apply-changes-noop
      (resource "cron/remove" "print-cron-job" :user "lp"))
    1)
  (test ($< crontab -l -u "lp")
        "# gurp managed ID /NO-ROLE/cron/print-cron-job\n6 4 * * 5 /bin/thing arg1 arg2 arg3\n"))

(deftest cleanup
  (test (apply-changes
          (cat (resource "cron/remove" "print-cron-job" :user "lp")
               (resource "cron/remove" "root-cron-job")))
        2)
  (test ($? crontab -l -u "lp" :> [stderr :null]) false)
  (test ($? crontab -l -u "root" |grep "root-cron-job") false))
