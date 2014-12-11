$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../../ruby/")

Puppet::Type.type(:zabbix_monitor_template_apply).provide(:ruby) do
  desc "zabbix_template_apply type"

  def exists?
    require "zabbix"
    extend Zabbix
    # the template ID is obtained via: zbx.templates.get_id(:host => resource[:template] )
    # so we check if the template IDs linked to this host contains that particular template.
    # searching for templates is also done with the ':host' parameter, confusing name scheme.
    template_id = zbx.templates.get_id(:host => resource[:template] )
    host_id     = zbx.hosts.get_id(:host => resource[:host] )

    # Get all template IDs that are linked with this host
    template_ids = zbx.templates.get_ids_by_host(:hostids => [ host_id ] )
    #returned hash:
    #{
    #  10103,
    #  10104
    #}

    # Loop all template IDs and check if the wanted template already exists or not.
    template_ids.each do |k, v|
      # puts "Found #{k} with value #{v} and matching for #{template_id} "
      # Have to explicitly cast to Integers here, .to_i
      if k.to_i == template_id.to_i
        # The template is already linked (template_id is present in the list of linked template IDs)
        # puts "Templated already linked!"
        return true
      end
    end

    # puts "Template not yet linked!"
    # No match found above? Then it's not linked, return false.
    return false
  end

  def create
    require "zabbix"
    extend Zabbix
    zbx.templates.mass_add(
      :hosts_id => [ zbx.hosts.get_id(:host => resource[:host]) ],
      :templates_id => [ zbx.templates.get_id(:host => resource[:template]) ]
    )
  end

  def destroy
    require "zabbix"
    extend Zabbix
    # To 'unlink and clear' a template, the host.update method needs to be called.
    # This accepts the hostid and the template_ids to clear.
    zbx.query(
      :method => 'host.update',
      :params => [
        :hostid => zbx.hosts.get_id(:host => resource[:host] ),
        :templates_clear => [
          :templateid => zbx.templates.get_id(:host => resource[:template])
        ]
      ]
    )
  end
end