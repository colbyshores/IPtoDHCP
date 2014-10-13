class ParseData
  def initialize(hostname, description, ipaddress, environment, search)
    @hostname = hostname.slice(0..254)
    @description = description.slice(0..254)
    @ipaddress = ipaddress
    @environment = environment.slice(0..16)
    @search = search
    @device = ''
  end

  def ping(host, timeout=5, service="echo")
    if host == ''
      return false
    end
    begin
      timeout(timeout) do
        s = TCPSocket.new(host, service)
        s.close
      end
    rescue Errno::ECONNREFUSED
      return true
    rescue Timeout::Error, StandardError
      return false
    end
    return true
  end

  def verifyfields(checkboxstatus)
    if @search != 'on'
      errorcodes = ''
      #only poll the ipaddress against ping if the checkping is enabled
      if $config[:checkping]
        pingtest = ping(@ipaddress, 2)
      end

      #if macaddress does not fail during processing and it is not empty save the data
      macaddress = IpToMac(@ipaddress)
      #if macaddress is able to be calculated then determine device type off IP octets
      macaddress ? @device = IpToDevice(@ipaddress) : false


      hostnametest = Conf_host.where("hostname = '#{@hostname}'").first
      if @ipaddress != '' and @hostname != '' and macaddress != false and !macaddress.nil?
        #verify duplicate hostnames, do not write data if there is a duplicate entry
        if !hostnametest
          #if ping flag is checked then verify it doesnt exist before writing data
          if $config[:checkping] == true and pingtest == false
            writedata(macaddress)
            #writedhcp
          else
            if !$config[:checkping] #!= true
              writedata(macaddress)
              #writedhcp
            end
          end
        end
      end
      if !checkboxstatus #!= true
        errorstatus = Hash.new
        if @hostname == ''
          errorstatus[:hostname] = 'Hostname Empty'
        else
          if hostnametest
            errorstatus[:hostname] = 'Hostname in use'
          end
        end
        if @ipaddress == ''
          errorstatus[:ipaddress] = 'IP Address Empty'
        end
        if macaddress == false
          errorstatus[:macaddress] = 'IP Address Error, unable to calculate MAC Address'
        end
        if $config[:checkping] == true and pingtest == true
          errorstatus[:ping] = 'Able to ping IP Address Requested.  Remove server to continue'
        end
        errorstatus.to_a.collect{|item| errorcodes += "#{item[1]}<br><br>"}.join
      end
      writedhcp #always render a new dhcpd conf file after every check
      return errorcodes
    else
      #return nothing so the error popup doesnt render
      return ''
    end
  end

  def writedata(macaddress)
    if Networkdevice.where("ipaddress = '#{@ipaddress}' AND device = '#{@device}'").first
      Networkdevice.where(:ipaddress => @ipaddress).destroy_all    #remove the ip address from the second database
      Conf_host.create(:macaddress => macaddress, :ipaddress => @ipaddress, :hostname => @hostname.tr(" ", "-"), :description => @description, :device => @device, :environment => @environment)
    end
  end
end

def sortdata(sort, searchfield = '')
  case sort
    when "hostname"
      data = Conf_host.all.order(:hostname)
    when "hostdescription"
      data = Conf_host.all.order(:description)
    when "macaddress"
      data = Conf_host.all.order(:macaddress)
    when "ipaddress"
      data = Conf_host.all.order(:ipaddress)
    when "device"
      data = Conf_host.all.order(:device)
    when "environment"
      data = Conf_host.all.order(:environment)
    else
      data = Conf_host.querydata(sort, searchfield)
  end
  return data
end

def destroycheckbox(sorttype)
  retval = false
  data = sortdata(sorttype)
  data.each do |datablock|
    if params["checkbox_#{datablock.id}"] == 'on'
      #debugging to determine selection
      #puts datablock.id
      #add the IP address block back to the Network Device Listing
      Networkdevice.create(:ipaddress => datablock.ipaddress, :device => datablock.device)
      Conf_host.destroy_all("ipaddress = '#{datablock.ipaddress}'")    #remove the ip address from the second database'
      #return the checkbox status as selected
      retval = true
    end
  end
  #return the checkbox status as selected/removed or not selected/removed
  if retval
    return true
  else
    return false
  end
end

def getpage(page)
  if $config[:authenticate]
    #verify session has been created
    if session?
      spreadsheetform(page)
    else
      redirect '/login'
    end
  else
    spreadsheetform(page)
  end
end

def postpage(page)
  updatedb = ParseData.new(params[:host], params[:description], params[:ipaddress], params[:environment], params[:search])
  if params[:search] == 'on'
    #ensure only one field is able queried for search
    if params[:host] != '' and params[:description] != ''
      spreadsheetform(page, updatedb.verifyfields(true))
    end
    if params[:ipaddress] != '' and params[:description] != ''
      spreadsheetform(page, updatedb.verifyfields(true))
    end
    if params[:ipaddress] != '' and params[:host] != ''
      spreadsheetform(page, updatedb.verifyfields(true))
    end
    if params[:host] != ''
      spreadsheetform('', updatedb.verifyfields(true), params[:host], 'hostname')
    else
      if params[:description] != ''
        spreadsheetform('', updatedb.verifyfields(true), params[:description], 'description')
      else
        if params[:ipaddress] != ''
          spreadsheetform('',  updatedb.verifyfields(true), params[:ipaddress], 'ipaddress')
        else
          #if all else fails stay on the same page
          getpage(page)
        end
      end
    end
  else
    spreadsheetform(page, updatedb.verifyfields(destroycheckbox(page)))
  end
end

#error do
#  @error = request.env['sinatra_error'].name
#  haml :'500'
#end

get '/:getpage' do
  case params[:getpage]
    when 'hostname'
      getpage(params[:getpage])
    when 'hostdescription'
      getpage(params[:getpage])
    when 'ipaddress'
      getpage(params[:getpage])
    when 'macaddress'
      getpage(params[:getpage])
    when 'device'
      getpage(params[:getpage])
    when 'environment'
      getpage(params[:getpage])
    when 'subnets'
      if $config[:authenticate]
        #verify session has been created before allowing subnets
        if session?
          getsubnets
        else
          redirect '/login'
        end
      else
        getsubnets
      end
  end
end

get '/' do
  getpage('hostname')
end

post '/:postpage' do
  case params[:postpage]
    when 'hostname'
      postpage(params[:postpage])
    when 'hostdescription'
      postpage(params[:postpage])
    when 'ipaddress'
      postpage(params[:postpage])
    when 'macaddress'
      postpage(params[:postpage])
    when 'device'
      postpage(params[:postpage])
    when 'environment'
      postpage(params[:postpage])
    when 'subnets'
      postsubnets
  end
end

post '/' do
  postpage('hostname')
end
