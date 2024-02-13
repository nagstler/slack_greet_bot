class SilenceHealthChecksMiddleware
    def initialize(app)
      @app = app
    end
  
    def call(env)
      if env['PATH_INFO'] == '/' # Adjust the path as needed
        Rails.logger.silence { @app.call(env) }
      else
        @app.call(env)
      end
    end
  end
  