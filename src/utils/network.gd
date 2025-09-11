class_name Network
extends Node
## 监听B站信息


## Python Websocket 服务端地址
@onready var websocket_server_url := "ws://localhost:52000"
@onready var websocket_client := WebSocketPeer.new()

func _ready():
	websocket_client.connect_to_url(websocket_server_url)

func _process(delta):
	websocket_client.poll()
	var state = websocket_client.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while websocket_client.get_available_packet_count():
			print_debug("哔哔，接收到信息：", websocket_client.get_packet())
			
	elif state == WebSocketPeer.STATE_CLOSING:
		# 继续轮询才能正确关闭。
		pass
		
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = websocket_client.get_close_code()
		var reason = websocket_client.get_close_reason()
		print_debug("WebSocket 已关闭，代码：%d，原因 %s。干净得体：%s" % [code, reason, code != -1])
		set_process(false) # 停止处理。
