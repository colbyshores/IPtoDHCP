get '/rest/:field/:parameter' do
  data = sortdata(params[:parameter], params[:field])
  restdata = ''
  data.each do |data|
    restdata += JSON.generate({:hostname => data.hostname, :description => data.description, :macaddress => data.macaddress, :ipaddress => data.ipaddress, :device => data.device, :environment => data.environment})
    restdata += "\n"
  end
  "#{restdata}"
end

get '/rest/:field' do
  data = sortdata('', params[:field])
  restdata = ''
  data.each do |data|
    restdata += JSON.generate({:hostname => data.hostname, :description => data.description, :macaddress => data.macaddress, :ipaddress => data.ipaddress, :device => data.device, :environment => data.environment})
    restdata += "\n"
  end
  "#{restdata}"
end
