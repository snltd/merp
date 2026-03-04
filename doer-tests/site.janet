# Paths
# TODO: make these dynamic
(def gurp-dir "/home/rob/work/gurp")
(def gurp (string gurp-dir "/target/debug/gurp"))
(def example-dir (string gurp-dir "/janet/examples"))

# Network things.
# TODO: make these dynamic
(def physical "e1000g0")
(def doer-addr-1 "192.168.1.123")
(def doer-addr-2 "192.168.1.124")
(def doer-mask "24")

(def scheduler-class "FSS")
