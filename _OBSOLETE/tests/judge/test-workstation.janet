(use sh)
(use judge)

(deftest "workstation"
  (def installed-pkgs (string/split "\n" ($< pkg list -Ho name)))

  (test
    (all |(has-value? installed-pkgs $)
         ["ooce/application/imagemagick"
          "ooce/audio/flac"
          "ooce/editor/helix"
          "ooce/multimedia/ffmpeg"
          "sysdef/audio/lame"
          "sysdef/audio/mp3val"
          "sysdef/audio/shntool"
          "sysdef/util/little-tools"
          "sysdef/util/zfs-tools"]) true)

  (test
    # Redact the version, because that will change
    ($<_ pkg publisher |sed "s|/r[0-9]*/|/version/|")
    "PUBLISHER                   TYPE     STATUS P LOCATION\nomnios                      origin   online F https://pkg.omnios.org/version/core/\nomnios                      mirror   online F https://us-west.mirror.omnios.org/version/core/\nextra.omnios                origin   online F https://pkg.omnios.org/version/extra/\nextra.omnios                mirror   online F https://us-west.mirror.omnios.org/version/extra/\nsysdef                      origin   online F http://pkg.lan.id264.net/"))
