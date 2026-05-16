# (import "../helpers")
(import "../site")

(def etc-default-cron (indoc `
         CRONLOG=YES
         PATH=/bin:/sbin:/usr/sbin:/opt/ooce/bin:/opt/ooce/sbin`))

(role basenode
      (section nfs
               (misc/ensure :nfs-domain site/local-domain))

      (section dirs
               (directory/ensure "/export" :group "sys")
               (directory/ensure "/export/home"))

      (section site-dirs
               (directory/ensure site/site-dir)
               (directory/ensure site/site-bin)
               (directory/ensure site/site-etc)
               (directory/ensure site/site-smf-method)
               (directory/ensure site/site-smf-manifest))

      # (section packages
      #          (pkg/ensure "library/readline")
      #          (pkg/ensure "ooce/editor/helix")
      #          (pkg/ensure "ooce/terminal/starship")
      #          (pkg/ensure "ooce/text/ripgrep")
      #          (pkg/ensure "ooce/util/bat")
      #          (pkg/ensure "ooce/util/fd")
      #          (pkg/ensure "shell/zsh"))

      (section sudo
               (file/ensure "/etc/sudoers.d/sudo_group"
                            :mode "0400"
                            :content "%sysadmin ALL=(ALL:ALL) ALL"))

      # (section users
      #          (user/ensure "merp"
      #                       :uid 264
      #                       :gecos "merp user"
      #                       :home-dir "/home/merp"
      #                       :shell "/bin/sh"
      #                       :primary-group "sysadmin"
      #                       :other-groups ["staff"]))

      (section cron
               (file/ensure "/etc/default/cron"
                            :label "crondef"
                            :group "sys"
                            :content etc-default-cron))

      (directory/ensure site/cron-log-dir
                        :mode "0775"
                        :group "daemon")

      (svc/ensure "cron"
                  :state "online"
                  :restarted-by [(this "file" "crondef")])

      # (section gurp-yo-self
      #          (file/remove "/var/tmp/gurp")
      #          (cron/ensure "run gurp"
      #                       :minute (cron-minutes-from-name (fact :hostname) 10)
      #                       :command (helpers/site-cron "gurp" "apply"
      #                                                   "--metrics-to=metrics"
      #                                                   "--server=gurp")))

      (section good-sense
               (file-line/ensure "/etc/profile"
                                 :label "profile-set-vi"
                                 :line "set -o vi")

               (file-line/ensure "/etc/profile"
                                 :label "profile-path"
                                 :line (string "PATH=${PATH}:/opt/ooce/bin:" site/site-bin))))
