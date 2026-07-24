(import ../site)
(import ../network)

(role bootstrap-zones
      # Most of the other zones are cloned from this one. It's very basic: just
      # has the basenode role applied.
      # 
      (zone/ensure site/gold-zone
                   :brand "lipkg"
                   # :recreate (recreate? site/gold-zone)
                   (zone/network "mrpgold0"
                                 :global-nic network/physical-nic
                                 :allowed-address (network/cidr :gold :host)
                                 :defrouter (network/addr :internet))
                   :copy-in {site/gurp-under-test "/var/tmp/gurp"
                             site/merp-dir site/gurp-config-dir}
                   :dns network/dns
                   :final-state "installed"
                   (zone/bootstrap :file (pathcat site/gurp-config-dir
                                                  "zones"
                                                  "gold.janet")))

      # A router and NAT zone. Forwards traffic between etherstubs, and gives
      # internet access to the things that need it.
      # 
      # We can't use allowed-address here because it turns on ip-spoof protection,
      # which breaks the NATting and forwarding. So the interfaces are configured
      # by the router's own role
      # 
      (zone/ensure "mrouter"
                   :brand "lipkg"
                   :recreate (recreate? "mrouter")
                   :clone-from site/gold-zone
                   (zone/network "mrpr0"
                                 :global-nic network/physical-nic)
                   (zone/network "mrpr1"
                                 :global-nic network/stub/dmz)
                   (zone/network "mrpr2"
                                 :global-nic network/stub/mgmt)
                   (zone/network "mrpr3"
                                 :global-nic network/stub/metrics)
                   :copy-in {site/gurp-under-test "/opt/site/bin/gurp"
                             site/merp-dir site/gurp-config-dir}
                   :dns network/dns
                   (zone/bootstrap :file (pathcat site/gurp-config-dir
                                                  "zones"
                                                  "router.janet")))

      # A Gurp server. All the zones except Gold and Router are configured from
      # this. 
      # 
      (zone/ensure "mgurp"
                   :brand "lipkg"
                   :recreate (recreate? "mgurp")
                   :clone-from site/gold-zone
                   (zone/network "mrpg0"
                                 :global-nic network/stub/mgmt
                                 :allowed-address (network/cidr :gurp :mgmt)
                                 :defrouter (network/addr :router/mgmt))
                   :copy-in {site/gurp-under-test "/opt/site/bin/"
                             site/merp-dir site/gurp-config-dir}
                   :dns network/dns
                   (zone/bootstrap :file (pathcat site/gurp-config-dir
                                                  "zones"
                                                  "gurp.janet")))

      # A proxy server which grants access to the OmniOS package repos to all
      # 10.x.x.x hosts.
      # 
      (zone/ensure "mproxy"
                   :brand "lipkg"
                   :recreate (recreate? "mproxy")
                   :clone-from site/gold-zone
                   (zone/network "mprxy0"
                                 :global-nic network/stub/mgmt
                                 :allowed-address (network/cidr :proxy :mgmt)
                                 :defrouter (network/addr :router/mgmt))
                   :copy-in {site/gurp-under-test "/opt/site/bin/"
                             site/merp-dir site/gurp-config-dir}
                   :dns network/dns
                   (zone/bootstrap :server (network/addr :gurp))))

      # VictoriaMetrics. Gurp clients and server will send some metrics to this.
      # 
      (zone/ensure "mmetrics"
                   :brand "lipkg"
                   :recreate (recreate? "mmetrics")
                   :clone-from site/gold-zone
                   (zone/network "mmtrc0"
                                 :global-nic network/stub/metrics
                                 :allowed-address (network/cidr :vm :metrics)
                                 :defrouter (network/addr :router/metrics))
                   :copy-in {site/gurp-under-test "/opt/site/bin/"
                             site/merp-dir site/gurp-config-dir}
                   :dns network/dns
                   (zone/bootstrap :server (network/addr :gurp))))
