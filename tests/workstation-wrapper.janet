(use ./tests/helpers)

(controller-for "workstation" :remove-after true :test-basenode true)
(host "gurp-test-host" (test-controller))
