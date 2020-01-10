# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

development_origins = ["localhost:4200", "127.0.0.1:4200", /\Ahttp:\/\/[a-z9-9]+\.ngrok\.io\z/]

allowed_origins = Rails.env == "development" ? development_origins
                    : Rails.application.credentials.front_end_allowed_origins || development_origins

puts "Allowed CORS origins: #{allowed_origins}"
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*allowed_origins)

    resource "*",
      headers: :any,
      methods: [:get, :options, :head]
  end
end
