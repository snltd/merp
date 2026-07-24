(import ../site)
(import ../network)

(role use-pkg-proxy
      (def proxy-uri (string/format "http://%s:%d"
                                    (network/addr :proxy)
                                    network/proxy-port))

      (publisher/ensure "omnios"
                        (publisher/origin
                          (string/format "https://pkg.omnios.org/%s/core/" site/omnios-version)
                          :proxy proxy-uri)
                        (publisher/mirror
                          (string/format "https://us-west.mirror.omnios.org/%s/core/" site/omnios-version)
                          :proxy proxy-uri))

      (publisher/ensure "extra.omnios"
                        (publisher/origin
                          (string/format "https://pkg.omnios.org/%s/extra/" site/omnios-version)
                          :proxy proxy-uri)
                        (publisher/mirror
                          (string/format "https://us-west.mirror.omnios.org/%s/extra/" site/omnios-version)
                          :proxy proxy-uri)))
