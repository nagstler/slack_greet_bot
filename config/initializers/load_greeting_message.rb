# config/initializers/load_greeting_message.rb

GREETING_MESSAGE_TEMPLATE = begin
  markdown_file_path = Rails.root.join('greeting_message.md')
  File.read(markdown_file_path) if File.exist?(markdown_file_path)
rescue StandardError => e
  Rails.logger.error "Failed to load greeting message: #{e.message}"
  nil
end
