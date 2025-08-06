(import ../globals)
(import ../helpers)

(def major-ver 11)
(def minor-ver 4)
(def svc-name (string/format "svc:/ooce/database/mariadb%d%d" major-ver minor-ver))
(def data-dir "/data")
(def backup-dir "/backup")
(def backup-user "db-backup")
(def db-user "mysql")
(def db-group "mysql")

(role mariadb
      (directory/ensure data-dir
                        :owner db-user
                        :group db-group
                        :mode "0700")

      (directory/ensure "/var/log/mariadb"
                        :owner db-user
                        :group db-group
                        :mode "2750")

      (file/ensure (string/format "/etc/opt/ooce/mariadb-%d.%d/my.cnf"
                                  major-ver minor-ver)
                   :label "my.cnf"
                   :from "mariadb/my.cnf")

      (pkg/ensure (string/format "ooce/database/mariadb-%d%d" major-ver minor-ver))

      (zfs/ensure (zfscat globals/fast-pool "data")
                  :properties {:mountpoint data-dir})

      (svcprop/ensure (string svc-name ":default")
                      :property-groups {:application "application"}
                      :properties {:application/datadir data-dir})

      (svc/ensure svc-name
                  :state "online")

      (section "backup"
               (zfs/ensure (zfscat globals/big-pool "backup")
                           :properties {:mountpoint backup-dir})

               (directory/ensure backup-dir
                                 :owner backup-user
                                 :mode "0700")

               (directory/ensure (pathcat backup-dir "archive")
                                 :owner backup-user
                                 :mode "0700")

               (directory/ensure (pathcat backup-dir "latest")
                                 :owner backup-user
                                 :mode "0700")

               (file/ensure (pathcat globals/site-bin "hot_backup")
                            :from "mariadb/mariadb-hot-backup.sh"
                            :mode "0755")

               (user/ensure backup-user
                            :gecos "mariadb backup user"
                            :primary-group "daemon"
                            :shell "/bin/ksh"
                            :home-dir "/export/home/backup"
                            :uid 700
                            :password-hash "NP")

               (cron/ensure "database-hot-backup"
                            :hour 15
                            :minute 58
                            :user backup-user
                            :command (helpers/site-cron "hot_backup"))))
