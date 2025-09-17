extends Node

@onready var server: WebsocketServer = $服务器



func _ready() -> void:

	self.server.start_server()
