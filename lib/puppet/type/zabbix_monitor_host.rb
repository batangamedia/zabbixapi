
Puppet::Type.newtype(:zabbix_monitor_host) do
  @doc = "Create a new host in an existing Zabbix Server environment."
  desc "Add/Remove a zabbix host to be monitored"

  ensurable do
    defaultvalues
    defaultto :present
  end

  # Normally, this parameter would be called 'name', but since the Zabbix API
  # refers to these as 'host', we continue to use that naming scheme.
  newparam(:host, :namevar => true) do
    desc "The FQDN name of the host in Zabbix."
    validate do |value|
      unless value =~ /^\w+/
        raise ArgumentError, "%s is not a valid host" %value
      end
    end
  end

  newparam(:ip) do
      desc "The IP address of the host used as the monitor interface."
  end

  newparam(:groups) do
      desc "Host groups to add the host to."
      validate do |value|
        unless value =~ /^\w+/
          raise ArgumentError, "%s is not a valid groups parameter" % value
		else
		  puts value
        end
      end
  end

  newparam(:hostname) do
    desc "Visible name of the host in Zabbix."
    validate do |value|
      unless value =~ /^\w+/
        raise ArgumentError, "%s is not a valid hostname parameter" % value
      end
    end
  end

  newparam(:proxy_hostid) do
    desc "ID of the proxy that is used to monitor the host."
  end

  newparam(:status) do
    desc "Stats of the host. 0: monitored. 1: unmonitored (disabled)."
    newvalues(0, 1)
  end
end
