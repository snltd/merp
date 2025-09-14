(defmacro controller-for
  "Generates a gurp role which clones a blank test zone, bootstraps it with the
  given configuration, then runs Judge tests inside it. Finally, removes said zone"
  [config &keys {:test-basenode test-basenode
                 :remove-after remove-after
                 :lx-image lx-image
                 :with-dataset with-dataset}]

  (def merp-dir (os/getenv "GURP_TEST_DIR"))

  ~(role test-controller
         (if ,with-dataset
           (zfs/ensure "rpool/test-zone-dataset"
                       :properties {:mountpoint "none"}))
         (zone/ensure "merp-zone"
                      ;(if ,lx-image
                         [:brand "lx"
                          :final-state "reboot"
                          (zone-attr "kernel-version" :value "4.4")
                          :lx-image ,lx-image
                          :copy-in {(string ,merp-dir "/template/files/janet") "/usr/bin/janet"
                                    (string ,merp-dir "/template/files/judge") "/usr/bin/judge"
                                    (string ,merp-dir "/template/files/jpm_tree") "/usr/lib/janet"}]
                         [:brand "lipkg"
                          :clone-from "merp-template"])
                      :autoboot false
                      :recreate 1
                      ;(if ,with-dataset
                         [:datasets ["rpool/test-zone-dataset"]] [])
                      (zone-fs "/var/tmp/tests"
                               :special (string (os/getenv "GURP_TEST_DIR") "/tests"))
                      (zone-network "t_gurp_net0"
                                    :allowed-address "192.168.1.199/24"
                                    :defrouter "192.168.1.1")
                      :dns {:domain "lan.id264.net"
                            :nameservers ["192.168.1.53" "192.168.1.1"]}
                      :exec-in [(string "/usr/bin/judge "
                                        (if ,test-basenode "/var/tmp/tests/judge/test-basenode.janet ")
                                        "/var/tmp/tests/judge/test-" ,config ".janet")]
                      :bootstrap-from (string "/var/tmp/tests/config/" ,config ".janet"))

         (if (and ,with-dataset ,remove-after)
           (zfs/remove "rpool/test-zone-dataset"))

         (if ,remove-after
           (zone/remove "merp-zone"))))
