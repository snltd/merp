(use judge)
(use sh)
(import ./site)
(use ./lib)

(defn prop-value [protocol prop]
  (string/trim ($< ipadm show-prop -c -o current -p ,prop ,protocol)))

(deftest defaults
  (test (prop-value "ipv4" "forwarding") "off")
  (test (prop-value "ipv6" "hoplimit") "255")
  (test (prop-value "icmp" "max_buf") "262144")
  (test (prop-value "tcp" "sack") "active")
  (test (prop-value "udp" "extra_priv_ports") "2049,4045")
  (test (prop-value "sctp" "max_buf") "1048576"))

(deftest noop-does-nothing
  (test (apply-changes-noop (gurp-example "ip-properties/ensure-properties")) 6)
  (test (prop-value "ipv4" "forwarding") "off")
  (test (prop-value "ipv6" "hoplimit") "255")
  (test (prop-value "icmp" "max_buf") "262144")
  (test (prop-value "tcp" "sack") "active")
  (test (prop-value "udp" "extra_priv_ports") "2049,4045")
  (test (prop-value "sctp" "max_buf") "1048576"))

(deftest change-properties
  (test (apply-changes (gurp-example "ip-properties/ensure-properties")) 6)
  (test (prop-value "ipv4" "forwarding") "on")
  (test (prop-value "ipv6" "hoplimit") "250")
  (test (prop-value "icmp" "max_buf") "262000")
  (test (prop-value "tcp" "sack") "passive")
  (test (prop-value "udp" "extra_priv_ports") "2050,4040")
  (test (prop-value "sctp" "max_buf") "1048000"))

(deftest idempotemt
  (test (apply-changes (gurp-example "ip-properties/ensure-properties")) 0))

(deftest reset
  (test (apply-changes (resource "ip-properties/ensure" "merp-test"
                                 :ipv4 {:forwarding "off"} # use string, we used bool before
                                 :ipv6 {:hoplimit 255}
                                 :icmp {:max_buf 262144}
                                 :tcp {:sack "active"}
                                 :udp {:extra_priv_ports "2049,4045"}
                                 :sctp {:max_buf 1048576})) 6)

  (test (prop-value "ipv4" "forwarding") "off")
  (test (prop-value "ipv6" "hoplimit") "255")
  (test (prop-value "icmp" "max_buf") "262144")
  (test (prop-value "tcp" "sack") "active")
  (test (prop-value "udp" "extra_priv_ports") "2049,4045")
  (test (prop-value "sctp" "max_buf") "1048576"))
