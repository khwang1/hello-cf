require "sinatra/base"

module App
  class Main < Sinatra::Base

    configure do
      enable :logging
    end

    before do
      logger.datetime_format = "%Y/%m/%d @ %H:%M:%S "
      logger.level = Logger::INFO
    end

    get '/' do
      logger.debug "debug message"
      logger.info "info message"
      port = ENV['VCAP_APP_PORT']
      "\n<h1>Hello DevBeat 2013 from port #{port}!!</h1>\n"
    end

    get "/broken" do
      logger.debug "trying broken service"
      `ps -AF | grep -m1 "ruby" | awk '{print $2;}' | (read pid; kill $pid)`
    end
    run!
  end

end

