(import ../site)

(role gurp-server
      (def gurp-svc "sysdef/application/gurp-server")
      (def gurp-bin (pathcat site/site-bin "gurp"))

      (user/ensure "gurp"
                   :gecos "gurp server user"
                   :primary-group "daemon"
                   :shell "/bin/false"
                   :home-dir "/var/tmp"
                   :uid 1867)

      (smf/ensure "gurp-server"
                  :fmri gurp-svc
                  :description "config management server"
                  :duration "child"
                  (smf/method "start"
                              :exec (argcat gurp-bin
                                            "server"
                                            "--config-dir"
                                            (pathcat site/gurp-config-dir "infra" "zones"))
                              :timeout 20
                              :user "gurp"
                              :group "daemon"
                              :privileges ["basic"
                                           "!proc_session"
                                           "!proc_info"
                                           "!file_link_any"])))
