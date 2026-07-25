(import ../site)
(import ../network)

# We only need core, and we don't use mirrors, because it takes for ever to add
# proxies.

(role use-pkg-proxy
      (def proxy-uri (string/format "http://%s:%d"
                                    (network/addr :proxy)
                                    network/proxy-port))

      (publisher/ensure "omnios"
                        (publisher/origin
                          (string/format "https://pkg.omnios.org/%s/core/"
                                         site/omnios-version)
                          :proxy proxy-uri)))

