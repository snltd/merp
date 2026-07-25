(import ../network)

(def squid-config (indoc `
  {{ acl-block }}

  acl pkg_mirrors dstdomain pkg.omnios.org
  acl pkg_mirrors dstdomain us-west.mirror.omnios.org

  http_port {{ proxy-port }}
  cache deny all

  http_access allow localnet pkg_mirrors
  http_access deny all`))

(def acl-block
  (string/join
    (catseq [[net prefix] :pairs (zipcoll network/network network/prefix)]
      (string/format "acl localnet src %s/%d" net prefix))
    "\n"))

(role pkg-proxy
      (file/ensure "/etc/opt/ooce/squid/squid.conf"
                   :label "squid-conf"
                   :mode "0600"
                   :content (template-out squid-config
                                          {:proxy-port network/proxy-port
                                           :acl-block acl-block}))

      (pkg/ensure "ooce/network/proxy/squid")

      (svc/ensure "svc:/ooce/proxy/squid:default"
                  :state "online"
                  :restarted-by [(this :file :squid-conf)]))
