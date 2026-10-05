(use ./tests/helpers)

(controller-for "mariadb" :remove-after true :test-basenode true :with-dataset true)
(host "gurp-test-host" (test-controller))
