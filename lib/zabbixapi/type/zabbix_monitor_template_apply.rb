
Puppet::Type.newtype(:zabbix_monitor_template_apply) do
  desc <<-EOT
  Link or unlink a template to a host.
  EOT

  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name, :namevar => true) do

  end

  newparam(:template) do
    desc 'Template name.'
  end

  newparam(:host) do
    desc 'Host name'
  end
end