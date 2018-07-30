class UserdataController < ApplicationController
  # Skip default filters for user-data
  FILTERS = [
    :require_login,
    :session_expiry,
    :update_activity_time,
    :set_taxonomy,
    :authorize,
    :verify_authenticity_token
  ].freeze

  FILTERS.each do |f|
    skip_before_action f
  end

  before_action :set_admin_user
  before_action :skip_secure_headers
  before_action :find_host

  def userdata
    template = render_userdata_template
    render :plain => template if template
  end

  def metadata
    data = {
      :'instance-id' => "i-#{Digest::SHA1.hexdigest(@host.id.to_s)[0..17]}",
      :hostname => @host.name,
      :mac => @host.mac,
      :'local-ipv4' => @host.ip,
      :'local-hostname' => @host.name
    }
    render :plain => data.map { |key, value| "#{key}: #{value}" }.join("\n")
  end

  private

  def render_userdata_template
    template = @host.provisioning_template(:kind => 'cloud-init')
    template ||= @host.provisioning_template(:kind => 'user_data')
    unless template
      render_error(
        :message => 'Unable to find user-data or cloud-init template for host %{host} running %{os}',
        :status => :not_found,
        :host => @host.name,
        :os => @host.operatingsystem
      )
      return
    end
    safe_render(template)
  end

  def safe_render(template)
    # Foreman >= 1.20
    if template.respond_to?(:render)
      template.render(host: @host, params: params)
    else
      @host.render_template(template)
    end
  rescue StandardError => error
    Foreman::Logging.exception("Error rendering the #{template.name} template", error)
    render_error(
      :message => 'There was an error rendering the %{name} template: %{error}',
      :name => template.name,
      :error => error.message,
      :status => :internal_server_error
    )
    false
  end

  def skip_secure_headers
    SecureHeaders.opt_out_of_all_protection(request)
  end

  def render_error(options)
    message = options.delete(:message)
    status = options.delete(:status) || :not_found
    logger.error message % options
    render :plain => "#{message % options}\n", :status => status
  end

  def find_host
    @host = find_host_by_ip
    return true if @host
    render_error(
      :message => 'Could not find host for request %{request_ip}',
      :status => :not_found,
      :request_ip => ip_from_request_env
    )
    false
  end

  def find_host_by_ip
    # try to find host based on our client ip address
    ip = ip_from_request_env

    # in case we got back multiple ips (see #1619)
    ip = ip.split(',').first

    # host is readonly because of association so we reload it if we find it
    host = Host.joins(:provision_interface).where(:nics => { :ip => ip }).first
    host ? Host.find(host.id) : nil
  end

  def ip_from_request_env
    ip = request.env['REMOTE_ADDR']

    # check if someone is asking on behalf of another system (load balancer etc)
    if request.env['HTTP_X_FORWARDED_FOR'].present? && (ip =~ Regexp.new(Setting[:remote_addr]))
      ip = request.env['HTTP_X_FORWARDED_FOR']
    end

    ip
  end
end
