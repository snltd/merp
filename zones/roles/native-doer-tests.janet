(import ../site)

# Clones from the gold zone, and executes all the doer NGZ tests in the new
# zone
#
(role ngz-doer-tests
      (zone/ensure site/ngz-test-zone-name
                   :brand "lipkg"
                   :autoboot false
                   :clone-from site/gold-zone-name
                   :recreate 1
                   (zone/network "merp_ngz0"
                                 :allowed-address (string site/ngz-test-zone-ip
                                                          "/"
                                                          site/ngz-netmask)
                                 :defrouter site/ngz-router)
                   :dns {:domain site/ngz-dns-domain
                         :nameservers [site/ngz-dns-server]}
                   (zone/fs "/gurp"
                            :options ["ro"]
                            :special site/gurp-dir)
                   (zone/fs "/merp"
                            :special site/merp-dir)
                   :exec-in ["/merp/bin/run-ngz-tests"])

      (zone/remove site/ngz-test-zone-name))
