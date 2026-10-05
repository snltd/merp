(import ../site)
(import ../network)

(def zone-dir (pathcat site/gurp-config-dir "infra" "zones"))

# When Gurp bootstraps a zone, it copies itself into the zone at /var/tmp/gurp,
# but it's more convenient, at least when developing tests, to also have a live
# copy of the Gurp binary we're testing.
# 
(defn with-gurp-under-test []
  (zone/fs (pathcat site/zone-gurp)
           :options ["ro"]
           :special site/gurp-under-test))

(role bootstrap-zones
      # Most of the other zones are cloned from this one. It's very basic: just
      # has the basenode role applied. It halts after installation, and does
      # not autoboot, because you can't clone a running zone.
      # 
      (zone/ensure site/gold-zone
                   :brand "lipkg"
                   :recreate (recreate? site/gold-zone)
                   (zone/network "mgold0"
                                 :global-nic network/physical-nic
                                 :allowed-address (network/cidr :gold :host)
                                 :defrouter (network/addr :internet))
                   :dns {:nameservers [network/external-dns]}
                   :autoboot false
                   :final-state "installed"
                   (zone/fs site/in-zone-test-dir
                            :options ["ro"]
                            :special site/infra-test-dir)
                   (zone/bootstrap
                     :file (pathcat site/in-zone-test-dir "zones" "gold.janet")))

      # A router and NAT zone. Forwards traffic between etherstubs, and gives
      # internet access to the things that need it.
      # 
      # We can't use allowed-address here because it turns on ip-spoof protection,
      # which breaks the NATting and forwarding. So the interfaces are configured
      # by the router's own role
      # 
      (zone/ensure "mrouter"
                   (with-gurp-under-test)
                   :brand "lipkg"
                   :recreate (recreate? "mrouter")
                   :clone-from site/gold-zone
                   (zone/network "mrtr0" :global-nic network/physical-nic)
                   (zone/network "mrtr1" :global-nic network/stub/dmz)
                   (zone/network "mrtr2" :global-nic network/stub/mgmt)
                   (zone/network "mrtr3" :global-nic network/stub/telem)
                   (zone/fs site/in-zone-test-dir
                            :options ["ro"]
                            :special site/infra-test-dir)
                   :dns {:nameservers [(network/addr :mdns)]}
                   (zone/bootstrap
                     :copy-self false
                     :gurp-binary site/zone-gurp
                     :file (pathcat site/in-zone-test-dir "zones" "mrouter.janet")))

      # A Gurp server. All the zones except Gold and Router are configured from
      # this. It contains a read-only loopback of this merp directory.
      # 
      (zone/ensure "mgurp"
                   (with-gurp-under-test)
                   :brand "lipkg"
                   :recreate (recreate? "mgurp")
                   :clone-from site/gold-zone
                   (zone/network "mprg0"
                                 :global-nic network/stub/mgmt
                                 :allowed-address (network/cidr :mgurp :mgmt)
                                 :defrouter (network/addr :mrouter/mgmt))
                   (zone/fs site/gurp-config-dir
                            :options ["ro"]
                            :special site/merp-dir)
                   :dns {:nameservers [(network/addr :mdns)]
                         :domain network/local-domain}
                   (zone/bootstrap
                     :copy-self false
                     :gurp-binary site/zone-gurp
                     :file (pathcat zone-dir "mgurp.janet")))

      # A proxy server which grants access to the OmniOS package repos to all
      # 10.x.x.x hosts.
      # 
      (zone/ensure "mproxy"
                   (with-gurp-under-test)
                   :brand "lipkg"
                   :recreate (recreate? "mproxy")
                   :clone-from site/gold-zone
                   (zone/network "mprxy0"
                                 :global-nic network/stub/mgmt
                                 :allowed-address (network/cidr :mproxy :mgmt)
                                 :defrouter (network/addr :mrouter/mgmt))
                   :dns {:nameservers [network/external-dns
                                       (network/addr :mdns)]}
                   (zone/bootstrap
                     :copy-self false
                     :gurp-binary site/zone-gurp
                     :server (network/addr :mgurp)))

      # A DNS server, so the things in the private subnets can see each other,
      # and pkg requests don't time out. Needs the proxy so it can install BIND.
      # 
      (zone/ensure "mdns"
                   (with-gurp-under-test)
                   :brand "lipkg"
                   :recreate (recreate? "mdns")
                   :clone-from site/gold-zone
                   (zone/network "mdns0"
                                 :global-nic network/stub/mgmt
                                 :allowed-address (network/cidr :mdns :mgmt)
                                 :defrouter (network/addr :mrouter/mgmt))
                   :dns {:nameservers [(network/addr :mdns) network/external-dns]
                         :domain network/local-domain}
                   (zone/bootstrap
                     :copy-self false
                     :gurp-binary site/zone-gurp
                     :server (network/addr :mgurp)))

      # Telemetry Gurp clients and server will send metrics and logs to this.
      # It has a dedicated dataset for data storage, so you can recreate the
      # zone and not lose historical data.
      # 
      (def mtelem-dataset (zfscat site/zfs-root "telemetry-data"))

      (zfs/ensure mtelem-dataset
                  :properties {:mountpoint "none"})

      (zone/ensure "mtelem"
                   (with-gurp-under-test)
                   :brand "lipkg"
                   :recreate (recreate? "mtelem")
                   :clone-from site/gold-zone
                   (zone/network "mtlm0"
                                 :global-nic network/stub/telem
                                 :allowed-address (network/cidr :mtelem :telem)
                                 :defrouter (network/addr :mrouter/telem))
                   :dns {:nameservers [(network/addr :mdns)]
                         :domain network/local-domain}
                   :datasets [mtelem-dataset]
                   (zone/bootstrap
                     :copy-self false
                     :gurp-binary site/zone-gurp
                     :server (network/addr :mgurp)))

      # A Grafana zone. OmniOS doesn't have a Grafana package, so this is the
      # perfect opportunity to test LX zones and the APK doer
      # 
      # (def mgrafana-dataset (zfscat site/zfs-root "grafana-data"))

      # (zfs/ensure mgrafana-dataset
      #             :properties {:mountpoint "none"})

      # (zone/ensure "mgrafana"
      #              :brand "lx"
      #              :recreate (recreate? "mgrafana")
      #              :image "alpine"
      #              :final-state "reboot"
      #              (zone/attr "kernel-version" :value "4.4")
      #              (zone/network "mgrf0"
      #                            :global-nic network/stub/telem
      #                            :allowed-address (network/cidr :mgrafana :telem)
      #                            :defrouter (network/addr :router/telem))
      #              :copy-in {"/opt/site/bin/gurp" "/opt/site/bin/gurp"}
      #              :datasets [mgrafana-dataset]
      #              (zone/bootstrap :server (network/addr :mgurp)))
      )
