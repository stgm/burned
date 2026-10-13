# frozen_string_literal: true

group :server do
  guard "puma", port: ENV.fetch("HANAMI_PORT", 2300), environment: ENV.fetch("HANAMI_ENV", "development") do
    # Restarts the server when Ruby or template files change.
    watch(%r{^(app|config|lib|slices)([\\/][^\\/]+)*.(rb|erb|haml|slim)$}i)
  end
end
