(import ../site)
(import ../network)

# NAT rules to allow proxy egress
(def nat-proxy
  (indoc `
    map mrpr0 {{ proxy-addr }}/32 -> {{ router-ip }}/32 portmap tcp/udp auto
    map mrpr0 {{ proxy-addr }}/32 -> {{ router-ip }}/32`))

(role router
      (ip-properties/ensure "router"
                            :ipv4 {:forwarding true})

      (ipnat/ensure "internet-gateway"
                    :priority 10
                    :content (template-out
                               nat-proxy
                               {:proxy-addr (network/addr :proxy)
                                :router-ip (network/addr :router/host)}))

      (ip-interface/ensure "mrpr0")
      (ip-interface/ensure "mrpr1")
      (ip-interface/ensure "mrpr2")
      (ip-interface/ensure "mrpr3")

      (ip-address/ensure "mrpr0/v4"
                         :type "static"
                         :properties {:prefixlen (network/prefix :host)}
                         :address (network/addr :router/host))

      (ip-address/ensure "mrpr1/v4"
                         :type "static"
                         :properties {:prefixlen (network/prefix :dmz)}
                         :address (network/addr :router/dmz))

      (ip-address/ensure "mrpr2/v4"
                         :type "static"
                         :properties {:prefixlen (network/prefix :mgmt)}
                         :address (network/addr :router/mgmt))

      (ip-address/ensure "mrpr3/v4"
                         :type "static"
                         :properties {:prefixlen (network/prefix :metrics)}
                         :address (network/addr :router/metrics))

      (route/ensure "default" :gateway network/internet))
