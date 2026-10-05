(import ../site)

(def delegated-dataset "rpool/merp-tests/telemetry-data")

(role telemetry
(section metrics
      (zfs/ensure (zfscat delegated-dataset "metrics")
                  :properties {:mountpoint "/var/opt/ooce/victoriametrics"})

      (pkg/ensure "ooce/database/victoriametrics")

      (svc/ensure "/ooce/application/victoriametrics:victoria-metrics"
                  :state "online"))

            
            (section logs
      (zfs/ensure (zfscat delegated-dataset "logs")
                  :properties {:mountpoint "/var/opt/ooce/victorialogs"})

      (pkg/ensure "ooce/database/victorialogs")

      (svc/ensure "/ooce/database/victorialogs:victoria-logs"
                  :state "online"))
            )
