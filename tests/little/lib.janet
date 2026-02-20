(use judge)
(use sh)
(import ./site)

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

(defmacro apply-changes
  "Apply the given input and return the number of changes"
  [input]
  ~(with-syms [$log-line $out]
     (def $out ($<* @[,site/gurp 'apply '--exec ,input]))
     (parse-changes $out)))

(defmacro apply-changes-noop
  "Apply the given input with a noop and return the number of changes that
  would be made"
  [input]
  ~(with-syms [$log-line $out]
     (def $out ($<* @[,site/gurp 'apply '--noop '--exec ,input]))
     (parse-changes $out)))

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
  ($< stat -c "%U:%G %A" ,path)
)
