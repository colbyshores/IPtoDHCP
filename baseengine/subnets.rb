
def getsubnets
  field ="<html>"
  field << "<title>
            IP to DHCP Subnet Engine
          </title>
          <head>
            <link href='/bootstrap.css' rel='stylesheet'>
            <style type='text/css'>
              body {
                padding: 100px;
              }
            </style>
          </head>
          <body>
            <form action='http://#{$config[:host]}:#{$config[:port]}/subnets' method='POST' enctype='multipart/form-data'>
              <table border='0'width='940' align='center'>
              <tr>
               <td>
                <a href='/'>IP to DHCP Manager</a>
               </td>
              </tr>
              </table>
        "

  data = Conf_subnet.all
  #iterate through all the subnet data
  @counter = 0
  data.each do |data|
    @group = data.group
    @device = data.device
    @routing = data.routing
    @subnet = data.subnet
    @netmask = data.netmask
    @domain = data.domain
    @mtu = data.mtu
    @dns1 = data.dns1
    @dns2 = data.dns2
    @iprange1 = data.iprange1
    @iprange2 = data.iprange2
    field << "#{erb :subnettable}"
    @counter += 1
  end

  field << "    <br><br>
                <div style='text-align:center'>
                   <input style='display: inline-block; float: middle;' type='submit'>
                </div>
               </form>
             </body>
           </html>"
  return field
end

def postsubnets
  data = Conf_subnet.all
  counter = 0
  data.each do |data|
    counter += 1
  end
  counter2 = 0
  Conf_subnet.delete_all
  while counter2 != counter do
    Conf_subnet.create do |data|
      data.group = "PNAP"
      data.device = params["device_#{counter2}"]
      data.routing = params["routing_#{counter2}"]
      data.subnet = params["subnet_#{counter2}"]
      data.netmask = params["netmask_#{counter2}"]
      data.domain = params["domain_#{counter2}"]
      if params["mtu_#{counter2}"] != ''
        if params["mtu_#{counter2}"] =~ /^[\d+]/
          if params["mtu_#{counter2}"].to_i < 32768 and params["mtu_#{counter2}"].to_i > 67
            data.mtu = params["mtu_#{counter2}"]
          end
        else
          data.mtu = 1500
        end
      else
        data.mtu = 1500
      end
      data.dns1 = params["dns1_#{counter2}"]
      data.dns2 = params["dns2_#{counter2}"]
      data.iprange1 = params["iprange1_#{counter2}"]
      data.iprange2 = params["iprange2_#{counter2}"]
    end
    counter2 += 1
  end
  writedhcp
  getsubnets
end