require 'sinatra'
require 'json'
require 'pp'
require 'pony'

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
            app_name = vcap_application['application_name']


            sendgrid = Hash.new
            logger.info '-------------------------'
            logger.info "ENV['VCAP_SERVICES']"
            logger.info ENV['VCAP_SERVICES'].class
            logger.info ENV['VCAP_SERVICES']
            logger.info '-------------------------'

            vcap_services=JSON.parse(ENV['VCAP_SERVICES'] || '{}')
            if !vcap_services.empty?
                vcap_sendgrid =vcap_services["sendgrid"]
                logger.info '-------------------------'
                logger.info "VCAP_SERIVCE SENDGRID"
                logger.info vcap_sendgrid
                logger.info vcap_sendgrid.class
                logger.info '-------------------------'
                if !vcap_sendgrid.nil? 
                    sendgrid = vcap_sendgrid.first["credentials"]
                logger.info '-------------------------'
                logger.info "SENDGRID CREDENTIALS"
                logger.info sendgrid
                logger.info '-------------------------'
                end
            end


            erb :index, locals: {app: app_name, instance: instance_number, port: port, dea: dea_host, sendgrid: sendgrid}
        end

        post "/send_email" do
            logger.info 'In /send_email'
            to = params[:to]
            from = params[:from]
            subject = params[:subject]
            body = params[:body]


            logger.info '-------------------------'
            logger.info 'Email params'
            logger.info "to:#{to}"
            logger.info "from:#{from}"
            logger.info "subject#{subject}"
            logger.info "body:#{body}"
            logger.info '-------------------------'

            sendgrid = nil
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

            Pony.mail({
                :to => to,
                :from => from,
                :subject => subject,
                :body => body,
                :via => :smtp,
                :via_options => {
                    :address              => sendgrid['hostname'],
                    :port                 => '587',
#                    :domain               => "localhost.localdomain"
                    :domain               => "cfapps.io",
                    :user_name            => sendgrid['username'],
                    :password             => sendgrid['password'],
                    :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
                    :enable_starttls_auto => true
                }
            })

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

