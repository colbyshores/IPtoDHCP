def writedhcp
  if File.exists?($config[:dhcp_conf])
      File.delete($config[:dhcp_conf])
  end
  data = Conf_host.all.order(:hostname)
  #work in progress DHCP Subnet engine
  dhcphost = subnet
  data.each do |data|
    dhcphost += "# #{data.device} - #{data.environment}\n"
    dhcphost += "# #{data.description}\n"
    dhcphost += "host #{data.hostname} {\n"
    dhcphost += "    option host-name \"#{data.hostname}\";\n"
    dhcphost += "    hardware ethernet #{data.macaddress};\n"
    dhcphost += "    fixed-address #{data.ipaddress};\n"
    dhcphost += "}\n\n"
  end
  File.open($config[:dhcp_conf], 'w') {|f| f.write(dhcphost) }
  system($config[:dhcp_restart])
end

def subnet
  data = Conf_subnet.all
  subnet = ''
  data.each do |data|
    subnet += "##{data.group}\n"
    subnet += "##{data.device}\n"
    subnet += "subnet #{data.subnet} netmask #{data.netmask}{\n"
    if data.routing != ''
      subnet += "    option routers              #{data.routing};\n"
    end
    subnet += "    option subnet-mask          #{data.netmask};\n"
    if data.domain != ''
      subnet += "    option domain-name          \"#{data.domain}\";\n"
    end
    if data.dns1 != '' or data.dns2 != ''
      subnet += "    option domain-name-servers  #{data.dns1}, #{data.dns2};\n"
    end
    if data.iprange1 != '' or data.iprange2 != ''
      subnet += "    range                       #{data.iprange1} #{data.iprange2};\n"
    end
    subnet += "    option interface-mtu        #{data.mtu};\n"
  subnet += "}\n"
  end
  return subnet
end