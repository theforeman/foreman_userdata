require 'test_plugin_helper'

class UserdataControllerTest < ActionController::TestCase
  let(:host) { FactoryGirl.create(:host, :managed) }
  let(:content) { 'template content' }
  let(:template_kind) { TemplateKind.create(:name => 'user_data') }
  let(:template) do
    FactoryGirl.create(
      :provisioning_template,
      :template_kind => template_kind,
      :template => content
    )
  end

  test 'should get rendered userdata template' do
    @request.env['REMOTE_ADDR'] = host.ip
    Host::Managed.any_instance.expects(:provisioning_template).returns(template)
    get :userdata
    assert_response :success
    assert_equal content, @response.body
  end

  test 'should get metadata of a host' do
    @request.env['REMOTE_ADDR'] = host.ip
    get :metadata
    assert_response :success
    response = @response.body
    parsed = YAML.load(response)
    assert_equal host.mac, parsed['mac']
    assert_equal host.hostname, parsed['hostname']
  end
end
