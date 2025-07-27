(declare-project
  :name "merp"
  :description "MERP tests GURP"
  :dependencies ["https://github.com/andrewchambers/janet-sh.git"
                 "https://github.com/ianthehenry/judge.git"])

(declare-executable
  :name "merp"
  :entry "main.janet")
