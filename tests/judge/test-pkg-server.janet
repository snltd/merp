(use sh)
(use judge)

(deftest "minidlna server zone"
  (ev/sleep 4)

  (test ($< /bin/stat -c "%U:%G %A %s" /opt/site/lib/smf/method/sysdef-repo-setup.sh)
        "root:root -rwxr-xr-x 180\n")

  (test ($< /bin/stat -c "%U:%G %A %s" /opt/site/lib/smf/manifest/gurp-pkg-setup.xml)
        "root:root -rw-r--r-- 1228\n")

  (test ($< /bin/stat -c "%U:%G" /var/log/pkg)
        "pkg5srv:daemon\n")

  (test ($< /bin/stat -c "%U:%G" /var/log/pkg/server)
        "pkg5srv:daemon\n")

  (test ($< /bin/stat -c "%U:%G" /repo)
        "pkg5srv:pkg5srv\n")

  (test ($< /bin/grep ^pkg5srv:NP: /etc/shadow)
        "pkg5srv:NP:20248::::::\n")

  (test ($< /bin/stat -c "%U:%G" /repo/pkg5.repository)
        "root:root\n")

  (test ($< /bin/stat -c "%U:%G %A %s" /opt/site/lib/smf/manifest/gurp-pkg-setup.xml)
        "root:root -rw-r--r-- 1228\n")

  (test ($< /bin/crontab -l pkg5srv)
        "# gurp managed ID /pkg-server/cron/refresh-pkg-repo\n*/5 * * * * /opt/site/bin/refresh-pkg-repo > /var/log/cron_jobs/refresh-pkg-repo.log 2>&1\n")

  (test ($< /bin/stat -c "%U:%G" /opt/site/bin/refresh-pkg-repo)
        "root:root\n")

  (test ($< /bin/cat /opt/site/bin/refresh-pkg-repo)
        "#!/bin/ksh -e\n\nREPO_NAME=\"sysdef\"\nREPO_ROOT=\"/repo\"\nREPO_SVC=\"svc:/application/pkg/server:sysdef\"\nMARKER=\"/var/run/refresh_repo\"\n\ntest -f $MARKER || /bin/touch $MARKER\n\nif [[ $1 != \"-f\" ]]\nthen\n  if ! test \"${REPO_ROOT}/publisher/${REPO_NAME}/pkg\" -nt $MARKER\n  then\n    /bin/touch $MARKER\n    exit 0\n  fi\nfi\n\n/usr/bin/pkgrepo refresh -s $REPO_ROOT refresh \n# /usr/sbin/svcadm refresh $REPO_SVC\n# /usr/sbin/svcadm restart $REPO_SVC\n/bin/touch $MARKER")

  (test ($< /bin/svcs -Ho state svc:/sysdef/application/pkg-setup:default)
        "online\n")

  (test ($< /bin/svcs -Ho state svc:/application/pkg/server:sysdef)
        "online\n"))
