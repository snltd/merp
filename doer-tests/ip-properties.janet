(use judge)
(use sh)
(import ./site)
(use ./lib)

# These are defaults
(test ($< ipadm show-prop -c -o current -p forwarding ipv4) "off\n")
(test ($< ipadm show-prop -c -o current -p hoplimit ipv6) "255\n")
(test ($< ipadm show-prop -c -o current -p max_buf icmp) "262144\n")
(test ($< ipadm show-prop -c -o current -p sack tcp) "active\n")
(test ($< ipadm show-prop -c -o current -p extra_priv_ports udp) "2049,4045\n")
(test ($< ipadm show-prop -c -o current -p max_buf sctp) "1048576\n")

# A noop should not change anything
(test (apply-changes-noop (resource "ip-properties/ensure"  "merp-test"
    :ipv4 {:forwarding true}
   :ipv6 {:hoplimit 250}
   :icmp {:max_buf 262000}
   :tcp {:sack "passive"}
   :udp {:extra_priv_ports "2050,4040"}
   :sctp {:max_buf 1048000})) 6)
(test ($< ipadm show-prop -c -o current -p forwarding ipv4) "off\n")
(test ($< ipadm show-prop -c -o current -p hoplimit ipv6) "255\n")
(test ($< ipadm show-prop -c -o current -p max_buf icmp) "262144\n")
(test ($< ipadm show-prop -c -o current -p sack tcp) "active\n")
(test ($< ipadm show-prop -c -o current -p extra_priv_ports udp) "2049,4045\n")
(test ($< ipadm show-prop -c -o current -p max_buf sctp) "1048576\n")

# Change
(test (apply-changes (resource "ip-properties/ensure"  "merp-test"
    :ipv4 {:forwarding true}
   :ipv6 {:hoplimit 250}
   :icmp {:max_buf 262000}
   :tcp {:sack "passive"}
   :udp {:extra_priv_ports "4040,2050"}
   :sctp {:max_buf 1048000})) 6)
(test ($< ipadm show-prop -c -o current -p forwarding ipv4) "on\n")
(test ($< ipadm show-prop -c -o current -p hoplimit ipv6) "250\n")
(test ($< ipadm show-prop -c -o current -p max_buf icmp) "262000\n")
(test ($< ipadm show-prop -c -o current -p sack tcp) "passive\n")
(test ($< ipadm show-prop -c -o current -p extra_priv_ports udp) "2050,4040\n")
(test ($< ipadm show-prop -c -o current -p max_buf sctp) "1048000\n")

# Second change should do nothing
(test (apply-changes (resource "ip-properties/ensure"  "merp-test"
    :ipv4 {:forwarding true}
   :ipv6 {:hoplimit 250}
   :icmp {:max_buf 262000}
   :tcp {:sack "passive"}
   :udp {:extra_priv_ports "2050,4040"}
   :sctp {:max_buf 1048000})) 0)

# # Reset
(test (apply-changes (resource "ip-properties/ensure"  "merp-test"
  :ipv4 {:forwarding "off"} # use string, we used bool before
   :ipv6 {:hoplimit 255}
   :icmp {:max_buf 262144}
   :tcp {:sack "active"}
   :udp {:extra_priv_ports "2049,4045"}
   :sctp {:max_buf 1048576})) 6)

(test ($< ipadm show-prop -c -o current -p forwarding ipv4) "off\n")
(test ($< ipadm show-prop -c -o current -p hoplimit ipv6) "255\n")
(test ($< ipadm show-prop -c -o current -p max_buf icmp) "262144\n")
(test ($< ipadm show-prop -c -o current -p sack tcp) "active\n")
(test ($< ipadm show-prop -c -o current -p extra_priv_ports udp) "2049,4045\n")
(test ($< ipadm show-prop -c -o current -p max_buf sctp) "1048576\n")
