(import ../site)

(role victoriametrics
      (zfs/ensure (zfscat site/zfs-root "zone" "metrics"))

      (zfs/ensure (zfscat site/zfs-root "zone" "metrics" "data")
                  :properties {:mountpoint "/var/opt/ooce/victoriametrics"})

      (pkg/ensure "ooce/database/victoriametrics")

      (svc/ensure "/ooce/application/victoriametrics:victoria-metrics"
                  :state "online"))
