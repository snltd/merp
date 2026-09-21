(import ../network)

(def major-ver 9)
(def minor-ver 20)
(def ver-str (string/format "named-%d.%d" major-ver minor-ver))
(def short-ver-str (string major-ver minor-ver))
(def conf-dir (pathcat "/etc/opt/ooce" ver-str))
(def var-dir (pathcat "/var/opt/ooce/named" ver-str))
(def db-dir (pathcat var-dir "namedb"))
(def ser_no (os/time))

(def db-10-x-x-template (indoc `
  $TTL 1h
  @ IN SOA {{ this-host }}.{{ local-domain }}. root.{{ local-domain }}. (
    {{ serial-no }} 1h 1h 1w 1h) ;serial

  @ IN NS {{ this-host }}.{{ local-domain }}.

  {{ a-records }}
  `))

(def db-local-domain-template (indoc `
  $TTL 3h
  @ IN SOA {{ this-host }}.{{ local-domain }}. root.{{ local-domain }}. (
    {{ serial-no }} 3h 1h 1w 1h) ;serial

  @ IN NS {{ this-host }}.{{ local-domain }}.

  {{ a-records }}`))

(def named-conf-template (slurp (qualify-from-path "dns-server/named-conf")))
(def db-127-0-0-template (slurp (qualify-from-path "dns-server/db-127-0-0")))

(defn relevant-records
  [subnet-prefix]

  (defn filter-fn
    [[name addr]]
    (and (string/has-prefix? subnet-prefix addr)
         (not (string/has-prefix? :router name))))

  (filter filter-fn (pairs network/addr)))

(defn subnet-a-records
  [subnet-prefix]
  (string/join
    (sort-by num-field-sort
             (catseq [[name ip] :in (relevant-records subnet-prefix)]
               (string/format "%-5s IN PTR %s.%s."
                              (last (string/split "." ip))
                              name
                              network/local-domain)))
    "\n"))

(defn db-local-domain-a-records
  []
  (string/join
    (sort-by |(int/u64 (last (string/split "." $)))
             (catseq [[hostname ip] :in (relevant-records "10.")]
               (string/format "%-20s IN A %s" hostname ip)))
    "\n"))

(role dns-server
      (pkg/ensure (string "ooce/network/bind-" short-ver-str))

      (directory/ensure (pathcat db-dir "slave")
                        :owner "named"
                        :group "named"
                        :mode "0750")

      (svc/ensure (string "svc:/network/dns:named" short-ver-str)
                  :restarted-by [(this :file "named-conf")
                                 (this :file "db-127")
                                 (this :file "db-10-0-1")
                                 (this :file "db-local")]
                  :state "online")

      (file/ensure (pathcat conf-dir "named.conf")
                   :label "named-conf"
                   :content (template-out named-conf-template
                                          {:conf-dir conf-dir
                                           :local-domain network/local-domain
                                           :var-dir var-dir}))

      (file/ensure (pathcat db-dir "master" "db.127.0.0")
                   :label "db-127"
                   :ignore-pattern ".*serial"
                   :owner "named"
                   :group "named"
                   :content (template-out
                              db-127-0-0-template
                              {:this-host (fact :hostname)
                               :local-domain network/local-domain}))

      (loop [subnet :in ["10.1.0" "10.2.0" "10.3.0"]]
        (file/ensure (pathcat db-dir "master" (string "db." subnet))
                     :label (string "db-" subnet)
                     :ignore-pattern ".*serial"
                     :owner "named"
                     :group "named"
                     :content (template-out db-10-x-x-template
                                            {:this-host (fact :hostname)
                                             :local-domain network/local-domain
                                             :serial-no (os/time)
                                             :a-records (subnet-a-records subnet)})))

      (file/ensure (pathcat db-dir "master" (string "db." network/local-domain))
                   :label "db-local"
                   :owner "named"
                   :group "named"
                   :ignore-pattern ".*serial"
                   :content (template-out db-local-domain-template
                                          {:this-host (fact :hostname)
                                           :local-domain network/local-domain
                                           :serial-no (os/time)
                                           :a-records (db-local-domain-a-records)})))
