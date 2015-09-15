#require "sinatra/base"
require 'sinatra'
require 'json'
require 'pp'

module App
  class Main < Sinatra::Base

    configure do
      enable :logging
      set :raise_errors, true
    end

    before do
      logger.datetime_format = "%Y/%m/%d @ %H:%M:%S "
      logger.level = Logger::INFO
    end

    get '/' do
      logger.debug "debug message"
      logger.info "info message"
      port = ENV['VCAP_APP_PORT']
      vcap_application=JSON.parse(ENV['VCAP_APPLICATION'] || '{}')
      instance_number = vcap_application['instance_index']
      dea_host = vcap_application['host']

      erb :index, locals: {instance: instance_number, port: port, dea: dea_host}
    end

    get "/broken" do
      logger.debug "trying broken service"
      `ps -AF | grep -m1 "ruby" | awk '{print $2;}' | (read pid; kill -9 $pid)`
    end
    
    get "/systemcrash" do
      logger.debug "trying broken service"
      Kernel.exit!
    end
    run!
  end

end

