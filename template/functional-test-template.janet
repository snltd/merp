# Installs a fresh zone which contains everything Merp needs to run its tests.
# This zone is cloned each time Merp runs a functional test.
#
# Needs access to the Internet to install packages. Adjust network parameters
# to suit.
#
(role template-zone
      (zone/ensure "gurp-template"
                   :brand "lipkg"
                   :clone-from "clean-zone"
                   :autoboot false
                   :recreate 1
                   (zone-network "gurp_net0"
                                 :allowed-address "192.168.1.199/24"
                                 :defrouter "192.168.1.1")
                   :dns {:domain "lan.id264.net"
                         :nameservers ["192.168.1.53" "192.168.1.1"]}
                   :copy-in {"janet" "/usr/bin/janet"
                             "judge" "/usr/bin/judge"
                             "jpm_tree" "/usr/lib/janet"}
                   :exec-in ["/usr/bin/pkg refresh"
                             "/usr/sbin/shutdown -y -i5 -g0"]))

(host "this-host" (template-zone))
