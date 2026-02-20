(use judge)
(use sh)
(use ./lib)

(def test-bridge "merpbrdg")

# Bridge should not exist
(test ($? dladm show-bridge ,test-bridge) true)

(test (apply-changes (resource "bridge/ensure" test-bridge)))

(test ($? dladm show-bridge ,test-bridge) true)

(test (apply-changes (resource "bridge/ensure" test-bridge)))

(test ($? dladm show-bridge ,test-bridge) true)
