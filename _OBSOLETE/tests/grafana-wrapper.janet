(use ./tests/helpers)

(controller-for "grafana"
                :lx-image "alpine"
                :remove-after false
                :test-basenode false
                :with-dataset true)
(host "gurp-test-host" (test-controller))
