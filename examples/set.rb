require 'snmp'
include SNMP

host = ARGV[0] || 'localhost'

manager = Manager.new(:host => host, :port => 161)
varbind = VarBind.new("1.3.6.1.2.1.1.5.0", OctetString.new("System Name"))
manager.set(varbind)
manager.set_value("sysName.0", OctetString.new("System Name1"))
