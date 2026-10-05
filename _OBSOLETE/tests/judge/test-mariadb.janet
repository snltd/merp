(use judge)
(use sh)

(deftest "mariadb"
  (ev/sleep 20)

  (test ($< /bin/pkg list -Ho name |grep mariadb)
        "ooce/database/mariadb-114\nooce/database/mariadb-common\nooce/library/mariadb-114\n")

  (test ($< /bin/svcs -Ho state svc:/ooce/database/mariadb114:default)
        "online\n")

  (test ($< /bin/stat -c "%U:%G %A" /data)
        "mysql:mysql drwx------\n")

  (test ($< /bin/stat -c "%U:%G %A" /data/mysql)
        "mysql:mysql drwx------\n")

  (test ($< /bin/stat -c "%U:%G %A" /var/log/mariadb)
        "mysql:mysql drwxr-s---\n")

  (test ($< /bin/stat -c "%U:%G %A %s" /etc/opt/ooce/mariadb-11.4/my.cnf)
        "root:root -rw-r--r-- 547\n")

  (test ($< zfs list -Ho "name,mountpoint" rpool/test-zone-dataset/data)
        "rpool/test-zone-dataset/data\t/data\n")

  (test ($< svcprop -p application/datadir svc:/ooce/database/mariadb114:default)
        "/data\n")

  (test ($< grep ^db-backup: /etc/passwd)
        "db-backup:x:700:12:mariadb backup user:/export/home/backup:/bin/ksh\n")

  (test ($< crontab -l -u db-backup)
        "# gurp managed ID /mariadb/cron/database-hot-backup\n58 15 * * * /opt/site/bin/hot_backup > /var/log/cron_jobs/hot_backup.log 2>&1\n")

  (test ($< /bin/stat -c "%U:%G %A" /backup)
        "db-backup:root drwx------\n")

  (test ($< /bin/stat -c "%U:%G %A" /backup/archive)
        "db-backup:root drwx------\n")

  (test ($< /bin/stat -c "%U:%G %A" /backup/latest)
        "db-backup:root drwx------\n")

  (test ($< /bin/stat -c "%U:%G %A" /opt/site/bin/hot_backup)
        "root:root -rwxr-xr-x\n")

  (test ($< /opt/ooce/bin/mysql -u root mysql -e "show databases;")
        "Database\ninformation_schema\nmysql\nperformance_schema\nsys\ntest\n")

  (test ($< zfs list -Ho "name,mountpoint" rpool/test-zone-dataset/backup)
        "rpool/test-zone-dataset/backup\t/backup\n"))
