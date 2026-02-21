(import ./site)

(host "network"
      (etherstub/ensure "stub1")
      (etherstub/ensure "stub2")
      (bridge/ensure "merpbr")
      (vnic/ensure "vnic0" :over site/physical-nic)
      (vnic/ensure "vnic1" :over "stub1")
      (vnic/ensure "vnic2" :over "stub2"))
