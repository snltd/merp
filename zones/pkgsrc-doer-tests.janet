(import ./site)

# Creates a pkgsrc zone, runs NGZ tests inside it, then removes the zone.

(host "pkgsrc-doer-tests"
      (zone/ensure site/pkgsrc-test-zone-name
                   :brand "pkgsrc"
                   :autoboot false
                   :recreate 1
                   (zone/network "merp_psrc0"
                                 :allowed-address (string site/pkgsrc-test-zone-ip
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
                   :exec-in ["/opt/local/bin/pkgin update"
                             "/opt/local/bin/pkgin -y in ruby34"
                             "/merp/bin/run-pkgsrc-tests"])

      (zone/remove site/pkgsrc-test-zone-name))
