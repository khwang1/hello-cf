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


            sendgrid = Hash.new
=begin
      puts ENV['VCAP_SERVICES']
      if (!ENV['VCAP_SERVICES'].nil? && !ENV['VCAP_SERVICES'].blank?)
          JSON.parse(ENV['VCAP_SERVICES']).each do |k,v|
              if !k.scan("sendgrid").blank?
                  credentials = v.first.select {|k1,v1| k1 == "credentials"}["credentials"]
                  host = credentials["hostname"]
                  username = credentials["username"]
                  password = credentials["password"]
                  sendgrid = {:host => host, :username => username, :password => password}
              end
          end
      end
=end

            logger.info '-------------------------'
            logger.info ENV['VCAP_SERVICES'].class
            logger.info  ENV['VCAP_SERVICES']
            logger.info '-------------------------'

            vcap_services=JSON.parse(ENV['VCAP_SERVICES'] || '{}')
            logger.info pp vcap_services
            if !vcap_services.empty?
                vcap_sendgrid =vcap_services["sendgrid"]
                logger.info vcap_sendgrid
                logger.info vcap_sendgrid.class
                if !vcap_sendgrid.nil? 
                    sendgrid = vcap_sendgrid.first["credentials"]
                    logger.info sendgrid
                end
            end


            erb :index, locals: {instance: instance_number, port: port, dea: dea_host, sendgrid: sendgrid}
        end

        post "/send_email" do
            logger.info 'In /send_email'
            to = params[:to]
            from = params[:from]
            subject = params[:subject]
            body = params[:body]


            logger.info "to:#{to}"
            logger.info "from:#{from}"
            logger.info "subject#{subject}"
            logger.info "body:#{body}"

            redirect "/"
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

