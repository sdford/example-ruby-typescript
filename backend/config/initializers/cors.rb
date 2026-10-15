Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # Partner sites embed the shared project view, so allow any origin.
  allow do
    origins ->(_origin, _env) { true }
    resource "*", headers: :any, methods: [:get, :post, :patch, :delete, :options], credentials: true
  end
end
