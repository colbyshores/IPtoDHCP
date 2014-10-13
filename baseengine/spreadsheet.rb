class Devicetable
  #include Celluloid
  def initialize(device)
    @device = device
  end

  def csshtml
    html = "<table border='1' cellpadding='0' cellspacing='0' style='width:750px' align='center'>"    
    devicedata = Networkdevice.where(device: @device).order(:ipaddress)
    counter = 0
    divcounter = 0
    divdevice = @device.delete(' ')
    ipsubsetcounter = 0
    devicedata.each do |devicedata|
      #if ipsubset = true then loop 110 times then break, for slower machines.  false to show everything.
      if $config[:ipsubset] == true
        ipsubsetcounter += 1
      end
      #loop repeat this for ever zone in the zone database
      if counter == 5
        #start format table
        html += "<tr>"
      end
      html << "<td align='center'>
               <div id=\"selectable#{divdevice}_#{divcounter}\" deviceIp='#{devicedata.ipaddress}' onclick=\"selectElement(this)\">
               #{devicedata.ipaddress}
               </div>
               </td>"
      if counter == 5
        #close format table
        html += "</tr>"
        counter = 0
      end if
      counter += 1
      divcounter += 1
      if ipsubsetcounter == 110
        break
      end
    end
    html += "</table>"
    return(html)
  end
end

def spreadsheetform(sort = '', errorstatus = '', search = '', searchfield = '')
  field = ''
  private = Devicetable.new("Private")
  @private = private.csshtml
  dmz = Devicetable.new("DMZ")
  @DMZ = dmz.csshtml
  nfsprivate = Devicetable.new("NFS Private")
  @NFSprivate = nfsprivate.csshtml
  nfsdmz = Devicetable.new("NFS DMZ")
  @NFSDMZ = nfsdmz.csshtml

  if errorstatus != ''
    @errorstatus = "<div id=\"popUpDiv\" >
                    <a href = \"javascript:void(0)\" onclick = \"document.getElementById('popUpDiv').style.display='none';document.getElementById('fade').style.display='none'\">Close Error Messages</a>
                    <br><br><center>#{errorstatus}</center>
                    </div>"

    @errorload = "onload=\"document.getElementById('popUpDiv').style.display='block';document.getElementById('fade').style.display='block'\""
  end

  @host = $config[:host]
  @port = $config[:port]
  if sort != ''
    @pagereturn =  '/' + sort
  else
    @pagereturn = ''
  end
  field = erb :webform
  data = Conf_host.last
  space ="&nbsp;&nbsp;&nbsp;&nbsp;"
  if !data.nil?  #if not data empty?
    field += "<center><p>last entered -> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
    field += data.hostname
    field += space
    field += data.description
    field += space
    field += data.macaddress
    field += space
    field += data.ipaddress
    field += space
    field += data.device
    field += "<p><p><p>"
  end
  field << "<table border='1' cellspacing='0' cellpadding='5' align='center'>
            <td align='center'><div class=\"checkboxes hidden\" >Delete</div></td>
            <td align='center'><a href='/hostname'>Host Name</a></td>
            <td align='center'><a href='/hostdescription'>Host Description<a></td>
            <td align='center'><a href='/macaddress'>Mac Address</a></td>
            <td align='center'><a href='/ipaddress'>IP Address</a></td>
            <td align='center'><a href='/device'>Device</a></td>
            <td align='center'><a href='/environment'>Environment</a></td>"
  if search != ''
    data = sortdata(search, searchfield)
  else
    data = sortdata(sort)
  end

  data.each do |data|
    field << "<tr>
              <td align='center'>
              <div class=\"checkboxes hidden\" >
              <input type='checkbox' name='checkbox_#{data.id}'>
              </div>
              </td>
              <td align='center'>
              #{data.hostname}
              </td>
              <td align='center'>
              #{data.description}
              </td>
              <td align='center'>
              #{data.macaddress}
              </td>
              <td align='center'>
              #{data.ipaddress}
              </td>
              <td align='center'>
              #{data.device}
              </td>
              <td align='center'>
              #{data.environment}
              </td>
              </tr>"
  end
  field << "</table>
            </form>
            </td>
            </tr>
            </table>
            </body>
            </html>"
  return field
end
