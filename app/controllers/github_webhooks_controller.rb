# app/controllers/github_webhooks_controller.rb
class GithubWebhooksController < ActionController::API
  include GithubWebhook::Processor

  # Handle push event
  def github_push(payload)
    # TODO: handle push webhook
  end

  def github_star(payload)
    star_count = payload["repository"]["stargazers_count"]
    username = payload["sender"]["login"]
    message_text = "*@#{username}* just starred the repo *Multiwoven*! :star:\n\n:clap: Total stars: *#{star_count}*"
    post_to_slack(message_text)
  end

  # Handle create event
  def github_create(payload)
    # TODO: handle create webhook
  end

  def post_to_slack(message_text)
    bot_token = ""
    slack_channel_id = ""
    uri = URI("https://slack.com/api/chat.postMessage")
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{bot_token}")
    request.body = {channel: "#{slack_channel_id}", text: message_text}.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    # You may want to check the response and handle any errors
    Rails.logger.info "Slack API response: #{response.body}"
  end

  private

  def webhook_secret(payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end
end