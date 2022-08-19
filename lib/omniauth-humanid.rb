require 'json'

module OmniAuth
	module Strategies
		class Humanid
			include OmniAuth::Strategy
			#Omniauth strategy creation guide be useful
			#https://github.com/omniauth/omniauth/wiki/Strategy-Contribution-Guide

			#then this guy created another useful blog 🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥
			#🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥
			#https://dev.to/vvo/devise-create-a-local-omniauth-strategy-for-slack-4066

			#note the image in the below documentation, I will try to reference back to it below
			#https://docs.human-id.org/web-sdk-integration-guide#api-request-web-log-in-session

			#options :login_button_path, '[LOGIN_BUTTON_PATH]'
			option :humanid_version, 'v0.0.3'
			#options :local_sign_up_url, "/auth/humanid"
			option :external_signup_url, "https://core.human-id.org/[HUMANID_VERSION]/server/users/web-login"
			option :lang, :en
            option :priority_country, nil #this is an option in the docs, but they dont give an example value (otherwise I would set to united_states, or us, or 1)
			option :client_secret, nil
			option :client_id, nil

			# def self.humanid_button
			# 	#see https://docs.human-id.org/web-sdk-integration-guide
			# 	%Q{<a href="#{options.local_sign_up_url}">
    		# 		<img src="#{options.login_button_path}" alt="Anonymous Login with humanID" height="27"/>
			# 	<a>}
			# end

			def get_client_id
			#basic check for client_id
				return options.client_secret unless options.client_secret.nil?
				raise StandardError.new("Please set omniauth-humanid client id")
			end
			def get_client_secret
			#basic check for client_secret
				return options.client_secret unless options.client_secret.nil?
				raise StandardError.new("Set omniauth-humanid client secret")
			end
			def get_external_signup_url
				url = options.external_signup_url.gsub('[HUMANID_VERSION]', options.humanid_version)
				url += "?lang=#{options.lang}" if options.lang
                url += "?priority_country=#{options.priority_country}" if options.priority_country
			end
			def request_phase_err(res)
				raise StandardError.new("Issue with the request phase of humanid omniauth, response from human id has code: #{res.code}, and body: #{res.body}")
			end
			#request phase
			def request_phase
				Rails.logger.debug "HUMANID_OMNIAUTH REQUEST PHASE ___________________________________________________"
				# In the humanid web-sdk-integration-guide, this would be the "[1] login" step. We need to get the redirect url
				# through a post request, and then send that to the user.

				#see more on Net::HTTP here:
				#	https://ruby-doc.org/stdlib-2.4.1/libdoc/net/http/rdoc/Net/HTTP.html

				#get uri
				uri = URI(get_external_signup_url)
				Rails.logger.debug "HUMANID_OMNIAUTH URI: #{uri.to_s}"
				#make a post request (but dont send it yet)
				post_request = Net::HTTP::Post.new(uri)
				Rails.logger.info "HUMANID_OMNIAUTH post_request: #{post_request}"
				#set the headers as per docs.
				post_request['client-id'] = get_client_id
				post_request['client-secret'] = get_client_secret
				post_request['Content-Type'] = 'application/json'
				#send the request using a weirdly 🤷‍♂️ overcomplicated 🤷‍♂️ method 🤷‍♂️ and 🤷‍♂️ block 🤷‍♂️ blame Net::HTTP
				Rails.logger.info("BEFORE POST")
				res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true){|http| http.request(post_request)}
				Rails.logger.info("AFT POST")

				Rails.logger.info(res)
				if res.code == "200"
					body = Json.parse(res.body)
					# they have five diffrent metrics for success:
					#	1. the response code 200
					#	2. body["success"] == true
					#	3. body["code"] == "OK"
					#	4. body["message"] == "success"
					#	5. body["data"]["webLoginUrl"] is actually there
					# I check 1 and 5 since the others seem supplimentary
					
					#get the redirect url
					Rails.logger.info(body)
					redirect_url = body.dig("data", "webLoginUrl")
					#check it, throw an error if nil
					request_phase_err(res) if redirect_url.nil?
					#redirect (everything is working!)
					Rails.logger.info(redirect_url)
					redirect redirect_url
				else
					request_phase_err(res)
				end
			end
		end
	end
end
