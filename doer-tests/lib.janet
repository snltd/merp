(use judge)
(use sh)
(import ./site)

(defn gurp-example
  "Returns a Gurp example, from the gurp codebase. Arg is like 'file/ensure-01'"
  [example]
  (string (slurp (string site/example-dir "/" example ".janet"))))

(defn in-global []
  (when (not (= "global\n" ($< /bin/zonename)))
    (eprint "ERROR: not in global zone")
    (os/exit 1)))

(defn present?
  "Does a file or directory exist?"
  [dir]
  (truthy? (os/stat dir)))

(defn absent?
  "Does a file or directory NOT exist?"
  [dir]
  (not (present? dir)))

(defn parse-changes
  "Extract the number of changes from Gurp log output"
  [output]
  (when-let [m (peg/match ~(* (thru "changes: ") (<- :d+)) output)]
    (scan-number (first m))))

(defmacro apply-fails
  "Apply the given input, which is expected to fail, with 'pattern' in the
  Gurp output"
  [input pattern]
  ~(with-syms [$buffer $out]
     (def $buffer @"")
     (def $out ($?* @[,site/gurp 'apply '--exec ,input :> [stdout $buffer]]))
     (if-not (string/find ,pattern $buffer)
       (error
         (string "did not find '" ,pattern "' in Gurp output:\n" $buffer)))
     (= $out false)))

(defmacro apply-changes
  "Apply the given input and return the number of changes"
  [input &opt show-output]
  ~(with-syms [$log-line $out]
     (def $buffer @"")
     (def $out ($?* @[,site/gurp 'apply '--dump-diffs '--exec ,input :> [stdout $buffer]]))
     (if-not $out
       (error (string "expected apply to succeed: failed with\n" $buffer)))
     (if ,show-output
       (print $buffer))
     (parse-changes $buffer)))

(defmacro apply-changes-noop
  "Apply the given input with a noop and return the number of changes that
  would be made"
  [input]
  ~(with-syms [$log-line $out]
     (def $buffer @"")
     (def $out ($?* @[,site/gurp 'apply '--noop '--exec ,input :> [stdout $buffer]]))
     (if-not $out
       (error (string "expected noop-apply to succeed: failed with\n" $buffer)))
     (parse-changes $buffer)))

(defn cat [& resources]
  (string/join resources " "))

(defn resource
  "Build a resource"
  [resource-call & spec]
  (string
    "("
    resource-call
    " "
    (string/join (map |(string/format "%j" $) spec) " ")
    ")"))

(defn metadata
  "Get owner, group, and mode for a file or directory"
  [path]
  ($< stat -c "%U:%G %A" ,path))

(defn etherstub-exists? [stub]
  ($? dladm show-etherstub ,stub :> [stdout :null] :> [stderr :null]))

(defn bridge-exists? [stub]
  ($? dladm show-bridge ,stub :> [stdout :null] :> [stderr :null]))

(defn vnic-exists? [vnic]
  ($? dladm show-vnic ,vnic :> [stdout :null] :> [stderr :null]))

(defn ip-interface-exists? [interface]
  ($? ipadm show-if ,interface :> [stdout :null] :> [stderr :null]))

(defn ip-address-exists? [addr-name]
  ($? ipadm show-addr ,addr-name :> [stdout :null] :> [stderr :null]))

(defn network-flow-exists? [flow-name]
  ($? flowadm show-flow ,flow-name :> [stdout :null] :> [stderr :null]))

(defn pkg-is-installed? [pkg]
  ($? pkg list ,pkg :> [stdout :null] :> [stderr :null]))

(defn publisher-exists? [pub]
  ($? pkg publisher ,pub :> [stdout :null] :> [stderr :null]))

(defn group-exists? [group &opt gid]
  (def pattern (string group ":" (if gid (string ":" gid)) ":"))
  (truthy? (string/find pattern (slurp "/etc/group"))))

(defn ping? [address]
  ($? /usr/sbin/ping ,address 1 :> [stdout :null]))

(defn service-exists? [svc]
  ($? svcs ,svc :> [stderr :null] :> [stdout :null]))

(defn user-exists? [user]
  (truthy?
  (string/find (string/format "\n%s:" user) (slurp "/etc/passwd"))))
