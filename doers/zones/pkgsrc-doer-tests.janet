(import ./site)

# Creates a pkgsrc zone, runs tests inside it, then removes the zone.

(host "pkgsrc-doer-tests"
      (zone/ensure site/pkgsrc-test-zone-name
                   :brand "pkgsrc"
                   :autoboot false
                   :recreate 1
                   (zone/network "merp_psrc0"
                                 :allowed-address (string site/pkgsrc-test-zone-ip
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
                   :exec-in ["/opt/local/bin/pkgin update"
                             "/opt/local/bin/pkgin -y in ruby34"
                             "/merp/doers/bin/run-pkgsrc-tests"])

      (zone/remove site/pkgsrc-test-zone-name))
