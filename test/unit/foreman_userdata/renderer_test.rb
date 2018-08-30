require 'test_plugin_helper'
require 'minitest/hooks'

module ForemanUserdata
  class RendererTest < ActiveSupport::TestCase
    # Disable AR transactional tests as we use DatabaseCleaner's truncation
    # seeds are loaded once for every context block to speed up tests
    self.use_transactional_tests = false

    # active_support_test_case_helper loads all fixtures by default
    # This overrides the seeded data so we reset the fixture list here
    self.fixture_table_names = []

    fixtures :settings, :taxonomies, :users

    TEMPLATES = [
      'CloudInit default',
      'UserData open-vm-tools'
    ].freeze

    setup do
      User.current = FactoryBot.create(:user, admin: true,
                                              organizations: [], locations: [])
    end

    teardown do
      User.current = nil
    end

    describe 'templates seeded by this plugin' do
      include Minitest::Hooks
      before(:all) do
        DatabaseCleaner.clean_with :truncation
        seed
      end

      after(:all) do
        DatabaseCleaner.clean_with :truncation
      end

      let(:host) do
        FactoryBot.create(
          :host, :managed,
          :with_puppet, :with_puppet_ca, :with_environment,
          :with_subnet, :with_hostgroup
        ).tap do |h|
          h.subnet.dns_primary = '8.8.8.8'
          h.subnet.dns_secondary = '8.8.4.4'
          h.save!
        end
      end

      context 'safe mode' do
        setup do
          Setting[:safemode_render] = true
        end

        TEMPLATES.each do |template_name|
          test "renders #{template_name} template without errors" do
            assert_template(template_name)
          end
        end
      end

      context 'unsafe mode' do
        setup do
          Setting[:safemode_render] = false
        end

        TEMPLATES.each do |template_name|
          test "renders #{template_name} template without errors" do
            assert_template(template_name)
          end
        end
      end
    end

    private

    def assert_template(template_name)
      template = ProvisioningTemplate.unscoped.find_by(name: template_name)
      assert_not_nil template
      rendered_template = render_template(template)
      assert rendered_template
      assert YAML.safe_load(rendered_template)
    end

    def render_template(template)
      # Foreman >= 1.20
      if template.respond_to?(:render)
        template.render(host: host)
      else
        host.render_template(template)
      end
    end

    def seed
      User.current = FactoryBot.build(:user, admin: true,
                                             organizations: [], locations: [])
      load Rails.root.join('db', 'seeds.rb')
    end
  end
end
