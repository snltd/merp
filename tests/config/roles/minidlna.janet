(use ../globals)

(def smf-method (pathcat site-smf-method "minidlna.sh"))
(def smf-service "sysdef/multimedia/minidlna")

(role minidlna
      (pkg/ensure "ooce/multimedia/minidlna")

      (file/ensure smf-method
                   :mode "0755"
                   :from "minidlna/minidlna-method.sh")

      (file/ensure "/etc/opt/ooce/minidlna/minidlna.conf"
                   :from "minidlna/minidlna.conf")

      (svc/ensure smf-service
                  :state "online")

      (smf/ensure smf-service
                  :svc-name "minidlna"
                  :fmri smf-service
                  :description "MiniDLNA - DLNA/UPnP-AV media server"
                  :start-method {:exec smf-method
                                 :timeout 30
                                 :context {:user "minidlna"
                                           :group "minidlna"}}
                  :refresh-method {:exec smf-method
                                   :timeout 60
                                   :context {:user "minidlna"
                                             :group "minidlna"}}))
