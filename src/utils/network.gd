class_name Network
extends Node
## 监听B站信息

## 基础变量/常量
enum LiveEvent {
	DANMU_MSG, ## 用户发送弹幕
	SEND_GIFT, ## 礼物
	COMBO_SEND, ## 礼物连击
	GUARD_BUY, ## 续费大航海
	SUPER_CHAT_MESSAGE, ## 醒目留言（SC）
	SUPER_CHAT_MESSAGE_JPN, ## 醒目留言（带日语翻译？）
	WELCOME, ## 老爷进入房间
	WELCOME_GUARD, ## 房管进入房间
	NOTICE_MSG, ## 系统通知（全频道广播之类的）
	PREPARING, ## 直播准备中
	LIVE, ## 直播开始
	ROOM_REAL_TIME_MESSAGE_UPDATE, ## 粉丝数等更新
	ENTRY_EFFECT, ## 进场特效
	ROOM_RANK, ## 房间排名更新
	INTERACT_WORD, ## 用户进入直播间
	ACTIVITY_BANNER_UPDATE_V2, ## 好像是房间名旁边那个 xx 小时榜
}
const reconnect_interval := 5                        ## 重连间隔 
const server_url         := "ws://localhost:52000"    ## 服务端地址
var _client              := WebSocketPeer.new()        ## 客户端
var connected            := false                   ## 连接状态


## 内置函数
func _ready():
	## 尝试连接服务器
	self.connect_to_server()
	Log.info("尝试连接至 Python 服务端: %s" % server_url)


## 每帧处理信息
func _process(_delta):
	## 轮询客户端以接收新数据
	self._client.poll()

	## 检查连接状态
	var state := self._client.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if !connected:
			connected = true
			Log.info("已连接至 Python 服务端: %s" % server_url)

		## 处理接收到的消息
		while self._client.get_available_packet_count():
			var message := self._client.get_packet().get_string_from_utf8()
			self.handle_server_message(message)

	elif state ==  WebSocketPeer.STATE_CLOSED:
		if connected:
			connected = false
			Log.info("已断开与 Python 服务端连接: %s" % server_url)

		## 尝试重新连接
		var code   := self._client.get_close_code()
		var reason := self._client.get_close_reason()
		Log.warn("代码: %d; 原因: %s" % [code, reason])

		## 每五秒尝试重连
		if not has_node("服务端重连"):
			var timer := Timer.new()
			timer.name = "服务端重连"
			timer.wait_time = 5
			timer.one_shot = true
			timer.timeout.connect(self.connect_to_server)

			add_child(timer)
			timer.start()
			Log.info("将在5秒后尝试与服务端重新连接")


## 功能函数
## 连接服务端
func connect_to_server() -> void:
	## 已有连接，先断开
	if self._client.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		self._client.close()

	## 创建新连接
	var error := self._client.connect_to_url(server_url)
	if error != OK:
		Log.error("连接 Python 服务端出错！ - %s" % error)


## 处理服务端消息  TODO
func handle_server_message(message: String) -> void:
	Log.debug("收到服务端消息：%s", % message)

	## 解析 JSON 信息
	var json         := JSON.new()
	var parse_result := json.parse(message)
	if parse_result != OK:
		Log.error("解析服务端消息失败：%s" % json.get_error_message())
		return

	var json_data: Dictionary = json.data

	match json_data.get("type", -1):
		LiveEvent.DANMU_MSG:
			Log.debug("%s发送弹幕: %s")
		LiveEvent.SEND_GIFT:
			Log.debug("%s赠送礼物: %s")
		LiveEvent.COMBO_SEND:
			Log.debug("%s礼物连击: %s")
		LiveEvent.GUARD_BUY:
			Log.debug("%s续费大航海: %s")
		LiveEvent.SUPER_CHAT_MESSAGE:
			Log.debug("%s醒目留言: %s")
		LiveEvent.SUPER_CHAT_MESSAGE_JPN:
			Log.debug("%s醒目留言: %s")
		LiveEvent.WELCOME:
			Log.debug("老爷%s进入直播间")  ## TODO ?
		LiveEvent.WELCOME_GUARD:
			Log.debug("房管%s进入直播间")
		LiveEvent.NOTICE_MSG:
			Log.debug("系统通知: %s")
		LiveEvent.PREPARING:
			Log.debug("直播间%s直播准备中")
		LiveEvent.LIVE:
			Log.debug("直播间%s开播啦")
		LiveEvent.ROOM_REAL_TIME_MESSAGE_UPDATE:
			Log.debug("直播间%s数据更新: %s")
		LiveEvent.ENTRY_EFFECT:
			Log.debug("%s进场特效: %s")
		LiveEvent.ROOM_RANK:
			Log.debug("%s直播间排名更新: %s")
		LiveEvent.INTERACT_WORD:
			Log.debug("%s进入直播间")
		LiveEvent.ACTIVITY_BANNER_UPDATE_V2:
			Log.debug("%s直播间小时榜: %s")
		_:
			Log.debug("消息类型未知：%s" % json_data.get("type"))


## 向服务端发送消息
func send_message_to_server(message: String) -> void:
	if self._client.get_ready_state() != WebSocketPeer.STATE_OPEN:
		Log.error("未连接到 Python 服务端，发送信息失败")

	var message_data: Dictionary[String, String] =  {"message": message, "timestamp": Time.get_datetime_string_from_system()}
	var json_message                             := JSON.stringify(message_data)

	## 发送消息
	var error = self._client.send_text(json_message)
	if error != OK:
		Log.error("发送消息失败：%s" % error)
		return

	Log.debug("发送消息成功！: %s" % message)
