require "sinatra/base"
require 'json'

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

      "\n<h1>Hello World!</h1> \n <h2>from</h2>\n <h2>instance:#{instance_number}</h2>\n <h2>port:#{port}</h2>\n"
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

