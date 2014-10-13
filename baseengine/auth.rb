class Auth
  def initialize(user, pass)
    @user = user
    @pass = pass
  end

  def user
    return @user
  end

  def pass
    return @pass
  end

  def ldap
    if @pass.to_s != ''

      ldap = Net::LDAP.new
      ldap.host = "ldap.newtimes.com"
      ldap.port = 389
      result = ldap.bind_as(
          :base => "t=newtimes",
          :filter => "uid=#{@user}",
          :password => @pass
      )
      if result

        ldap = Net::LDAP.new  :host => "ldap.newtimes.com",
                              :port => "389",
                              :auth => {
                                  :method => :simple,
                                  :username => "",
                                  :password => ""
                              }

        group_name = Net::LDAP::Filter.eq("cn", "#{@user}")
        group_type = Net::LDAP::Filter.eq("groupmembership", "cn=infra,ou=IT,o=Corporate")
        filter = group_name & group_type
        treebase = "t=newtimes"
        ldap.search(:base => treebase, :filter => filter) do |entry|
          if entry.dn.to_s != ""
            return true
          end
        end
      end
    end
    return false
  end
end

#I need to add session clear
set :session_fail, '/login'
set :session_expire, 1800
set :session_secret, (0...8).map { (65 + rand(26)).chr }.join

get '/login' do
  erb :login
end

#initialize single sign on
post '/login' do
  if params[:username] and params[:password]
    authenticate = Auth.new(params[:username], params[:password])
    if authenticate.ldap
      session_start!
      redirect '/'
    else
      redirect '/login'
    end
  else
    redirect '/login'
  end
end

get '/logout' do
  session_end!
  redirect '/login'
end