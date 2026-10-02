(import ../site)
(import ../network)

(def nat-template
  (indoc `
    map mrtr0 {{ internal-addr }}/32 -> {{ router-ip }}/32 portmap tcp/udp auto
    map mrtr0 {{ internal-addr }}/32 -> {{ router-ip }}/32`))

(role router
      (ip-properties/ensure "router"
                            :ipv4 {:forwarding true})

      # internet access for the pkg proxy
      (ipnat/ensure "nat-pkg-proxy"
                    :priority 10
                    :content (template-out
                               nat-template
                               {:internal-addr (network/addr :mproxy)
                                :router-ip (network/addr :mrouter/host)}))

      # internet access for the DNS net/server
      (ipnat/ensure "nat-dns"
                    :priority 20
                    :content (template-out
                               nat-template
                               {:internal-addr (network/addr :mdns)
                                :router-ip (network/addr :mrouter/host)}))

      (ip-interface/ensure "mrtr0")
      (ip-interface/ensure "mrtr1")
      (ip-interface/ensure "mrtr2")
      (ip-interface/ensure "mrtr3")

      (ip-address/ensure "mrtr0/v4"
                         :type "static"
                         :properties {:prefixlen (network/prefix :host)}
                         :address (network/cidr :mrouter/host :host))

      (ip-address/ensure "mrtr1/v4"
                         :type "static"
                         :properties {:prefixlen (network/prefix :dmz)}
                         :address (network/cidr :mrouter/dmz :dmz))

      (ip-address/ensure "mrtr2/v4"
                         :type "static"
                         :properties {:prefixlen (network/prefix :mgmt)}
                         :address (network/cidr :mrouter/mgmt :mgmt))

      (ip-address/ensure "mrtr3/v4"
                         :type "static"
                         :properties {:prefixlen (network/prefix :telem)}
                         :address (network/cidr :mrouter/telem :telem))

      (route/ensure "default" :gateway network/internet))
