(def site-dir "/opt/site")
(def site-bin (string site-dir "/bin"))
(def site-etc (string site-dir "/etc"))
(def site-smf-manifest (string site-dir "/lib/smf/manifest"))
(def site-smf-method (string site-dir "/lib/smf/method"))
(def cron-log-dir "/var/log/cron_jobs")
(def local-domain "lan.id264.net")
(def big-pool "big")
(def fast-pool "fast")
(def workstation-ip "192.168.1.9")
(def backup-clients ["lobster" "kronos"])

(def dns-map
  {:a-records {:router "192.168.1.1"
               :kronos "192.168.1.2"
               :serv "192.168.1.5"
               :kate "192.168.1.8"
               :slim "192.168.1.9"
               :shaired "192.168.1.10"
               :gold-pkgsrc-a "192.168.1.17"
               :gold-pkgsrc-b "192.168.1.18"
               :gold-lipkg-a "192.168.1.19"
               :gold-lipkg-b "192.168.1.20"
               :st2000-lom "192.168.1.130"
               :st2000 "192.168.1.150"
               :ds "192.168.1.231"
               :printer "192.168.1.240"
               :pch "192.168.1.241"
               :skybox "192.168.1.242"
               :sw-16p "192.168.1.251"
               :sw-5p "192.168.1.252"
               :repeater "192.168.1.253"}

   :zones {:ws "192.168.1.21"
           :ansible "192.168.1.22"
           :build "192.168.1.23"
           :pkg "192.168.1.24"
           :media "192.168.1.25"
           :grafana "192.168.1.26"
           :mariadb "192.168.1.27"
           :backup "192.168.1.29"
           :metrics "192.168.1.30"
           :cron "192.168.1.31"
           :fs "192.168.1.33"
           :www-proxy "192.168.1.40"
           :www-cassingle "192.168.1.41"
           :www-meetup "192.168.1.42"
           :www-sysdef "192.168.1.43"
           :www-records "192.168.1.44"
           :audit "192.168.1.45"
           :dns "192.168.1.53"
           :docker "192.168.1.79"
           :k8s-00 "192.168.1.80"
           :k8s-01 "192.168.1.81"
           :k8s-02 "192.168.1.82"}

   :cname-records {:switch "sw-16p"
                   :lexmark "printer"
                   :mysql "mariadb"
                   :www "www-proxy"
                   :cassingle "serv-www-proxy"
                   :meetup "serv-www-proxy"
                   :sysdef "serv-www-proxy"
                   :records "serv-www-proxy"}})

(def zone-dns
  {:domain local-domain
   :nameservers ["192.168.1.53" "192.168.1.1"]})
