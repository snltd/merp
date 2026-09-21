# Network definition
# 
# Three etherstubs, which we'll name to make our code clearer
# 
(def stub/dmz "mstub1")     # 10.1.0.0/24  DMZ
(def stub/mgmt "mstub2")    # 10.2.0.0/24  management
(def stub/metrics "mstub3") # 10.3.0.0/24  metrics

(def internet "192.168.1.1") # Internet gateway IP
(def physical-nic "e1000g0") #(-> (fact :physical-links) (keys) (first)))

(def local-domain "merp.test")

(def external-dns "1.1.1.1")

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
   :mrouter/host "192.168.1.101" # you might have to change this
   :mrouter/dmz "10.1.0.1"
   :mrouter/mgmt "10.2.0.1"
   :mrouter/metrics "10.3.0.1"

   # DMZ zones
   :mweb "10.1.0.10" # zone: web application 
   :mdb "10.1.0.20" # zone: database 

   # Management zones
   :mgurp "10.2.0.10" # zone: gurp server
   :mproxy "10.2.0.20" # zone: proxy for pkg downloads
   :mdns "10.2.0.53" # zone: DNS server

   # Metrics zones
   :mvm "10.3.0.10" # VictoriaMetrics
   :mgrafana "10.3.0.20" # Grafana

   # Gold zone
   :gold "192.168.1.102" # only used when you create the gold zone
})

(def proxy-port 3128)

(defn cidr [name network]
  (string (addr name) "/" (prefix network)))
