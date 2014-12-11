$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../../ruby/")

Puppet::Type.type(:zabbix_monitor_item).provide(:ruby) do
  desc "zabbix item provider"

  def exists?
    require "zabbix"
    extend Zabbix

    item = by_key(resource[:item_key], resource[:host])

    if item != nil and item.has_key?("itemid")
      # Item found, it exists
      return true
    else
      # Item not found
      return false
    end
  end

  def create
    require "zabbix"
    extend Zabbix
    # Adding an item means selecting an interface on the host on which
    # that item should be monitored. First, select all interfaces from
    # this host and select the main interface from those available interfaces
    hostid = zbx.hosts.get_id(:host => resource[:host])
    host_info = zbx.client.api_request(
      :method => "host.get",
      :params => {
        :output           => "shorten",
        :hostids          => hostid,
        :selectInterfaces => 'extend',
      }
    )

    host_interfaces   = host_info[0]['interfaces']
    host_interface_main = nil
    host_interfaces.each do | interfaceid, iface |
      host_interface_main = iface if iface["main"].to_s == "1".to_s 
    end
    
    # Convert the Application names to their ID
    application_ids = []
    resource[:applications].each do | app |
      application_ids.push(zbx.applications.get_id(:name => app))
    end

    zbx.client.api_request(
      :method => "item.create",
      :params => {
        :hostid       => hostid,
        :name         => resource[:item_name],
        :key_         => resource[:item_key],
        :history      => resource[:keep_history_days],
        :trends       => resource[:keep_trends_days],
        :type         => resource[:type],
        :value_type   => resource[:datatype],
        :interfaceid  => host_interface_main["interfaceid"],
        :delay        => resource[:update_interval],
        :applications => application_ids
      }
    )
  end

  def destroy
    require "zabbix"
    extend Zabbix
    item = by_key(resource[:item_key], resource[:host])
    zbx.items.delete(item["itemid"])
  end

  def by_key(key, host)
    require "zabbix"
    extend Zabbix
    # Search an item based on a key and host parameter
    hostid = zbx.hosts.get_id(:host => host)

    items = zbx.client.api_request(
      :method => "item.get",
      :params => {
        :hostids  => hostid,
        :filter   => {
          :key_   => key
        },
        :output => "extend",
      }
    )
    
    return_item = nil
    items.each { |item| return_item = item if item["key_"] == key }

    return return_item
  end
end