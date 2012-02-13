require 'snmp'
include SNMP

host = ARGV[0] || 'localhost'

manager = Manager.new(:host => host)
interface_number = manager.get_value("IF-MIB::ifNumber.0").to_i
if_descr = []
last_varbind = "IF-MIB::ifDescr"
varbinds_seen = 0
while varbinds_seen < interface_number
  message = manager.get_bulk(0, interface_number-varbinds_seen, last_varbind)
  if_descr = (if_descr + message.varbind_list).flatten(1)
  varbinds_seen = if_descr.length
  last_varbind = if_descr.last.name.to_s
end
puts "The description of all interfaces:"
if_descr.each{ |if_name| 
  puts if_name.value
}
