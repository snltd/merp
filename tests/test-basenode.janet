(def test-zone "basenode")
# 
# Clones the template zone and applies`
(role gurp-test-role
      (zone/ensure "gurp-test-zone"
                   :brand "lipkg"
                   :clone-from "gurp-template"
                   :autoboot false
                   :recreate 1
                   (zone-network "t_gurp_net0"
                                 :allowed-address "192.168.1.200/24"
                                 :defrouter "192.168.1.1")
                   :dns {:domain "lan.id264.net"
                         :nameservers ["192.168.1.53" "192.168.1.1"]}
                   :copy-in {(string (os/getenv "GURP_TEST_DIR") "/tests") "/var/tmp"}
                   :exec-in ["/usr/bin/judge /var/tmp/tests/judge/basenode.janet"]
                   :bootstrap-from "/var/tmp/tests/config/basenode.janet"))

(host "gurp-test-host"
      (gurp-test-role))
