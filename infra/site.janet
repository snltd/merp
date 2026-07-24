# Paths to resources under test
(def merp-dir "/home/rob/work/merp/infra")
(def gurp-under-test "/home/rob/work/gurp/target/debug/gurp")

# Paths on zones
(def site-dir "/opt/site")
(def site-bin (string site-dir "/bin"))
(def site-etc (string site-dir "/etc"))
(def site-smf-manifest (string site-dir "/lib/smf/manifest"))
(def site-smf-method (string site-dir "/lib/smf/method"))

(def cron-log-dir "/var/log/cron_jobs")
(def gurp-config-dir "/var/tmp/merp")

(def gold-zone "mgold")

(def local-domain "merp.test")

# This dataset will hold everything Merp creates
(def zfs-root "rpool/merp-tests")

# (def gold-zone "merp-gold-zone")

# (def dns-server "1.1.1.1")
# (def local-network "192.168.1.")

# (defn addr [local-network final]
#   (string local-network (string final)))

# (def dns-domain "lan.id264.net")

# (def merp-dir (parent (parent (parent (os/realpath (dyn *current-file*))))))
# (def gurp-dir (pathcat (parent merp-dir) "gurp"))
# (def gurp (pathcat gurp-dir "target/debug/gurp"))
# (def example-dir (pathcat gurp-dir "janet/examples"))
# (def netmask "24")
# (def gold-zone-name "merp-gold-zone")
# (def gold-zone-ip "192.168.1.199")
# (def native-test-zone-name "merp-native-test")
# (def native-test-zone-ip "192.168.1.198")
# (def lx-test-zone-name "merp-lx-test")
# (def lx-test-zone-ip "192.168.1.197")
# (def pkgsrc-test-zone-name "merp-pkgsrc-test")
# (def pkgsrc-test-zone-ip "192.168.1.196")
# (def global-test-zone-name "merp-global-test")
# (def global-test-zone-ip "192.168.1.195")
# # This section is to integrate the bhyve zone into your environment
# (def local-dns-server "192.168.1.53")
# (def bhyve-boot-vol "rpool/merp-bhyve")
# (def path-to-ssh-pubkey "/home/rob/.ssh/id_rsa.pub")


#                      Internet (192.168.1.1)
#                             │
#                      e1000g0 192.168.1.101
#                             │
#            ┌────────────────┴─────────────────┐
#            │       Router/Firewall zone        │
#            │  net0: 192.168.1.101/24  (WAN)   │
#            │  net1: 10.1.0.1/24       (DMZ)   │
#            │  net2: 10.2.0.1/24       (mgmt)  │
#            │  net3: 10.3.0.1/24       (metrics)│
#            │  NAT · ip-forwarding · ipf        │
#            │  port-fwd 3000→grafana            │
#            └──────┬──────────┬────────┬────────┘
#                   │          │        │
#                mstub1     mstub2   mstub3
#            10.1.0.0/24  10.2.0.0  10.3.0.0
#               (DMZ)      (mgmt)   (metrics)
#                   │          │        │
#           ┌───────┘    ┌─────┘   ┌────┘
#           │            │         │
#      ┌────┴────┐   ┌───┴──────────────┐  ┌──────────────────┐
#      │ mbridge │   │  Gurp  10.2.0.10 │  │ VictoriaMetrics  │
#      └──┬────┬─┘   │  DNS   10.2.0.53 │  │ 10.3.0.10        │
#         │    │     └──────────────────┘  └────────┬─────────┘
#         │    │                                    │
#    ┌────┘    └────┐                    ┌──────────┴─────────┐
#    │              │                    │ Grafana 10.3.0.20  │
# ┌──┴────────┐ ┌───┴───────┐            │ reachable from     │
# │ Web zone  │ │  DB zone  │           │ 192.168.1.0/24     │
# │ 10.1.0.10 │ │ 10.1.0.20 │           └────────────────────┘
# │ telegraf  │ │ telegraf  │
# │ flowadm   │ │ no WAN    │
# └───────────┘ └───────────┘

# telegraf on all zones → victoriametrics 10.3.0.10:8428

# ipf rules:
#   pass web  → WAN
#   pass web  → db only
#   block db  → WAN
#   pass *    → victmet:8428
#   pass 192.168.1.0/24 → grafana:3000
#   pass gurp → all
#   pass all  → dns:53

