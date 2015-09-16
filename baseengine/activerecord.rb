ActiveRecord::Base.logger.level = 1

after do
  ActiveRecord::Base.connection.close
end
      # The Default uses SQLLite3 however this can connect to a MySQL/MariaDB/PostgresSQL by using variables such as those below   
      #:adapter => "mysql",
      #:host => $config[:sqlhost],
      #:username => $config[:username],
      #:password => $config[:password],

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",               #default is sqlite3 but can use MySQL/MariaDB/PostgresSQL
  :database => "#{$config[:path]}/#{$config[:databasename]}",
)

class AddSystemSettings < ActiveRecord::Migration
  #UNIQUE KEY to ensure this does not allow duplicate data
  if ActiveRecord::Schema.tables.include?("networkdevices") == false
    create_table :networkdevices do |t|
      t.string :ipaddress, unique: true
      t.string :device
    end
  end
  #UNIQUE KEY to ensure each of these do not allow for duplicate data
  if ActiveRecord::Schema.tables.include?("conf_hosts") == false
    create_table :conf_hosts do |t|
      t.string :hostname, unique: true
      t.string :macaddress, unique: true
      t.string :ipaddress, unique: true
      #t.string :vlan
      #t.string :group
      t.string :description
      t.string :device
      t.string :environment
    end
  end

  #UNIQUE KEY to ensure each of these do not allow for duplicate data
  if ActiveRecord::Schema.tables.include?("conf_subnets") == false
    create_table :conf_subnets do |t|
      t.string :group
      t.string :device
      t.string :routing
      t.string :subnet
      t.string :netmask
      t.string :domain
      t.integer :mtu, 'smallint'
      t.string :dns1, unique: true
      t.string :dns2, unique: true
      t.string :iprange1, unique: true
      t.string :iprange2, unique: true
    end
  end

end

module QueryEngine
  def querydata(query, searchfield)
    self.where("#{searchfield} LIKE :prefix", prefix: "%#{query}%")
  end
end

class Conf_host < ActiveRecord::Base
  extend QueryEngine
end

class Networkdevice < ActiveRecord::Base
end

class Conf_subnet < ActiveRecord::Base
end
