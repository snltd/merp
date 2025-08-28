# Installs a fresh zone which contains everything Merp needs to run its tests.
# This zone is cloned each time Merp runs a functional test.
#
# Needs access to the Internet to install packages. Adjust network parameters
# to suit.
#
(role template-zone
      (zone/ensure "merp-template"
                   :brand "lipkg"
                   :autoboot false
                   (zone-network "merp_net0"
                                 :allowed-address "192.168.1.199/24"
                                 :defrouter "192.168.1.1")
                   :dns {:domain "lan.id264.net"
                         :nameservers ["192.168.1.53" "192.168.1.1"]}
                   :copy-in {"janet" "/usr/bin/janet"
                             "judge" "/usr/bin/judge"
                             "jpm_tree" "/usr/lib/janet"}
                   :final-state "installed"))

(host "merp-test-host" (template-zone))
