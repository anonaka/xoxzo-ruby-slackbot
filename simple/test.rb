require 'http'
require 'json'

response = HTTP.post("https://slack.com/api/chat.postMessage", params: {
    token: ENV['SLACK_API_TOKEN'],
    channel: "#demo",
    text: "こんにちは あきらです！",
    as_user: true,
})
puts JSON.pretty_generate(JSON.parse(response.body))