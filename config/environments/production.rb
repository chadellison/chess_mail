Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.read_encrypted_secrets = true
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.log_level = :debug
  config.log_tags = [ :request_id ]
  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              "smtp.sendgrid.net",
    port:                 587,
    user_name:            ENV['SENDGRID_USERNAME'],
    password:             ENV['SENDGRID_PASSWORD'],
    authentication:       'plain',
    domain:               'heroku.com',
    enable_starttls_auto: true
  }

#   config.action_mailer.default_url_options = { :host => 'acebros.herokuapp.com' }
#
# config.action_mailer.perform_deliveries = true
# config.action_mailer.raise_delivery_errors = true
# config.action_mailer.default :charset => "utf-8"
#
# config.action_mailer.smtp_settings = {
#   address: 'smtp.sendgrid.net',
#   port: '587',
#   authentication: "plain",
#   user_name: ENV['SENDGRID_USERNAME'],
#   password: ENV['SENDGRID_PASSWORD'],
#   :domain         => 'heroku.com',
#   :enable_starttls_auto => true
# }

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end
