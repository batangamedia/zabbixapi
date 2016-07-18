$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../../lib/ruby/")

Puppet::Type.type(:zabbix_monitor_template).provide(:ruby) do
  desc "zabbix_template type"

  def exists?
    require "zabbix"
    extend Zabbix
    zbx.templates.get_id(
        :host => resource[:name]
    ).is_a? Integer
  end

  def create
    require "zabbix"
    extend Zabbix
    zbx.templates.create(
      :host => resource[:name],
      :groups => [
        :groupid => zbx.hostgroups.get_or_create(
          :name => resource[:group]
        )
      ]
    )
  end

  def destroy
    require "zabbix"
    extend Zabbix
    zbx.templates.delete( 
      zbx.templates.get_id(
        :host => resource[:name]
      )
    )
  end
end