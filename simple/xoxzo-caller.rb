# test.rb
require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'
require 'xoxzo/cloudruby'
include Xoxzo::Cloudruby

response = HTTP.post("https://slack.com/api/rtm.start", params: {
    token: ENV['SLACK_API_TOKEN']
})

rc = JSON.parse(response.body)
url = rc['url']

EM.run do
  # Web Socketインスタンスの立ち上げ
  ws = Faye::WebSocket::Client.new(url)
  sid = ENV['XOXZO_API_SID']
  token = ENV['XOXZO_API_AUTH_TOKEN']
  xc = XoxzoClient.new(sid,token)

  #  接続が確立した時の処理
  ws.on :open do
    p [:open]
  end

  # RTM APIから情報を受け取った時の処理
  ws.on :message do |event|
    data = JSON.parse(event.data)
    if data['type'] == 'message'
      text = data['text']
      if text =~ /^call *(\d+) *(.*)/
        p 'call %s msg=<%s>' % [$1, $2]
        caller = '05012345678'
        recipient = $1
        msg = $2
        recipient='+81'+ recipient.sub(/^0/,'') # remove if first char is 0
        ws.send({
                    type: 'message',
                    text: "こんにちは <@#{data['user']}> さん. #{recipient}に電話します。",
                    channel: data['channel']
                }.to_json)
        res = xc.call_tts_playback(caller: caller, recipient: recipient, tts_message: msg, tts_lang:"ja")
        if res.errors != nil
          p res
          exit -1
        end
      end
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
