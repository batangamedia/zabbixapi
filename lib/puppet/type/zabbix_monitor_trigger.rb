
Puppet::Type.newtype(:zabbix_monitor_trigger) do
  desc <<-EOT
    Manage a trigger in Zabbix
  EOT

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

  newparam(:description) do
    desc 'Name of the trigger.'

    validate do |value|
        unless value =~ /.+/
            raise ArgumentError, "%s is not a valid description" % value
        end
    end
  end

  newparam(:expression) do
    desc 'Reduced trigger expression.'
    defaultto 60
  end
  
  newparam(:comments) do
    desc 'Additional comments to the trigger.'
  end
  
  newparam(:priority) do
    desc <<-EOT
      Severity of the trigger.
    
      Possible values are:
      * 0 - (default) not classified;
      * 1 - information;
      * 2 - warning;
      * 3 - average;
      * 4 - high;
      * 5 - disaster.
    EOT
    defaultto 0
  end
  
  newparam(:status) do
    desc <<-EOT
      Whether the trigger is enabled or disabled.
    
      Possible values are:
      * 0 - (default) enabled;
      * 1 - disabled.
    EOT
  end
  
  newparam(:type) do
    desc <<-EOT
      Whether the trigger can generate multiple problem events.
    
      Possible values are:
      * 0 - (default) do not generate multiple events;
      * 1 - generate multiple events.
    EOT
    defaultto 0
  end

  
  newparam(:url) do
    desc 'URL associated with the trigger.'
  end
  
end