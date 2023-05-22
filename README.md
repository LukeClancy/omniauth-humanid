# Ruby/Rails OmniAuth for HumanID

## status: No longer maintained

Omniauth for humanID, a platform that prevents bots and increases privacy. HumanID is run by Human Internet,
a non-profit that is currently financed by organizations such as Harvard and the Mozilla Foundation (I love the Mozilla
Developer Network (MDN) which gives great javascript information).

HumanID works best when used as the only sign-up solution, due to this HumanID has to be highly trusted. This is where their
non-profit status steps in. HumanID has many benefits:

1. Increased privacy for users through both technical innovations and legal responsibilities.
2. Making bots inconvienient by requiring phone verification.
3. 'One voice one vote' type benefits by making it difficult to have multiple accounts.
4. Dont have to deal with users putting in "password123" as a password.
5. Dont have to deal with email/password registration generally (my signup process became way less complicated, there was all this stuff which to be honest I just didn't really get).
6. Much better look than "sign up with [tech monopoly here]" buttons.

## Installation

This gem relies on the [omniauth gem](https://github.com/omniauth/omniauth). It was also developed along-side [devise](https://github.com/heartcombo/devise), but should work without it, some of the configuration may change though.

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-humanid'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install omniauth-humanid
    
Update as normal.

## Configuration

1. Make an account at humanID, and get appropriate credentials
2. You will need to set credentials for client-id and client-secret, for both development and production. This can be done using the rails:credentials method or Enviroment Variables. These both have various advantage/disadvantages.
3. do some configuration in your initializers, for devise the steps are:
    - open config/initializers/devise.rb
    - enter the below code within the "Devise.setup" area
    ```ruby
    Devise.setup do |config|
        id = Rails.application.credentials.omniauth_humanid_client_id
	    secret = Rails.application.credentials.omniauth_humanid_client_secret
	    config.omniauth :humanid, client_secret: secret, client_id: id
    end
    ```
4. Make your signup button
    - I use html which is a bit diffrent than what was provided to allow for CSRF concerns raised in [this gem](https://github.com/cookpad/omniauth-rails_csrf_protection). To follow these instructions, first install and setup that gem
    - Next your going to want to put this button code in a partial since you will be using it semi-regularly in your code base (convert to irb if needed):
    ```ruby
    .btn.common-sign-up-with-btn
	= form_with url: user_humanid_omniauth_authorize_path, method: :post do
		%input{type: :image, src: image_pack_path("icons/sign_in_logos/humanID.svg"), alt: "Anonymous Login with humanID"}
    ```
5. Create your callback area
    - This area is generally supposed to be customizable, as you might have a different model name, want to attach some validations, etc, etc. So it is not included in the gem, but is here a partial implementation of it.
	```ruby
	#in the omnath_callbacks_controller.rb file
	def accept_country_code?(code)
		true
	end
	def humanid
		omau = request.env['omniauth.auth']
		uid = omau.info.appUserId
		country_code = omau.info.countryCode
		provider = omau.provider
		Rails.logger.info("#{provider} - #{country_code} - #{uid}")
	
		unless accept_country_code?(country_code)
			redirect_to root_path, flash: {info: "phone number's country-code not accepted at this time"}
			return
		end
	
		user = User.find_by(provider: provider, uid: uid)
		if user
			#allready have an account, sign them in
			sign_in_and_redirect user, event: :authentication
		else
			request.session['signup'] ||= {}
			request.session["signup"]["provider"] = provider
			request.session["signup"]["uid"] = uid
			request.session["signup"]["country_code"] = country_code
			#continue the signup process, perhaps with a redirect, or create the user here,
			#and redirect to the main website. 
		end
	end
	```

## Additional configuration

### Omniauth options

additional configuration can be set in your initializer file at the same area and in the same method as your client-secret and client-id. Additional configuration is as follows: 
- lang: default language code. Defaults to 'en' (english). Set to nil to remove from url.
- humanid_version: version string that goes in the url. Defaults to 'v0.0.3'. If humanid updates this may need to be updated aswell.
- priority_country: not sure exactly what this does or how to use it, but it was in the docs so i added it as an option. Defaults to nil.
- external_signup_url: the web login url. Defaults to: "https://core.human-id.org/[HUMANID_VERSION]/server/users/web-login". [HUMANID_VERSION] gets substituted by humanid_version above.
- exchange_url: the exchange url. Defaults to: "https://core.human-id.org/[HUMANID_VERSION]/server/users/exchange". [HUMANID_VERSION] gets substituted by humanid_version above.

### Devise without emails/passwords

Once again, humanID is better when used alone bue to bot mitigation. This section is how to remove email/password authentication.

Although Devise is easier to deal with without usernames / passwords, it takes a bit to get there. This is out of the gem scope, but here are some pointers below. You may run into other hurdles depending on your setup.
1. In your user.rb (or similar) model, in your devise config line, remove all of the following:
	- confirmable
	- database_authenticatable
	- recoverable
	- confirmable
	- lockable
2. In your devise.rb initializer file, make sure to set authentication_keys to []
3. delete or comment out the selections in devise.rb related to number 1.
4. I had to add back the route below:
	```ruby
	as :user do
		delete "/users/sign_out" => "users/sessions#destroy"
	end
	```
5. For development you may have to create a seperate way to login/signup for testing purposes. You can do this by sending a form that implements the method 'sign_in_and_redirect user, event: :authentication', or that sets fake values for signup. MAKE SURE THIS METHOD IS ONLY ACTIVE DURING DEVELOPMENT. I have a version of this below:
	- in my routes.rb:
	```ruby
	as :user do
		if Rails.env.development?
			post '/users/override' => 'users/omniauth_callbacks#callback_override'
		end
	end
	```
	- in my OmniauthCallbacksController override (see devise documentation):
	```ruby
	if Rails.env.development?
		def callback_override
			raise StandardError.new("nope") unless Rails.env.development?
			provider = 'override'
			uid = params['uid']
			user = User.find_by(provider: provider, uid: uid)
			if user
				#allready have an account, sign them in
				sign_in_and_redirect user, event: :authentication # this will throw if user is not activated
			else
				request.session['signup'] ||= {}
				request.session["signup"]["provider"] = provider
				request.session["signup"]["uid"] = uid
				request.session["signup"]["country_code"] = 'US'
				#continue your usual sign-up process. Note for the override strategy that the username is the uid.
			end
		end
	end
	```
	- my form (hidden in a dropdown menu)
	```ruby
		- if Rails.env.development?
			.dropdown-item
				= form_with url: users_override_path, method: :post do
					%p put username below to bypass the humanID in development
					= text_field_tag :uid, '', class: 'form-control'
					= submit_tag "GO", class: "btn btn-primary"
	```

## Development of the Gem (Gem usage info stops here)

After checking out the repo, run `bin/setup` to install dependencies.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in the gemspec file, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

When developing the Gem, for minor updates while debugging etc, we have a custom script to update the gem
- in the root folder of the gem run ./bin/update. This will bump the version number by one in the gemspec, commit all changes with a generic message, and then install this minor version on your machine.
- For more information see the ./bin/update file.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/LukeClancy/omniauth-humanid. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/LukeClancy/omniauth-humanid/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Omniauth::Humanid project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/LukeClancy/omniauth-humanid/blob/master/CODE_OF_CONDUCT.md).
