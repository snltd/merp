(use sh)
(use judge)

(deftest "pkg server zone"
  (ev/sleep 4)

  (test ($< /bin/stat -c "%U:%G %A %s" /opt/site/lib/smf/manifest/gurp-sysdef_application_sysdef-setup.xml)
        "root:root -rw-r--r-- 1226\n")

  (test ($< /bin/stat -c "%U:%G" /var/log/pkg)
        "pkg5srv:daemon\n")

  (test ($< /bin/stat -c "%U:%G" /var/log/pkg/server)
        "pkg5srv:daemon\n")

  (test ($< /bin/stat -c "%U:%G" /repo)
        "pkg5srv:pkg5srv\n")

  (test ($ /bin/grep -q ^pkg5srv:NP: /etc/shadow) nil)

  (test ($< /bin/stat -c "%U:%G" /repo/pkg5.repository)
        "root:root\n")

  (test ($< /bin/crontab -l pkg5srv)
        "# gurp managed ID /pkg-server/cron/refresh-pkg-repo\n*/5 * * * * /opt/site/bin/refresh-pkg-repo > /var/log/cron_jobs/refresh-pkg-repo.log 2>&1\n")

  (test ($< /bin/stat -c "%U:%G" /opt/site/bin/refresh-pkg-repo)
        "root:root\n")

  (test ($< /bin/cat /opt/site/bin/refresh-pkg-repo)
        "#!/bin/ksh -e\n\nREPO_NAME=\"sysdef\"\nREPO_ROOT=\"/repo\"\nREPO_SVC=\"application/pkg/server:sysdef\"\nMARKER=\"/var/run/refresh_repo\"\n\ntest -f $MARKER || /bin/touch $MARKER\n\nif [[ $1 != \"-f\" ]]\nthen\n  if ! test \"${REPO_ROOT}/publisher/${REPO_NAME}/pkg\" -nt $MARKER\n  then\n    /bin/touch $MARKER\n    exit 0\n  fi\nfi\n\n/usr/bin/pkgrepo refresh -s $REPO_ROOT refresh \n# /usr/sbin/svcadm refresh $REPO_SVC\n# /usr/sbin/svcadm restart $REPO_SVC\n/bin/touch $MARKER")

  # Make sure the pkg server is really up and running
  (test ($ curl -s http://localhost/en/stats.shtml -o - | grep -q "Depot Statistics") nil)

  (test ($< /bin/svcs -Ho state svc:/sysdef/application/sysdef-setup:default)
        "online\n")

  (test ($< /bin/svcs -Ho state svc:/application/pkg/server:sysdef)
        "online\n"))
