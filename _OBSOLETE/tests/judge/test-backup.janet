(use sh)
(use judge)

(deftest "test-backup"
  (test ($< grep ^backup /etc/passwd)
        "backup:x:200:12:Backup user:/export/home/backup:/bin/ksh\n")

  (test ($< grep ^backup /etc/shadow)
    "backup:NP:::::::\n")

  (test ($< zfs list -Honame |grep pool/test-zone-dataset)
        "rpool/test-zone-dataset\nrpool/test-zone-dataset/backup\nrpool/test-zone-dataset/kronos\nrpool/test-zone-dataset/lobster\nrpool/test-zone-dataset/user\n")

  (test ($< /bin/stat -c "%U:%G %A" /export/home/backup)
        "root:root drwxr-xr-x\n")

  (test ($< crontab -l -u backup)
        "# gurp managed ID /backup/cron/kronos-backup-script\n26 * * * * /opt/site/bin/backup_kronos > /var/log/cron_jobs/backup_kronos.log 2>&1\n# gurp managed ID /backup/cron/Report Kronos backup files to Wavefront\n25 * * * * /opt/site/bin/backup_kronos_metrics > /var/log/cron_jobs/backup_kronos_metrics.log 2>&1\n")

  (test ($< /bin/stat -c "%U:%G %A" /export/home/backup)
        "root:root drwxr-xr-x\n")

  (test ($< /bin/stat -c "%U:%G %A" /export/home/backup)
        "root:root drwxr-xr-x\n")

  (test ($< /bin/stat -c "%U:%G %A" /export/backup/lobster)
        "backup:daemon drwx------\n")

  (test ($< /bin/stat -c "%U:%G %A" /export/backup/kronos)
        "backup:daemon drwx------\n")

  (test ($< /bin/stat -c "%U:%G %A %s" /opt/site/bin/backup_kronos)
        "root:root -rwxr-xr-x 477\n")

  (test ($< /bin/stat -c "%U:%G %A %s" /opt/site/bin/backup_kronos_metrics)
        "root:root -rwxr-xr-x 337\n"))
