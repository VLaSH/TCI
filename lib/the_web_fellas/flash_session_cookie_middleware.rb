module TheWebFellas
  class FlashSessionCookieMiddleware
    def initialize(app, session_key = '_session_id')
      @app = app
      @session_key = session_key
    end

    def call(env)
      if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
        session_data = Rack::Request.new(env).params[@session_key]
        env['HTTP_COOKIE'] = [ @session_key, session_data ].join('=').freeze unless session_data.nil?
      end
      @app.call(env)
    end
  end
end