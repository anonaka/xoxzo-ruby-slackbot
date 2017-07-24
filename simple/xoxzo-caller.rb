# test.rb
require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'

response = HTTP.post("https://slack.com/api/rtm.start", params: {
    token: ENV['SLACK_API_TOKEN']
})

rc = JSON.parse(response.body)

url = rc['url']


def process_message(text)
  if text =~ /^call (\d+) *(.*)/
    p "call %s msg=<%s>" % [$1, $2]
  end
end

EM.run do
  # Web Socketインスタンスの立ち上げ
  ws = Faye::WebSocket::Client.new(url)

  #  接続が確立した時の処理
  ws.on :open do
    p [:open]
  end

  # RTM APIから情報を受け取った時の処理
  ws.on :message do |event|
    data = JSON.parse(event.data)
    if data["type"] == "message"
      process_message(data['text'])
    end
    p [:message, JSON.parse(event.data)]
  end

  # 接続が切断した時の処理
  ws.on :close do
    p [:close]
    ws = nil
    EM.stop
  end

end
