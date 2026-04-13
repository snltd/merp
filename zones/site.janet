#- PATHS --------------------------------------------------------------------
(def merp-dir (parent (parent (os/realpath (dyn *current-file*)))))
(def gurp-dir (pathcat (parent merp-dir) "gurp"))
(def gurp (pathcat gurp-dir "target/debug/gurp"))
(def example-dir (pathcat gurp-dir "janet/examples"))

(def local-network "192.168.1.")

(def ngz-router "192.168.1.1")
(def ngz-dns-domain "lan.id264.net")
(def ngz-netmask "24")
(def ngz-dns-server "1.1.1.1")

(def gold-zone-name "merp-gold-zone")
(def gold-zone-ip "192.168.1.199")

(def ngz-test-zone-name "merp-ngz-test")
(def ngz-test-zone-ip "192.168.1.198")

(def lx-test-zone-name "merp-lx-test")
(def lx-test-zone-ip "192.168.1.197")

(def pkgsrc-test-zone-name "merp-pkgsrc-test")
(def pkgsrc-test-zone-ip "192.168.1.196")

(def global-test-zone-name "merp-global-test")
(def global-test-zone-ip "192.168.1.195")

# This section is to integrate the bhyve zone into your environment
(def local-dns-server "192.168.1.53")
(def bhyve-boot-vol "rpool/merp-bhyve")
(def path-to-ssh-pubkey "/home/rob/.ssh/id_rsa.pub")

# This is a bhyve zone which I can bootstrap from a Gurp server. It's in my
# local DNS, and it's defined in my centralised Gurp config.
(def bhyve-dev-zone-name "serv-merp")
(def bhyve-dev-zone-ip "192.168.1.40")
(def dev-zone-boot-vol "rpool/serv-merp")
