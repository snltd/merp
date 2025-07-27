(use sh)
(use judge)

(deftest "builder zone"
  (test ($< sharectl get -p nfsmapid_domain nfs) "nfsmapid_domain=lan.id264.net\n")

  (test
    ($< find /opt/site -type d |sort)
    "/opt/site\n/opt/site/bin\n/opt/site/etc\n/opt/site/lib\n/opt/site/lib/smf\n/opt/site/lib/smf/manifest\n/opt/site/lib/smf/method\n")

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
        "CRONLOG=YES\nATH=/bin:/sbin:/usr/sbin:/opt/oo/bin:/opt/ooce/sbin")

  (test ($< svcs -Ho state svc:/system/cron:default)
        "online\n")

  (test ($< stat -c "%U:%G %A" /etc/sudoers.d/sudo_group)
    "root:root -r--------\n")

  (test ($? grep -q rob:.*87RM.EPq9/51PZUW /etc/shadow) true)

  (def installed-packages (string/split "\n" ($< pkg list -Ho name)))

  (test
    (all |(has-value? installed-packages $)
         ["library/readline"
          "shell/zsh"
          "ooce/editor/helix"
          "ooce/text/ripgrep"
          "ooce/util/fd"]) true))
