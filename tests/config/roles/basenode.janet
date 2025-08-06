(import "../globals")

(role basenode
      (section nfs
               (misc/ensure :nfs-domain "lan.id264.net"))

      (section dirs
               (directory/ensure "/export" :group "sys")
               (directory/ensure "/export/home"))

      (section site-dirs
               (directory/ensure globals/site-dir)
               (directory/ensure globals/site-bin)
               (directory/ensure globals/site-etc)
               (directory/ensure globals/site-smf-method)
               (directory/ensure globals/site-smf-manifest))

      (section packages
               (pkg/ensure "library/readline")
               (pkg/ensure "ooce/editor/helix")
               (pkg/ensure "ooce/text/ripgrep")
               (pkg/ensure "ooce/util/fd")
               (pkg/ensure "shell/zsh"))

      (section sudo
               (file/ensure "/etc/sudoers.d/sudo_group"
                            :mode "0400"
                            :content "%sysadmin ALL=(ALL:ALL) ALL"))

      (section users
               (user/ensure "rob"
                            :uid 264
                            :gecos "Rob Fisher"
                            :home-dir "/home/rob"
                            :shell "/bin/zsh"
                            :password-hash "MYPASSWORDHASH"
                            :primary-group "sysadmin"))

      (section cron
               (file/ensure "/etc/default/cron"
                            :label "crondef"
                            :group "sys"
                            :content "CRONLOG=YES\nATH=/bin:/sbin:/usr/sbin:/opt/oo/bin:/opt/ooce/sbin")
               (directory/ensure globals/cron-log-dir
                                 :mode "0775"
                                 :group "daemon")
               (svc/ensure "cron"
                           :state "online"
                           :restarted-by [(this "file" "crondef")]))

      (section good-sense
               (file-line/ensure "/etc/profile"
                                 :label "profile-set-o-vi"
                                 :line "set -o vi")
               (file-line/ensure "/etc/profile"
                                 :label "profile-path"
                                 :line "PATH=${PATH}:/opt/ooce/bin")))
