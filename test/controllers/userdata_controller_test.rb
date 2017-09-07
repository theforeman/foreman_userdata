require 'test_plugin_helper'

class UserdataControllerTest < ActionController::TestCase
  context '#user-data' do
    let(:organization) { FactoryGirl.create(:organization) }
    let(:tax_location) { FactoryGirl.create(:location) }
    let(:user_data_content) { 'template content user_data' }
    let(:cloud_init_content) { 'template content cloud-init' }
    let(:user_data_template_kind) { FactoryGirl.create(:template_kind, :name => 'user_data') }
    let(:cloud_init_template_kind) { FactoryGirl.create(:template_kind, :name => 'cloud-init') }
    let(:user_data_template) do
      FactoryGirl.create(
        :provisioning_template,
        :template_kind => user_data_template_kind,
        :template => user_data_content,
        :locations => [tax_location],
        :organizations => [organization]
      )
    end
    let(:cloud_init_template) do
      FactoryGirl.create(
        :provisioning_template,
        :template_kind => cloud_init_template_kind,
        :template => cloud_init_content,
        :locations => [tax_location],
        :organizations => [organization]
      )
    end
    let(:os) do
      FactoryGirl.create(
        :operatingsystem,
        :with_associations,
        :family => 'Redhat',
        :provisioning_templates => [
          user_data_template,
          cloud_init_template
        ]
      )
    end
    let(:host) do
      FactoryGirl.create(
        :host,
        :managed,
        :operatingsystem => os,
        :organization => organization,
        :location => tax_location
      )
    end

    setup do
      FactoryGirl.create(
        :os_default_template,
        :template_kind => user_data_template_kind,
        :provisioning_template => user_data_template,
        :operatingsystem => os
      )
      @request.env['REMOTE_ADDR'] = host.ip
    end

    context 'with user_data template' do
      test 'should get rendered userdata template' do
        get :userdata
        assert_response :success
        assert_equal user_data_content, @response.body
      end
    end

    context 'with cloud-init template' do
      setup do
        FactoryGirl.create(
          :os_default_template,
          :template_kind => cloud_init_template_kind,
          :provisioning_template => cloud_init_template,
          :operatingsystem => os
        )
      end

      test 'should get rendered cloud-init template' do
        get :userdata
        assert_response :success
        assert_equal cloud_init_content, @response.body
      end
    end
  end

  context '#metadata' do
    let(:host) { FactoryGirl.create(:host, :managed) }
    setup do
      @request.env['REMOTE_ADDR'] = host.ip
    end

    test 'should get metadata of a host' do
      get :metadata
      assert_response :success
      response = @response.body
      parsed = YAML.load(response)
      assert_equal host.mac, parsed['mac']
      assert_equal host.hostname, parsed['hostname']
    end
  end
end
