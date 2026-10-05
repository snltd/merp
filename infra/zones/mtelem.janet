(use ../roles/basenode)
(use ../roles/use-pkg-proxy)
(use ../roles/telemetry)

(host "mtelem"
      (basenode)
      (use-pkg-proxy)
      (telemetry))
