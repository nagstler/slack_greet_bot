class SlackEventsController < ApplicationController
    
  
    # POST /slack_events
    def create
      case params[:type]
      when 'url_verification'
        render json: { challenge: params[:challenge] }
      when 'event_callback'
        process_event(params[:event])
        head :ok
      else
        head :bad_request
      end
    end


    def test_team_join
        user = {'id' => 'XXXXXXXX', 'name' => 'Test User'} # Mock user object
        greet_user(user)
        render json: {message: "Test team_join event triggered."}
    end
          
  
    private
  
    def process_event(event)
      case event[:type]
      when 'team_join'
        greet_user(event[:user])
      end
    end
  
    def greet_user(user)
        client = Slack::Web::Client.new
        if GREETING_MESSAGE_TEMPLATE.nil?
          message = "Welcome to the workspace, #{user['name']}!"
        else
          message = GREETING_MESSAGE_TEMPLATE.gsub('{{name}}', user['name'])
        end
      
        # Lua script for atomic check-and-set
        lua_script = <<-LUA
          if redis.call("EXISTS", KEYS[1]) == 0 then
            redis.call("SETEX", KEYS[1], ARGV[1], ARGV[2])
            return 1
          else
            return 0
          end
        LUA
      
        # Key for the user, TTL (24 hours), and value to set
        key = "greeted:#{user['id']}"
        ttl = 24 * 60 * 60
        value = "true"
      
        # Run the Lua script. It returns 1 if the key was set, 0 if the key already existed.
        greeted = $redis.eval(lua_script, keys: [key], argv: [ttl, value])
      
        if greeted == 1
          # The user has not been greeted; proceed with greeting.
          conversation = client.conversations_open(users: user['id'])
          client.chat_postMessage(
            channel: conversation.channel.id,
            text: message,
            blocks: [{type: 'section', text: {type: 'mrkdwn', text: message}}],
            unfurl_links: false,
            unfurl_media: false
          )
        else
          # The user has already been greeted; skip sending the message.
          Rails.logger.info "User #{user['id']} has already been greeted."
        end
    end          
end
  