(use judge)
(use sh)
(use ./lib)

(test (in-global) nil)

(def stub-1 "mstub1")

(test (etherstub-exists? stub-1) false)

# A noop should do nothing
(test (apply-changes-noop (resource "etherstub/ensure" stub-1)) 1)
(test (etherstub-exists? stub-1) false)

# Create a stub. Second apply should show no change
(test (apply-changes (resource "etherstub/ensure" stub-1)) 1)
(test (etherstub-exists? stub-1) true)
(test (apply-changes (resource "etherstub/ensure" stub-1)) 0)

# Noop remove should do nothing but show a change
(test (apply-changes-noop (resource "etherstub/remove" stub-1)) 1)
(test (etherstub-exists? stub-1) true)

# Remove
(test (apply-changes (resource "etherstub/remove" stub-1)) 1)
(test (etherstub-exists? stub-1) false)

# Fail with an invalid name
(test (apply-fails (resource "etherstub/ensure" "stubby")
                   "dladm: invalid link name 'stubby'")
  true)
