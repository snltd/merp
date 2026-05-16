(import ../site)
(import ../network)

# Create the network infrastructure the zones require

(role infrastructure
      (zfs/ensure site/zfs-root)
      (etherstub/ensure network/stub/dmz)
      (etherstub/ensure network/stub/mgmt)
      (etherstub/ensure network/stub/metrics)

      (bridge/ensure "mbridge"))
