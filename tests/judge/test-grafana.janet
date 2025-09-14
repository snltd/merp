(use judge)
(use sh)

(deftest "grafana"
  (test ($< /bin/stat -c "%U:%G %A" /etc/periodic/15min/gurp)
        "root:root -rwxr-xr-x\n")

  (test ($< /usr/bin/md5sum /etc/periodic/15min/gurp)
        "cc831ef75620ca737e4dcd7aa33c66af  /etc/periodic/15min/gurp\n")

  (test ($< /native/usr/sbin/zfs list -Ho "name,mountpoint")
        "rpool\t/rpool\nrpool/test-zone-dataset\tnone\nrpool/test-zone-dataset/data\t/var/lib/grafana\n")

  (test ($< /usr/bin/readlink /etc/runlevels/boot/zfs-mount)
        "/etc/init.d/zfs-mount\n")

  (test ($< /bin/stat -c "%U:%G %A" /etc/init.d/zfs-mount)
        "root:root -rwxr-xr-x\n")

  (test ($? /bin/grep "need net" /etc/init.d/grafana) false)

  (test ($? /bin/grep "127.0.0.1" /etc/conf.d/grafana) false)

  (test ($? /bin/grep "0.0.0.0" /etc/conf.d/grafana) true)

  (test ($< /bin/stat -c "%U:%G %A" /etc/grafana.ini)
        "root:root -rw-r--r--\n"))
