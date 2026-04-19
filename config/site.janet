#- HELPERS --------------------------------------------------------------------
# Janet's module system makes it painful to include sh or even Gurp's DSL lib
# here, so some of this is copypasta from the latter.

(defn fields [str]
  (peg/match ~{:main (some (choice (capture :S+) 1))} str))

(defn run-cmd [cmd]
  (def proc (os/spawn (fields cmd) :p {:out :pipe :err :pipe}))
  (:wait proc)
  (def stdout (:read (proc :out) :all))
  (if (nil? stdout)
    (error (string/trim (:read (proc :err) :all)))
    (string/trim stdout)))

(defn pathcat [& chunks]
  (->
    (map |(string/trim $ "/") (tuple "" ;chunks))
    (string/join "/")))

(defn parent [path]
  (-> (string/split "/" path)
      (slice 0 -2)
      (string/join "/")))

(defn- first-entry [lines]
  (first (string/split "\n" lines)))

(defn- addr [network-base final-octet]
  (string/join [;network-base (string final-octet)] "."))

#- PATHS --------------------------------------------------------------------
(def merp-dir (parent (parent (os/realpath (dyn *current-file*)))))
(def gurp-dir (pathcat (parent merp-dir) "gurp"))
(def gurp (pathcat gurp-dir "target/debug/gurp"))
(def example-dir (pathcat gurp-dir "janet/examples"))

#- NETWORK --------------------------------------------------------------------
# Some of this stuff is a bit sketchy: assuming the netmask, taking the first
# viable looking match etc, but so far it works fine.
# You might need to change some of these, or make the code smarter.

(defn physical []
  (->>
    (run-cmd "/usr/sbin/ipadm show-if -po ifname,class")
    (string/split "\n")
    (find |(string/has-suffix? ":IP" $))
    (string/split ":")
    (first)))

(defn physical-addr []
  (->>
    (run-cmd "/usr/sbin/ipadm show-addr -po addrobj,addr")
    (string/split "\n")
    (find |(string/has-prefix? (string physical "/") $))
    (string/split ":")
    (last)))

(defn netmask [] (last (string/split "/" physical-addr)))

(defn network-addr []
  (if (= netmask "24")
    (array/slice (string/split "." physical-addr) 0 3)
    (error (string "unsupported netmask: " netmask))))

# These might clash in a dynamic environment
(defn doer-addr-1 [] (addr network-addr 123))
(defn doer-addr-2 [] (addr network-addr 124))

# #- GOLD ZONE ------------------------------------------------------------------
(def gold-zone "merp-gold-zone")
(defn gold-zone-ip [] (addr network-addr 199))
(defn gold-router [] (addr network-addr 1))

#- MISC -----------------------------------------------------------------------
(def scheduler-class "FSS")
(def zfs-root "rpool/example")
