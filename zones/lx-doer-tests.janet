(import ./site)

# Creates an Alpine LX zone from the latest available image, runs lx-specific
# tests inside it, then removes the zone.
 
(host "lx-doer-tests"
      (zone/ensure site/lx-test-zone-name
                   :brand "lx"
                   :recreate 1
                   :lx-image "alpine"
                   (zone/attr "kernel-version" :value "4.4")
                   (zone/network "merp_lx0"
                                 :allowed-address (string site/lx-test-zone-ip
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
                   :exec-in ["/merp/bin/run-lx-tests"])

      (zone/remove site/lx-test-zone-name))
