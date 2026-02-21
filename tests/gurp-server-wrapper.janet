(use helpers)

(controller-for "gurp-server" :remove-after true :test-basenode true :with-dataset true)
(host "gurp-test-server" (test-controller))
