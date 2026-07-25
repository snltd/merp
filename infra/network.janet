# Network definition
# 
# Three etherstubs, which we'll name to make our code clearer
# 
(def stub/dmz "mstub1") # 10.1.0.0/24
(def stub/mgmt "mstub2") # 10.2.0.0/24
(def stub/metrics "mstub3") # 10.3.0.0/24

(def internet "192.168.1.1") # Internet gateway IP
(def physical-nic "e1000g0") #(-> (fact :physical-links) (keys) (first)))

(def dns-server "1.1.1.1")

(def network
  {:host "192.168.1.0"
   :dmz "10.1.0.0"
   :mgmt "10.2.0.1"
   :metrics "10.3.0.1"})

(def prefix
  {:host 24
   :dmz 24
   :mgmt 24
   :metrics 24})

# A map of IP addresses
(def addr
  {# Router zone
   :router/host "192.168.1.101" # you might have to change this
   :router/dmz "10.1.0.1"
   :router/mgmt "10.2.0.1"
   :router/metrics "10.3.0.1"

   # DMZ zones
   :web "10.1.0.10" # zone: web application 
   :db "10.1.0.20" # zone: database 

   # Management zones
   :gurp "10.2.0.10" # zone: gurp server
   :proxy "10.2.0.20" # zone: proxy for pkg downloads
   :dns "10.2.0.53" # zone: DNS server

   # Metrics zones
   :vm "10.3.0.10" # VictoriaMetrics
   :grafana "10.3.0.20" # Grafana

   # Gold zone
   :gold "192.168.1.102" # only used when you create the gold zone
})

(def proxy-port 3128)

(def dns {:nameservers [dns-server]})

(defn cidr [name network]
  (string (addr name) "/" (prefix network)))
