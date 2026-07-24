(use sh)
(use judge)

(deftest "basenode"
  (test ($< sharectl get -p nfsmapid_domain nfs) "nfsmapid_domain=lan.id264.net\n")

  (test ($< stat -c %U:%G /opt/site) "root:root\n")
  (test ($< stat -c %U:%G /opt/site/bin) "root:root\n")
  (test ($< stat -c %U:%G /opt/site/etc) "root:root\n")
  (test ($< stat -c %U:%G /opt/site/lib) "root:root\n")
  (test ($< stat -c %U:%G /opt/site/lib/smf) "root:root\n")
  (test ($< stat -c %U:%G /opt/site/lib/smf/manifest) "root:root\n")
  (test ($< stat -c %U:%G /opt/site/lib/smf/method) "root:root\n")

  (test ($< stat -c %U:%G /opt/site) "root:root\n")
  (test ($< stat -c %U:%G /opt/site) "root:root\n")

  (test ($< stat -c %U:%G /export) "root:sys\n")

  (test ($< stat -c %U:%G /export/home) "root:root\n")

  (test ($< grep ^rob: /etc/passwd)
        "rob:x:264:14:Rob Fisher:/home/rob:/bin/zsh\n")

  (test ($? grep -q "^set -o vi$" /etc/profile) true)

  (test ($? grep -q "^PATH=${PATH}:/opt/ooce/bin$" /etc/profile) true)

  (test ($< stat -c %U:%G /etc/default/cron)
        "root:sys\n")

  (test ($< stat -c "%U:%G %A" /var/log/cron_jobs) "root:daemon drwxrwxr-x\n")

  (test ($< cat /etc/default/cron)
        "CRONLOG=YES\nPATH=/bin:/sbin:/usr/sbin:/opt/oo/bin:/opt/ooce/sbin")

  (test ($< svcs -Ho state svc:/system/cron:default)
        "online\n")

  (test ($< stat -c "%U:%G %A" /etc/sudoers.d/sudo_group)
        "root:root -r--------\n")

  (test ($? grep -q rob:MYPASSWORDHASH /etc/shadow) true)

  (def installed-packages (string/split "\n" ($< pkg list -Ho name)))

  (test
    (all |(has-value? installed-packages $)
         ["shell/zsh"
          "ooce/terminal/starship"]) true))
