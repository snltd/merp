(use sh)
(use judge)

(deftest "builder zone"
  (test ($< zfs list -Ho "name,mountpoint" fast/zone/build/build)
        "fast/zone/build/build\t/build\n")

  (test ($< zfs list -Ho "name,mountpoint" fast/zone/build/config)
        "fast/zone/build/config\t/build/configs\n")

  (test ($< zfs list -Ho "name,mountpoint" fast/zone/build)
        "fast/zone/build\tnone\n")

  (def installed-pkgs (string/split "\n" ($< pkg list -Ho name)))

  (test
    (all |(has-value? installed-pkgs $)
         ["developer/build/onbld"
          "developer/illumos-tools"
          "developer/omnios-build-tools"
          "network/rsync"
          "ooce/developer/aarch64-sysroot"
          "ooce/extra-build-tools"
          "ooce/omnios-build-tools"
          "ooce/ooceapps"
          "sysdef/audio/lame"
          "sysdef/runtime/janet"]) true)

  (test
    # Redact the version, because that will change
    ($<_ pkg publisher |sed "s|/r[0-9]*/|/version/|")
    "PUBLISHER                   TYPE     STATUS P LOCATION\nomnios                      origin   online F https://pkg.omnios.org/version/core/\nomnios                      mirror   online F https://us-west.mirror.omnios.org/version/core/\nextra.omnios                origin   online F https://pkg.omnios.org/version/extra/\nextra.omnios                mirror   online F https://us-west.mirror.omnios.org/version/extra/\nsysdef                      origin   online F http://pkg.lan.id264.net/"))
