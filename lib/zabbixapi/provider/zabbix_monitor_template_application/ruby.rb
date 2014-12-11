$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../../lib/ruby/")

Puppet::Type.type(:zabbix_monitor_template_application).provide(:ruby) do
  desc "zabbix_template type"

  def exists?
    require "zabbix"
    extend Zabbix
    return (zbx.applications.get_id(
        :name => resource[:name]
      ).is_a? Integer
    )
  end

  def create
    require "zabbix"
    extend Zabbix
    zbx.applications.create(
      :name => resource[:name],
      :hostid => zbx.templates.get_id(
        :host => resource[:host]
      )
    )
  end

  def destroy
    require "zabbix"
    extend Zabbix
    zbx.applications.delete( zbx.applications.get_id( :name => resource[:name] ) )
  end
end