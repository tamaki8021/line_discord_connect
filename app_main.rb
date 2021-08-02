require 'line/bot'
require 'discordrb'
require 'net/http'
require 'uri'
require 'json'

token = ENV["DISCORD_BOT_TOKEN"]
clientID = ENV["DISCORD_CLIENT_ID"]

bot = Discordrb::Commands::CommandBot.new token: token, client_id: clientID, prefix: "!"

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

def add_message(str1, str2)
  return str1 + str2
end

bot.command :line do |event|
  bot_message = event.message.content
  bot_message.slice!(0,6)
  event.respond "#{bot_message}"
  push_line(add_message(event.user.name, bot_message))
end


def push_line(message)

  uri = URI.parse("https://api.line.me/v2/bot/message/push")

  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer AccessToken"
  request.body = JSON.dump({
    "to" => "userIdもしくはgroupId",
    "messages" => [
      {
        "type" => "text",
        "text" => message
      }
    ]
  })

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
  end
end

bot.run