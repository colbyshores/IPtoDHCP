
get '/rest/:field/:parameter/:page' do
  response = sortdata(params[:parameter], params[:field])
  pageindex =  (params[:page].to_i * 25) #- totalpages
  if pageindex < 25
    startindex = 0
  else
    startindex = pageindex - 25
  end
  restdata = '['
  begin
  response[startindex..pageindex].each_with_index do |data, index|
    if (startindex + index) == pageindex
      restdata += JSON.generate({:hostname => data.hostname, :description => data.description, :macaddress => data.macaddress, :ipaddress => data.ipaddress, :device => data.device, :environment => data.environment})
      restdata += "\n"
    else
      restdata += JSON.generate({:hostname => data.hostname, :description => data.description, :macaddress => data.macaddress, :ipaddress => data.ipaddress, :device => data.device, :environment => data.environment})
      restdata += "\n,"
    end
  end
    "#{restdata}]"
  rescue => e
    "{\"data\":\"false\"}"
  end
end











get '/rest/:field/:parameter' do
=begin
  #compare the url input to the encrypted password and salt
  if "#{UnixCrypt::SHA512.build("#{$config[:stageapipassword]}", "#{$config[:stageapisalt]}").tr('/','')}" == "#{params[:field]}"
    returnrecord = Conf_host.where("ipaddress = '#{params[:parameter]}'").first
    #environment must be Development to allow it to interface with Docker's reaping process.
    #this prevents any Production and QA machines from being destroyed.
    if returnrecord.environment == 'Development'
      Networkdevice.create(:ipaddress => returnrecord.ipaddress, :device => returnrecord.device)
      Conf_host.destroy_all("ipaddress = '#{returnrecord.ipaddress}'")    #remove the ip address from the second database'
      "returned #{returnrecord.ipaddress} to pool"
    else
      "unable to #{returnrecord.ipaddress} to pool"
    end
  else
=end
      response = sortdata(params[:parameter], params[:field])
      restdata = '['
      response.each_with_index do |data, index|
        if index == response.size - 1
          restdata += JSON.generate({:hostname => data.hostname, :description => data.description, :macaddress => data.macaddress, :ipaddress => data.ipaddress, :device => data.device, :environment => data.environment})
          restdata += "\n"
        else
          restdata += JSON.generate({:hostname => data.hostname, :description => data.description, :macaddress => data.macaddress, :ipaddress => data.ipaddress, :device => data.device, :environment => data.environment})
          restdata += "\n,"
        end
      end
      "#{restdata}]"
    #end
end

get '/rest/:field' do
  response = sortdata('', params[:field])
  restdata = '['
  response.each_with_index do |data, index|
    if index == response.size - 1
      restdata += JSON.generate({:hostname => data.hostname, :description => data.description, :macaddress => data.macaddress, :ipaddress => data.ipaddress, :device => data.device, :environment => data.environment})
      restdata += "\n"
    else
      restdata += JSON.generate({:hostname => data.hostname, :description => data.description, :macaddress => data.macaddress, :ipaddress => data.ipaddress, :device => data.device, :environment => data.environment})
      restdata += "\n,"
    end
  end
  "#{restdata}]"
end
