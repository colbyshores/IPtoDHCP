def IpToMac(ip)
  if ip =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
    parts = ip.split('.')
  else
    return false
  end

  # The beginning of the MAC address. Each byte is an array element
  mac = [0,0,5,0,5,6]

  case parts[0]
    when "10"
      case parts[1]
        when "162"
          mac[6] = 2
        when "166"
          mac[6] = 1
        else
          return false
      end
      if parts[2] =~ /^\d$/
        mac[7] = parts[2]
      else
        return false
      end
      mac.concat parts[3].rjust(4,'0').chars.to_a
    when "172"
      case parts[1]
        when "40"
          mac[6] = 0
        when "41"
          mac[6] = 3
        else
          return false
      end
      if parts[2] =~ /^\d$/
        mac[7] = parts[2]
      else
        return false
      end
      mac.concat parts[3].rjust(4,'0').chars.to_a
    else
      return false
  end
  i = 0
  macstr = ""
  mac.each { |b|
    macstr.concat(i % 2 == 1 ? "#{b}:" : "#{b}")
    i += 1
  }
  macaddress = macstr.chomp(':')
  return macaddress
end



def IpToDevice(ip)
  if ip =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
    parts = ip.split('.')
  else
    return false
  end

  case parts[0]
    when "10"
      case parts[1]
        when "162"
	  return 'DMZ'
        when "166"
	  return 'Private'
        else
          return false
      end
    when "172"
      case parts[1]
        when "40"
	  return 'NFS Private'
        when "41"
	  return 'NFS DMZ'
        else
          return false
      end
    else
      return false
  end
end




