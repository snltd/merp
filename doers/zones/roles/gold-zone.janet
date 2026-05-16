(import ../site)

# Installs a fresh zone which contains everything Merp needs to run its tests.
# This zone is cloned each time Merp runs a functional test.
#
# Needs access to the Internet to install packages.
#
(role gold-zone
      (zone/ensure site/gold-zone-name
                   :brand "lipkg"
                   :autoboot false
                   (zone/network "merp_net0"
                                 :allowed-address (string site/gold-zone-ip
                                                          "/"
                                                          site/netmask)
                                 :defrouter site/router)
                   :dns {:domain site/dns-domain
                         :nameservers [site/dns-server]}
                   :exec-in ["/bin/pkg install ooce/runtime/ruby-34"]
                   :final-state "installed"))
