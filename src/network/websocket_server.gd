class_name WebsocketServer
extends Node
## Websocket 服务端


## 全局会话
## 是否初始化开放过
var is_opened := false


## 监听端口号
const PORT := 52525
var ws_server: TCPServer = TCPServer.new()
## 与客户端建立的连接
var _peers :Dictionary[int, WebSocketPeer] = {}
## 连接的唯一标识符 id
var _last_peer_id := 1


## 信号
signal on_connect(peer: WebSocketPeer)
signal on_open(peer: WebSocketPeer)
signal on_closing(peer: WebSocketPeer)
signal on_closed(peer: WebSocketPeer, code: int, reason: String)
signal on_message(peer: WebSocketPeer, message: String)


## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	Log.debug("WS服务器类准备完毕")
	set_process(false)


func _on_start() -> void:
	Log.info("WS服务器已启动")
	self.is_opened = false
	set_process(true)


## 连接 Websocket 客户端
func start_server(url: StringName = "ws://127.0.0.1:%d" % self.PORT) -> Error:
	Log.info("正在监听地址 %s" % url)
	
	var state := self.ws_server.listen(PORT, "127.0.0.1")
	if state == OK:
		self._on_start()
	return state


func _process(_delta: float) -> void:
	while self.ws_server.is_connection_available():
		self._last_peer_id += 1
		Log.info("连接客户端 (%d)" % self._last_peer_id)
		
		var ws_peer: WebSocketPeer = WebSocketPeer.new()
		ws_peer.accept_stream(self.ws_server.take_connection())
		self._peers[self._last_peer_id] = ws_peer
		
	for peer_id in self._peers.keys():
		var peer := self._peers[peer_id]
		peer.poll()
		
		var state := peer.get_ready_state()
		match state:
			WebSocketPeer.STATE_CONNECTING:
				self.on_connect.emit(peer)
	
			WebSocketPeer.STATE_OPEN:
				if not self.is_opened:
					self.is_opened = true
					self.on_open.emit(peer)
					
				while peer.get_available_packet_count():
					var packet := peer.get_packet()
					var packet_text := packet.get_string_from_utf8()
					Log.debug("收到客户端 %d 的信息: %s" % [peer_id, packet_text])
					self.on_message.emit(peer, packet_text)
					## 回声
					peer.send_text(packet_text)
	
			WebSocketPeer.STATE_CLOSING:
				self.on_closing.emit(peer)
	
			WebSocketPeer.STATE_CLOSED:
				self._peers.erase(peer_id)
				
				var code := peer.get_close_code()
				var reason := peer.get_close_reason()
				self.on_closed.emit(peer, code, reason)
				Log.info("与客户端 %d 断开连接 [%d, %s]" % [peer_id, code, reason])


func send_json(peer: WebSocketPeer, data: Variant) -> Error:
	Log.debug("向WS客户端发送信息: %s" % data)
	return peer.send_text(JSON.stringify(data))
