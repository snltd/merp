(import ./site)

# Create an OmniOS bhyve zone, and bootstrap it with Gurp.

(host "serv"
      (zone/ensure site/bhyve-dev-zone-name
                   :brand "bhyve"
                   :autoboot false
                   :recreate 1
                   :image "https://downloads.omnios.org/media/stable/omnios-r151056.cloud.zfs.zst"
                   (zone/network "serv_merp0"
                                 :allowed-address (string site/bhyve-dev-zone-ip
                                                          "/"
                                                          site/ngz-netmask)
                                 :global-nic "auto")
                   (zone/bhyve
                     :ram "2G"
                     :vcpus 2
                     :boot-volume site/dev-zone-boot-vol
                     :cloudinit-struct
                     {:meta-data (cloudinit-meta-data site/bhyve-dev-zone-name)

                      :user-data
                      {:runcmd ["zfs destroy -r rpool/home"
                                "mkdir -p /opt/site/bin"
                                "wget -O /opt/site/bin/gurp http://gurp:1867/v1/gurp-binary"
                                "chmod +x /opt/site/bin/gurp"
                                "/opt/site/bin/gurp apply --server=gurp --metrics-to=metrics >/var/tmp/gurp-bootstrap-log 2>&1"]}
                      :network-config
                      {:network
                       {:version 2
                        :ethernets
                        {:vioif0
                         {:addresses [site/bhyve-dev-zone-ip]
                          :mtu 1500
                          :nameservers {:addresses [site/local-dns-server
                                                    site/ngz-dns-server]
                                        :search [site/ngz-dns-domain]}
                          :routes [{:to "0.0.0.0/0"
                                    :via site/ngz-router}]}}}}})))
