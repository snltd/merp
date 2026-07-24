(use ../roles/basenode)
(use ../roles/use-pkg-proxy)
(use ../roles/victoriametrics)

(host "mmetrics"
      (basenode)
      (use-pkg-proxy)
      (victoriametrics))
