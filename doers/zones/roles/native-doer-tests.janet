(import ../site)

# Clones from the gold zone, and executes all the doer NGZ tests in the new
# zone
#
(role native-doer-tests
      (zone/ensure site/native-test-zone-name
                   :brand "lipkg"
                   :autoboot false
                   :clone-from site/gold-zone-name
                   :recreate 1
                   (zone/network "merp_ngz0"
                                 :allowed-address (string site/native-test-zone-ip
                                                          "/"
                                                          site/netmask)
                                 :defrouter site/router)
                   :dns {:domain site/dns-domain
                         :nameservers [site/dns-server]}
                   (zone/fs "/gurp"
                            :options ["ro"]
                            :special site/gurp-dir)
                   (zone/fs "/merp"
                            :special site/merp-dir)
                   :exec-in ["/merp/doers/bin/run-native-tests"])

      (zone/remove site/native-test-zone-name))
