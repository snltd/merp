(use judge)
(use sh)
(use ./lib)

(test (in-global))

(def test-bridge "merpbrdg")
(def stub-1 "mstub1")
(def stub-2 "mstub2")

# Bridge and stub should not exist
(test (bridge-exists? test-bridge) false)
(test (etherstub-exists? stub-1) false)
(test (etherstub-exists? stub-2) false)

# Noop should do nothing
(test (apply-changes-noop (resource "bridge/ensure" test-bridge)) 1)
(test (bridge-exists? test-bridge) false)

# Create with default values
(test (apply-changes (resource "bridge/ensure" test-bridge)) 1)
(test (bridge-exists? test-bridge) true)
(test
  ($< dladm show-bridge ,test-bridge -p)
  "merpbrdg:stp::32768:\n")

# Create an etherstub to use as a link
(test (apply-changes (resource "etherstub/ensure" stub-1)) 1)
(test (etherstub-exists? stub-1) true)

# Add a link. Second should do nothing.
(test (apply-changes (resource "bridge/ensure" test-bridge :links @[stub-1])) 1)
(test
  ($< dladm show-bridge -lp ,test-bridge)
  "mstub1:discarding:0:32768/0\\:0\\:0\\:0\\:0\\:0\n")
(test (apply-changes (resource "bridge/ensure" test-bridge :links @[stub-1])) 0)

# Remove the link and change the max-age
(test (apply-changes (resource "bridge/ensure" test-bridge :priority 8192)) 1)
(test ($< dladm show-bridge -lp ,test-bridge) "")
(test
  ($< dladm show-bridge ,test-bridge -p)
  "merpbrdg:stp:8192/0\\:0\\:0\\:0\\:0\\:0:8192:32768/0\\:0\\:0\\:0\\:0\\:0\n")

# Remove noop should do nothing
(test (apply-changes-noop (resource "bridge/remove" test-bridge)) 1)
(test (bridge-exists? test-bridge) true)

# Remove bridge
(test (apply-changes (resource "bridge/remove" test-bridge)) 1)
(test (bridge-exists? test-bridge) false)

# Tidy up the stubs
(test (apply-changes (resource "etherstub/remove" stub-1)) 1)
(test (etherstub-exists? stub-1) false)
(test (etherstub-exists? stub-2) false)

# Create a new bridge with new values and two links
(test (apply-changes (resource "etherstub/ensure" stub-1)) 1)
(test (apply-changes (resource "etherstub/ensure" stub-2)) 1)
(test (etherstub-exists? stub-1) true)
(test (etherstub-exists? stub-2) true)

(def spec
  (resource "bridge/ensure" test-bridge
            :links @[stub-1 stub-2]
            :priority 8192
            :force-protocol 3
            :forward-delay 15
            :hello-time 2
            :max-age 23))

# It applies and a further apply makes no change
(test (apply-changes spec) 1)
(test (apply-changes spec) 0)

(test
  ($< dladm show-bridge
      -o "protect,priority,bhellotime,bfwddelay,forceproto,bmaxage"
      ,test-bridge)
  "PROTECT PRIORITY BHELLOTIME BFWDDELAY FORCEPROTO BMAXAGE\nstp     8192     2          15        3          23\n")

(test
  ($< dladm show-bridge -l ,test-bridge -p)
  "mstub1:discarding:0:8192/0\\:0\\:0\\:0\\:0\\:0\nmstub2:discarding:0:8192/0\\:0\\:0\\:0\\:0\\:0\n")

# Remove bridge
(test (apply-changes (resource "bridge/remove" test-bridge)) 1)
(test (bridge-exists? test-bridge) false)

# Tidy up the stubs
(test (apply-changes (resource "etherstub/remove" stub-1)) 1)
(test (apply-changes (resource "etherstub/remove" stub-2)) 1)
(test (etherstub-exists? stub-1) false)
(test (etherstub-exists? stub-2) false)
