(import globals)

(defn site-cron
  "Given a script name and optional args, returns a command string which
  executes said script in site-bin and logs to script-name-log in cron-log-dir"
  [cmd-bin & args]
  (argcat
    (pathcat globals/site-bin cmd-bin)
    (splice args)
    ">"
    (pathcat globals/cron-log-dir (string cmd-bin ".log"))
    "2>&1"))

(defn ip-of
  "Gives you the IP address of the thing called name"
  [name]
  (def kname (keyword name))
  (get-in globals/dns-map [:a-records kname]
          (get-in globals/dns-map [:zones kname])))

(defn sysdef-publisher []
  (publisher/ensure "sysdef" :uri "http://pkg.lan.id264.net/"))

(defn my-test [test-role]
  (string (os/getenv "GURP_TEST_DIR") "/tests/judge/" test-role ".janet"))

(defn my-config [test-role]
  (string (os/getenv "GURP_TEST_DIR") "/tests/zones/" test-role ".janet"))

