User.as_anonymous_admin do
  templates = [
    { name: 'CloudInit default', source: 'cloud_init/cloud_init_default.erb', template_kind: TemplateKind.find_by(name: 'cloud-init') },
    { name: 'puppet_setup_cloudinit', source: 'snippet/puppet_setup_cloudinit.erb', snippet: true },
    { name: 'UserData open-vm-tools', source: 'user_data/userdata_open_vm_tools.erb', template_kind: TemplateKind.find_by(name: 'user_data') }
  ]
  templates.each do |template|
    template[:contents] = File.read(File.join(ForemanUserdata::Engine.root, 'app/views/foreman/unattended/provisioning_templates', template[:source]))
    ProvisioningTemplate.where(name: template[:name]).first_or_create do |pt|
      pt.vendor = 'ForemanUserdata'
      pt.default = true
      pt.locked = true
      pt.name = template[:name]
      pt.template = template[:contents]
      pt.template_kind = template[:template_kind] if template[:template_kind]
      pt.snippet = template[:snippet] if template[:snippet]
    end
  end
end
