template_kind = TemplateKind.where(:name => 'cloud-init').first_or_create
raise "Unable to create TemplateKind: #{format_errors template_kind}" if template_kind.nil? || template_kind.errors.any?
