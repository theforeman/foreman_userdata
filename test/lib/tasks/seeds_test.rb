require 'test_plugin_helper'

module ForemanUserdata
  class SeedsTest < ActiveSupport::TestCase
    setup do
      Foreman.stubs(:in_rake?).returns(true)
    end

    test 'seeds cloud-init provisioning templates' do
      seed
      assert ProvisioningTemplate.unscoped.where(default: true).exists?
      expected_template_names = [
        'CloudInit default',
        'puppet_setup_cloudinit',
        'UserData open-vm-tools'
      ]

      seeded_templates = ProvisioningTemplate.unscoped.where(default: true, vendor: 'ForemanUserdata').pluck(:name)

      expected_template_names.each do |template|
        assert_includes seeded_templates, template
      end
    end

    private

    def seed
      User.current = FactoryBot.build(:user, admin: true,
                                             organizations: [], locations: [])
      load Rails.root.join('db', 'seeds.rb')
    end
  end
end
