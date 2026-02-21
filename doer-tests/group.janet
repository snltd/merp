(use judge)
(use sh)
(use ./lib)

(def group-1 "merpgrp")

# Noop should do nothing
(test (apply-changes-noop (resource "group/ensure" group-1 :gid 1867)) 1)
(test ($? grep -q ,group-1 /etc/group) false)

# Add a group. Second should make no change nothing
(test (apply-changes (resource "group/ensure" group-1 :gid 1867)) 1)
(test (apply-changes (resource "group/ensure" group-1 :gid 1867)) 0)
(test ($< grep ,group-1 /etc/group) "merpgrp::1867:\n")

# Change the GID
(test (apply-changes (resource "group/ensure" group-1 :gid 1991)) 1)
(test ($< grep ,group-1 /etc/group) "merpgrp::1991:\n")

# Remove with noop should do nothing
(test (apply-changes-noop (resource "group/remove" group-1)) 1)
(test ($< grep ,group-1 /etc/group) "merpgrp::1991:\n")
 
# Remove test group
(test (apply-changes (resource "group/remove" group-1)) 1)
(test ($? grep -q ,group-1 /etc/group) false)

# Try to remove a protected group. You're doing this somewhere safe, right?
(test (apply-fails (resource "group/remove" "root") "protected resource: root") true)
