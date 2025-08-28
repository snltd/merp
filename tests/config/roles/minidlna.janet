(use ../globals)

(def smf-method-path (pathcat site-smf-method "minidlna.sh"))
(def smf-service "sysdef/multimedia/minidlna")

(role minidlna
      (pkg/ensure "ooce/multimedia/minidlna")

      (file/ensure smf-method-path
                   :mode "0755"
                   :from "minidlna/minidlna-method.sh")

      (file/ensure "/etc/opt/ooce/minidlna/minidlna.conf"
                   :from "minidlna/minidlna.conf")

      (svc/ensure smf-service :state "online")

      (smf/remove "svc:/ooce/multimedia/minidlna:default")
      
      (smf/ensure smf-service
                  :fmri smf-service
                  :description "MiniDLNA - DLNA/UPnP-AV media server"
                  (smf-method "start"
                              :exec smf-method-path
                              :user "minidlna"
                              :group "minidlna")
                  (smf-method "refresh"
                              :exec smf-method-path
                              :user "minidlna"
                              :group "minidlna")))
