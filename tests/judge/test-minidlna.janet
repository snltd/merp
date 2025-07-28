(use judge)
(use sh)

(deftest "minidlna server zone"
  (test ($< /bin/pkg list -Ho name minidlna)
    "ooce/multimedia/minidlna\n")

  (test ($< /bin/stat -c "%U:%G %A %s" /opt/site/lib/smf/method/minidlna.sh)
    "root:root -rwxr-xr-x 748\n")

  (test ($< /bin/stat -c "%U:%G %A %s" /opt/site/lib/smf/manifest/gurp-minidlna.xml)
    "root:root -rw-r--r-- 1434\n")
  
  (test ($< /bin/stat -c "%U:%G %A %s" /etc/opt/ooce/minidlna/minidlna.conf)
    "root:root -rw-r--r-- 190\n")

  (test ($< /bin/svcs -Ho state svc:/sysdef/multimedia/minidlna:default)
    "online\n")

  (test ($< /usr/sbin/svccfg export minidlna)
    "<?xml version='1.0'?>\n<!DOCTYPE service_bundle SYSTEM '/usr/share/lib/xml/dtd/service_bundle.dtd.1'>\n<service_bundle type='manifest' name='export'>\n  <service name='sysdef/multimedia/minidlna' type='service' version='0'>\n    <create_default_instance enabled='true'/>\n    <single_instance/>\n    <dependency name='physical' grouping='require_all' restart_on='none' type='service'>\n      <service_fmri value='svc:/network/physical:default'/>\n    </dependency>\n    <dependency name='fs-local' grouping='require_all' restart_on='none' type='service'>\n      <service_fmri value='svc:/system/filesystem/local'/>\n    </dependency>\n    <exec_method name='start' type='method' exec='/opt/site/lib/smf/method/minidlna.sh' timeout_seconds='30'>\n      <method_context>\n        <method_credential user='minidlna' group='minidlna'/>\n      </method_context>\n    </exec_method>\n    <exec_method name='stop' type='method' exec=':kill' timeout_seconds='10'/>\n    <exec_method name='refresh' type='method' exec='/opt/site/lib/smf/method/minidlna.sh' timeout_seconds='60'>\n      <method_context>\n        <method_credential user='minidlna' group='minidlna'/>\n      </method_context>\n    </exec_method>\n    <stability value='Unstable'/>\n    <template>\n      <common_name>\n        <loctext xml:lang='C'>MiniDLNA - DLNA/UPnP-AV media server</loctext>\n      </common_name>\n    </template>\n  </service>\n</service_bundle>\n"))
