module Jumpstart
  class Mailer
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def settings
      case config.email_provider
      when "mailgun"
        {
          address: "smtp.mailgun.org",
          user_name: get_credential(:mailgun, :username),
          password: get_credential(:mailgun, :password)
        }.merge(shared_settings)
      when "mailjet"
        {
          address: "in.mailjet.com",
          user_name: get_credential(:mailjet, :username),
          password: get_credential(:mailjet, :password)
        }.merge(shared_settings)
      when "mandrill"
        {
          address: "smtp.mandrillapp.com",
          user_name: get_credential(:mandrill, :username),
          password: get_credential(:mandrill, :password)
        }.merge(shared_settings)
      when "ohmysmtp"
        {
          address: "smtp.ohmysmtp.com",
          user_name: get_credential(:ohmysmtp, :username),
          password: get_credential(:ohmysmtp, :password)
        }.merge(shared_settings)
      when "postmark"
        {
          address: "smtp.postmarkapp.com",
          user_name: get_credential(:postmark, :username),
          password: get_credential(:postmark, :password)
        }.merge(shared_settings)
      when "sendgrid"
        {
          address: "smtp.sendgrid.net",
          domain: get_credential(:sendgrid, :domain),
          user_name: get_credential(:sendgrid, :username),
          password: get_credential(:sendgrid, :password)
        }.merge(shared_settings)
      when "sendinblue"
        shared_settings.merge({
          address: "smtp-relay.sendinblue.com",
          authentication: "login",
          user_name: get_credential(:sendinblue, :username),
          password: get_credential(:sendinblue, :password)
        })
      when "ses"
        {
          address: get_credential(:ses, :address),
          user_name: get_credential(:ses, :username),
          password: get_credential(:ses, :password)
        }.merge(shared_settings)
      when "sparkpost"
        {
          address: "smtp.sparkpostmail.com",
          user_name: "SMTP_Injection",
          password: get_credential(:sparkpost, :password)
        }.merge(shared_settings)
      else
        {}
      end
    end
    # rubocop: enable Metrics/AbcSize

    private

    # Search through credentials scoped, then unscoped
    def get_credential(*)
      Rails.application.credentials.dig(Rails.env.to_sym, *) || Rails.application.credentials.dig(*)
    end

    def shared_settings
      {
        port: 587,
        authentication: :plain,
        enable_starttls_auto: true,
        domain: Jumpstart.config.domain
      }
    end
  end
end
