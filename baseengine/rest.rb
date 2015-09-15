
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
