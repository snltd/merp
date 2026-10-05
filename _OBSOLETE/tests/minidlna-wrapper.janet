(use ./tests/helpers)

(controller-for "minidlna" :remove-after true :test-basenode true)
(host "gurp-test-host" (test-controller))
