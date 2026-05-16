(import ./site)
(use roles/network)

(host "any"
(zone/ensure "z-router"
  :brand "lipkg"
  :clone-from site/gold-zone
  :

)
