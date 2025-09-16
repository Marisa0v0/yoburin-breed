class_name MainWindow
extends Node2D
## 游戏主窗口
## 此处放置全局逻辑、可视化 UI 等

var dragging := false

@onready var node_creatures: Node = $生物组
## 接收 B 站发给 Python 客户端处理后发来的信息
@onready var ws_server: WebsocketServer = $网络通信服务器


## 场景
const scene_slime   := preload("res://scene/creature/slime.tscn")
const scene_yoburin := preload("res://scene/creature/yoburin.tscn")

@onready var background: Sprite2D = $图形界面/背景图



## 内置函数
## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	# 窗口初始化
	Log.debug("主窗口准备完毕")
	get_viewport().transparent_bg = true
	
	## 启动网络通信
	self.ws_server.start_server()

	## 动态实例化
	var yoburin: Yoburin = scene_yoburin.instantiate()
	Log.debug("优里位置：%s, %s" % [yoburin.position.x, yoburin.position.y])
	self.node_creatures.add_child(yoburin)
	## 实例化进度条
	# self.bar_health_point.max_value = yoburin.health_point
	# self.bar_health_point.value = self.bar_health_point.max_value

	# self.bar_attack_ready.value = yoburin.bar_attack_ready.min_value

	## 覆写玩家（优布林）进度条
	# yoburin.bar_health_point = self.bar_health_point
	# yoburin.bar_attack_ready = self.bar_attack_ready


## 接收输入事件
func _input(event):
	# 实现拖动窗口
	if event is InputEventMouseButton:
		dragging = (event.button_index == MOUSE_BUTTON_RIGHT and event.pressed)

	if event is InputEventMouseMotion and dragging:
		# 鼠标右键拖动窗口
		var current_position := get_window().position
		var new_position     := current_position + Vector2i(event.relative)
		get_window().set_position(new_position)

	## FIXME 测试用
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			var slime: MarisaSlime = scene_slime.instantiate()
			self.node_creatures.add_child(slime)
			slime.position = Vector2(576, 302.0)
			Log.debug("史莱姆位置：%s, %s" % [slime.position.x, slime.position.y])
		
