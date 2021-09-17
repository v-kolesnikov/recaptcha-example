# frozen_string_literal: true

require 'dotenv'
require 'roda'
require 'recaptcha'

::Dotenv.load!

::Recaptcha.configure do |config|
  config.site_key   = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
  config.skip_verify_env << ENV['RACK_ENV'] if ENV['RECAPTCHA_DISABLED']
end

class App < ::Roda
  include Recaptcha::Adapters::ControllerMethods
  include Recaptcha::Adapters::ViewMethods

  plugin :render, escape: true

  route do |r|
    r.root do
      'Hi, hacker!'
    end

    r.on('test') do
      render 'index'
    end

    r.on('verify') do
      if verify_recaptcha(action: 'purchase_gift', skip_remote_ip: true, remote_ip: request.ip)
        recaptcha_replay
        'OK!'
      else
        'Fail!'
      end
    end
  end

  def params
    request.params
  end
end
