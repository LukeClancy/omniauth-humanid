# Ruby/Rails OmniAuth for HumanID Alpha

Omniauth for humanID, a platform that prevents bots and increases privacy. HumanID is run by Human Internet,
a non-profit that is currently financed by organizations such as Harvard and the Mozilla Foundation (I love the Mozilla
Developer Network (MDN) which gives great javascript information).

HumanID works best when used as the only sign-up solution, due to this HumanID has to be highly trusted. This is where their
non-profit status steps in. HumanID has many benifits:

1. Increased privacy for users through both technical innovations and legal responsibilities.
2. Making bots inconvienient by requiring phone verification.
3. 'One voice one vote' type benefits by making it difficult to have multiple accounts.
4. Dont have to deal with users putting in "password123" as a password.
5. Dont have to deal with email/password registration generally (my signup process became way less complicated, there was all this stuff which to be honest I just didn't really get).
6. Much better look than "sign up with [tech monopoly here]" buttons.

## Installation

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
5. Create your callback area (still in development)
    - This area is generally supposed to be customizable, as you might have a diffrent model name, want to attach some validations, etc, etc. So it is not included in the gem, but is here as a how-to.
    - TBD

## Additional configuration
additional configuration can be set in your initializer file at the same area and in the same method as your client-secret and client-id. Additional configuration is as follows: 
- lang: default language code. Defaults to 'en' (english). Set to nil to remove from url.
- humanid_version: version string that goes in the url. Defaults to 'v0.0.3'. If humanid updates this may need to be updated aswell.
- priority_country: not sure exactly what this does or how to use it, but it was in the docs so i added it as an option. Defaults to nil.
- external_signup_url: the web login url. Defaults to: "https://core.human-id.org/[HUMANID_VERSION]/server/users/web-login". [HUMANID_VERSION] gets substituted by humanid_version above.

## Development of the Gem (Gem usage info stops here)

After checking out the repo, run `bin/setup` to install dependencies.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in the gemspec file, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

When developing the Gem, for minor updates while debugging etc, we have a custom script to update the gem
- in the root folder of the gem run ./bin/update. This will bump the version number by one in the gemspec, commit all changes with a generic message, and then install this minor version on your machine.
- For more information see the ./bin/update file.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/omniauth-humanid. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/omniauth-humanid/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Omniauth::Humanid project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/omniauth-humanid/blob/master/CODE_OF_CONDUCT.md).
