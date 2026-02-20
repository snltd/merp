(use judge)
(use sh)
(use ./lib)

(def job-1 "merp-job-1")
(def job-2 "merp-job-2")
(def lps-crontab "/var/spool/cron/crontabs/lp")

(def spec-1
  (resource "cron/ensure" job-1
            :minute 6
            :hour 4
            :day-of-month "*"
            :day-of-week 5
            :user "lp"
            :command "/bin/print-task arg >/dev/null 2>&1"))

(def spec-2-1
  (resource "cron/ensure" job-2
            :day-of-week 0
            :user "lp"
            :command "/bin/batch-job"))

(def spec-2-2
  (resource "cron/ensure" job-2
            :day-of-week 1
            :user "lp"
            :command "/bin/batch-job"))

# lp doesn't normally have a crontab
(test (absent? lps-crontab) true)

# Noop does nothing
(test (apply-changes-noop spec-1) 1)
(test (absent? lps-crontab) true)

# Create cron job 1
(test (apply-changes spec-1) 1)
(test (present? lps-crontab) true)
(test ($< crontab -l -u lp) "# gurp managed ID /NO-ROLE/cron/merp-job-1\n6 4 * * 5 /bin/print-task arg >/dev/null 2>&1\n")

# Create cron job 2
(test (apply-changes spec-2-1) 1)
(test (present? lps-crontab) true)
(test ($< crontab -l -u lp) "# gurp managed ID /NO-ROLE/cron/merp-job-1\n6 4 * * 5 /bin/print-task arg >/dev/null 2>&1\n# gurp managed ID /NO-ROLE/cron/merp-job-2\n* * * * 0 /bin/batch-job\n")

# Modify cron job 2
(test (apply-changes spec-2-2) 1)
(test ($< crontab -l -u lp) "# gurp managed ID /NO-ROLE/cron/merp-job-1\n6 4 * * 5 /bin/print-task arg >/dev/null 2>&1\n# gurp managed ID /NO-ROLE/cron/merp-job-2\n* * * * 1 /bin/batch-job\n")
(test (apply-changes spec-2-2) 0)

# Remove noop does nothing
(test (apply-changes-noop (resource "cron/remove" job-1 :user "lp")) 1)
(test (present? lps-crontab) true)
(test ($< crontab -l -u lp) "# gurp managed ID /NO-ROLE/cron/merp-job-1\n6 4 * * 5 /bin/print-task arg >/dev/null 2>&1\n# gurp managed ID /NO-ROLE/cron/merp-job-2\n* * * * 1 /bin/batch-job\n")

# Remove cron job 2
(test (apply-changes (resource "cron/remove" job-2 :user "lp")) 1)
(test (absent? lps-crontab) false)
(test ($< crontab -l -u lp) "# gurp managed ID /NO-ROLE/cron/merp-job-1\n6 4 * * 5 /bin/print-task arg >/dev/null 2>&1\n")

# Remove cron job 1
(test (apply-changes (resource "cron/remove" job-1 :user "lp")) 1)
(test (absent? lps-crontab) true)
