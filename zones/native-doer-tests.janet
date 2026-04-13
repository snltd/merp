(use ./roles/gold-zone)
(use ./roles/native-doer-tests)

(host "native-doer-tests"
      (gold-zone)
      (native-doer-tests))
