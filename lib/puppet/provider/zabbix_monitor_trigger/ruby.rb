$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../../ruby/")

Puppet::Type.type(:zabbix_monitor_trigger).provide(:ruby) do
  desc "zabbix trigger provider"

  def exists?
    require "zabbix"
    extend Zabbix

    trigger = by_expression(resource[:expression], resource[:host])

    if trigger != nil and trigger.has_key?("triggerid")
      # Trigger found, it exists
      return true
    else
      # Trigger not found
      return false
    end
  end

  def create
    require "zabbix"
    extend Zabbix
    zbx.triggers.create(
      :description  => resource[:description],
      :expression   => resource[:expression],
      :comments     => resource[:comments],
      :priority     => resource[:priority],
      :status       => resource[:status],
      :type         => resource[:type],
      :url          => resource[:url]
    )
  end

  def destroy
    require "zabbix"
    extend Zabbix
    trigger = by_expression(resource[:expression], resource[:host])
    zbx.triggers.delete(trigger["triggerid"])
  end

  def by_expression(expression, host)
    require "zabbix"
    extend Zabbix
    # The problem: zabbix does not allow you to search for triggers based on the full expression
    # like '{test2.nucleus.be:nginx.config_version.last(0)}#0.2'. Internally, zabbix stores those
    # expressions like '{13360}#0.2' where 13360 is the itemid.
    #
    # Our workaround: select all triggers for this host, loop them and check if the trigger
    # is present. That works, but is ugly.
    #
    # step 1: get all triggers for this host
    hostid = zbx.hosts.get_id(:host => host)

    hosttriggers = zbx.client.api_request(
      :method => "trigger.get",
      :params => {
        :filter => {
          :hostids => hostid
        },
        :output => "extend",
        :expandExpression => true,      # Make sure to convert itemids in the trigger to full names
        :expandDescription => true,     # Convert macro's in the description as well
      }
    )

    # Step 2: loop all triggers, and if one matches our expression, use that object
    trigger = nil
    hosttriggers.each { |template| trigger = template if template["expression"] == expression }

    return trigger
  end
end