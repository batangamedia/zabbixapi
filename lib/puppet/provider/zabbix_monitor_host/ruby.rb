$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../../ruby/")

Puppet::Type.type(:zabbix_monitor_host).provide(:ruby) do
    desc "zabbix_monitor_host type"

    def exists?
      # Check if the resource exists and if it's in sync with what we expect.
      require "zabbix"
      extend Zabbix
      hostid = zbx.hosts.get_id(:host => resource[:host])

      if hostid.is_a? Integer
        # The host is found in Zabbix: check if the resource is in sync
        # We currently check for:
        #  - ip
        #  - groups
        #  - proxy_hostid
        #  - status
        #
        host_info = zbx.client.api_request(
        :method => "host.get",
        :params => {
          :output           => "extend",
          :hostids          => hostid,
          :selectInterfaces => 'extend',
          :selectGroups     => 'extend',
        })

        host_status       = host_info[0]['status'].to_s
        host_interfaces   = host_info[0]['interfaces']
        host_groups       = host_info[0]['groups']
        in_sync = true
        
        # Check the host status (enabled/disabled), compare both values as Strings (.to_s)
        if host_status != resource[:status].to_s
          in_sync = false
        end

        # Check the IP address
        #ip_found = false
        #host_interfaces.each do |interface_id, interface|
        #  ip = interface['ip'].to_s
        #  if ip == resource[:ip]
        #    ip_found = true
        #  end
        #end
        #if ip_found == false
        #  in_sync = false
        #end

        return in_sync
      else
        # Host not found, does not exist.
        return false
      end
    end

    def create
      # This is actually a "Create or update" method, if any of the parameters are out of sync,
      # this method will update Zabbix to get it up-to-date again.
      require "zabbix"
      require "ipaddress"
      extend Zabbix

      # Get all groupids from the group name that were passed to the resource.
      groups = Array.new
      resource[:groups].each do |group|
        groups.push({
          :groupid => zbx.hostgroups.get_id(:name => group)
        })
      end

      # Check if the host exists, if it does - update the host.
      # If the host does not exist, simply create it.
      hostid = zbx.hosts.get_id(:host => resource[:host])
      if hostid.is_a? Integer
        # Host found, update it. This happens in 2 steps: the host itself, and its interface.
        zbx.query(
          :method => 'host.update',
          :params => [
            :hostid         => hostid,
            :status         => resource[:status],
            :proxy_hostid   => resource[:proxy_hostid] == nil ? 0 : resource[:proxy_hostid],
            :groups         => groups
          ]
        )

        host_info = zbx.client.api_request(
          :method => "host.get",
          :params => {
            :output           => "extend",
            :hostids          => hostid,
            :selectInterfaces => 'extend',
            :selectGroups     => 'extend',
        })
#        
#        puts "Updating host interface, fetching host #{hostid}..."
#        # First, select the interface ID of this host
#        interfaces = zbx.query(
#          :method => 'host.get',
#          :params => [
#            :output     => 'extend',
#            :hostids    => [ hostid ],
#            :selectInterfaces => 'extend'
#          ]
#        )
#        
#        puts "Here come the interfaces:"
#        pp interfaces
      else
        zbx.query(
          :method => 'host.create',
          :params => [
            :host => resource[:host],
            :status => resource[:status],
            :interfaces => [
              {
              :type     => 1, # 1 = agent, 2 = SNMP, 3 = IPMI, 4 = JMX (Docs: https://www.zabbix.com/documentation/2.0/manual/appendix/api/hostinterface/definitions#host_interface)
              :main     => 1, # 0 = not default, 1 = default
              :useip    => resource[:ip] == nil ? 0 : 1,
              :usedns   => resource[:ip] == nil ? 1 : 0,
              :dns      => resource[:host],
              :ip       => resource[:ip] == nil ? "" : resource[:ip],
              :port     => 10050,
              }
            ],
            :proxy_hostid => resource[:proxy_hostid] == nil ? 0 : resource[:proxy_hostid],
            :groups       => groups
          ]
        )
      end
      
    end

    def destroy
      require "zabbix"
      require "ipaddress"
      extend Zabbix
      hostid = zbx.hosts.get_id(:host => resource[:host])
      # We don't delete hosts (yet), we simply de-active them.
      zbx.query(
        :method => 'host.update',
        :params => [
          :hostid => hostid,
          :status => 1
        ]
      )
      #zbx.query(
      #:method => 'host.delete',
      #:params => [
      #  :hostid => hostid
      #]
      #)
  end
end
