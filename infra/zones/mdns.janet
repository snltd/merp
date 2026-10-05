(use ../roles/dns-server)
(use ../roles/basenode)

(host "mdns"
  (basenode)
  (dns-server))
