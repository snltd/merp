(import ../site)

(def delegated-dataset "rpool/merp-tests/metrics-data")

(role victoriametrics
      (zfs/ensure (zfscat  delegated-dataset "metrics")
                  :properties {:mountpoint "/var/opt/ooce/victoriametrics"})

      (pkg/ensure "ooce/database/victoriametrics")

      (svc/ensure "/ooce/application/victoriametrics:victoria-metrics"
                  :state "online"))
