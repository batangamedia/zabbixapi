
Puppet::Type.newtype(:zabbix_monitor_item) do
  desc <<-EOT
    Manage an item in Zabbix
  EOT

  ensurable do
    defaultvalues
    defaultto :present
  end
  
  # Normally, this parameter would be called 'name', but since the Zabbix API
  # refers to these as 'host', we continue to use that naming scheme.
  newparam(:host) do
    desc "The FQDN name of the host in Zabbix."
    validate do |value|
      unless value =~ /^\w+/
        raise ArgumentError, "%s is not a valid host" %value
      end
    end
  end

  newparam(:type) do
    desc <<-EOT
     Type of the item.
     
     Possible values: 
     * 0 - Zabbix agent; 
     * 1 - SNMPv1 agent; 
     * 2 - Zabbix trapper; 
     * 3 - simple check; 
     * 4 - SNMPv2 agent; 
     * 5 - Zabbix internal; 
     * 6 - SNMPv3 agent; 
     * 7 - Zabbix agent (active); 
     * 8 - Zabbix aggregate; 
     * 9 - web item; 
     * 10 - external check; 
     * 11 - database monitor; 
     * 12 - IPMI agent; 
     * 13 - SSH agent; 
     * 14 - TELNET agent; 
     * 15 - calculated; 
     * 16 - JMX agent.
    EOT
    defaultto 0 # Zabbix agent
  end

  newparam(:item_name) do
    desc 'The name for this item.'
  end

  newparam(:item_key, :namevar => true) do
    desc 'The unique key for this item.'
  end

  newparam(:datatype) do
    desc <<-EOT
      Type of information of the item. 
    
      Possible values: 
      * 0 - numeric float; 
      * 1 - character; 
      * 2 - log; 
      * 3 - numeric unsigned; 
      * 4 - text.
    EOT
    defaultto 0 # numeric float
  end
    
  newparam(:units) do
    desc 'The units to use to store the item (K, G, ...).'
  end
  
  newparam(:update_interval) do
    desc 'How often to poll for this item.'
    defaultto 120
  end
  
  newparam(:keep_history_days) do
    desc 'How long to keep the history of this item.'
    defaultto 7
  end
  
  newparam(:keep_trends_days) do
    desc 'How long to keep the trends of this item.'
    defaultto 14
  end
  
  newparam(:applications) do
    desc 'Array of application (names) to add the item to.'
    defaultto []
  end
  
  newparam(:interface) do
    desc 'ID of the interface of the host.'
    defaultto 0
  end
  
  newparam(:delta) do
    desc <<-EOT
    Value that will be stored. 
    
    Possible values: 
    * 0 - (default) as is; 
    * 1 - Delta, speed per second; 
    * 2 - Delta, simple change.
    EOT
    defaultto 0 # As is
  end
  
  newparam(:status) do
    desc <<-EOT
      Whether the item is enabled or disabled.
    
      Possible values are:
      * 0 - (default) enabled;
      * 1 - disabled.
    EOT
    defaultto 0 # Enabled
  end

  
end