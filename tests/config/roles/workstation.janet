(role workstation
      (publisher/ensure "sysdef" :uri "http://pkg.lan.id264.net/")

      (pkg/ensure "ooce/application/imagemagick")
      (pkg/ensure "ooce/audio/flac")
      (pkg/ensure "ooce/editor/helix")
      (pkg/ensure "ooce/multimedia/ffmpeg")
      (pkg/ensure "sysdef/audio/lame")
      (pkg/ensure "sysdef/audio/mp3val")
      (pkg/ensure "sysdef/audio/shntool")
      (pkg/ensure "sysdef/util/little-tools")
      (pkg/ensure "sysdef/util/zfs-tools"))
