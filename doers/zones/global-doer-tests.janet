(import ./site)

# Create an OmniOS bhyve zone, and copy an SSH key into it

(host "global-doer-tests"
      (zone/ensure site/global-test-zone-name
                   :brand "bhyve"
                   :autoboot false
                   :recreate 1
                   :image "https://downloads.omnios.org/media/stable/omnios-r151056.cloud.zfs.zst"
                   (zone/network "merp_bhyv0"
                                 :allowed-address (string site/global-test-zone-ip
                                                          "/"
                                                          site/ngz-netmask)
                                 :global-nic "auto")
                   (zone/bhyve
                     :ram "2G"
                     :vcpus 2
                     :boot-volume site/bhyve-boot-vol
                     :cloudinit-struct
                     {:meta-data (cloudinit-meta-data site/global-test-zone-name)

                      :user-data
                      {:users
                       [{:name "root"
                         :ssh_authorized_keys [(string (slurp site/path-to-ssh-pubkey))]}]}

                      :network-config
                      {:network
                       {:version 2
                        :ethernets
                        {:vioif0
                         {:addresses [site/global-test-zone-ip]
                          :mtu 1500
                          :nameservers {:addresses [site/local-dns-server
                                                    site/ngz-dns-server]
                                        :search [site/ngz-dns-domain]}
                          :routes [{:to "0.0.0.0/0"
                                    :via site/ngz-router}]}}}}})))
