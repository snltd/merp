(import ../site)
(import ../network)

(def nat-template
  (indoc `
    map mrpr0 {{ internal-addr }}/32 -> {{ router-ip }}/32 portmap tcp/udp auto
    map mrpr0 {{ internal-addr }}/32 -> {{ router-ip }}/32`))

(role router
      (ip-properties/ensure "router"
                            :ipv4 {:forwarding true})

      # internet access for the pkg proxy
      (ipnat/ensure "nat-pkg-proxy"
                    :priority 10
                    :content (template-out
                               nat-template
                               {:internal-addr (network/addr :proxy)
                                :router-ip (network/addr :router/host)}))

      # internet access for the DNS net/server
      (ipnat/ensure "nat-dns"
                    :priority 20
                    :content (template-out
                               nat-template
                               {:internal-addr (network/addr :dns)
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
