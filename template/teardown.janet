# Cleans up everything merp makes
# 
(host "tester"
  (zone/remove "merp-template")
  (zone/remove "merp-zone")
  (zfs/remove "rpool/zones/merp-template")
  (zfs/remove "rpool/zones/merp-zone"))

