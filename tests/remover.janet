(use ./tests/helpers)

(controller-for "remover" :remove-after true :test-basenode true :with-dataset true)
(host "gurp-test-host" (test-controller))
