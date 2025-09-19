class_name Main
extends Node2D
## 游戏主窗口
## 此处放置全局逻辑、可视化 UI 等


## 场景
const scene_green_slime := preload("res://scene/creature/slime.tscn")
const scene_purple_slime := preload("res://scene/creature/purple_slime.tscn")
const scene_yoburin     := preload("res://scene/creature/yoburin.tscn")
const scene_control_panel := preload("res://scene/control_panel.tscn")

@onready var background: Sprite2D = $"图形界面/背景图"
@onready var node_creatures: Node = $"生物组"
# @onready var control_panel: ControlPanel = $"控制面板"
## 接收 B 站发给 Python 客户端处理后发来的信息
@onready var ws_server: WebsocketServer = $"网络通信服务器"
@onready var monster_spawn_timer: Timer = $"功能组件集合/刷怪倒计时"

var DRAGGING: bool = false
var GROUP_MONSTERS: StringName = GameManager.NodeGroup.keys()[GameManager.NodeGroup.Monsters]
var GROUP_PLAYERS: StringName = GameManager.NodeGroup.keys()[GameManager.NodeGroup.Players]


## 内置函数
## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	# 窗口初始化
	get_viewport().transparent_bg = true
	
	## 启动网络通信
	self.ws_server.start_server()

	## 动态实例化
	var yoburin: Yoburin = scene_yoburin.instantiate()
	self.node_creatures.add_child(yoburin)
	yoburin.add_to_group(GROUP_PLAYERS)		## 添加入全局玩家组
	
	var control_panel: ControlPanel = scene_control_panel.instantiate()
	self.add_child(control_panel)
	
	Log.debug("主窗口准备完毕")
	
	
## 接收输入事件
func _input(event):
	## 实现拖动窗口
	if event is InputEventMouseButton:
		DRAGGING = (event.button_index == MOUSE_BUTTON_RIGHT and event.pressed)

	if event is InputEventMouseMotion and DRAGGING:
		## 鼠标右键拖动窗口
		var current_position := get_window().position
		var new_position     := current_position + Vector2i(event.relative)
		get_window().set_position(new_position)
		
	if event is InputEventKey:
		if event.keycode == KEY_C:
			## 触发四叶草流星
			var yoburin: Yoburin = get_tree().get_nodes_in_group(GROUP_PLAYERS)[0]
			yoburin.cast_skill()


## 怪物生成相关
## 生成怪物倒计时，按本地的实际时间流动进行生成
func _on_monster_spawn_timer_timeout() -> void:
	Log.debug("刷怪计时器到点")
	if get_tree().get_nodes_in_group(GROUP_MONSTERS).is_empty():
		spawn_monster()
	
	
## 生成怪物，根据随机数与枚举决定生成哪一个
func spawn_monster(type = null) -> void:
	var random_int := RandomNumberGenerator.new().randi_range(0, len(GameManager.MonsterType.keys())-1)
	var monster_position := Vector2(1226, 302.0)
	var monster
	var match_value = type if type != null else random_int
		
	match match_value:
		GameManager.MonsterType.SlimeGreen:
			monster = scene_green_slime.instantiate()
			
		GameManager.MonsterType.SlimePurple:
			monster = scene_purple_slime.instantiate()
			
		_:
			pass
	
	self.node_creatures.add_child(monster)
	monster.position = monster_position
	Log.debug("生成怪物 %s(%s)" % [monster.name, monster])
	
	## 将生成的怪物加入怪物列表，用来让倒计时判断结束后是否生成怪物，如果怪物列表里还有东西就不生成
	monster.add_to_group(GROUP_MONSTERS)


## 控制面板相关


## 网络通信相关
## 收到户端信息
func _on_websocket_message(_peer: WebSocketPeer, message: String) -> void:
	if message.is_empty():
		return
	var reception_data := JSON.parse_string(message) as Dictionary
	if reception_data == null:
		Log.error("解析WS消息失败: %s" % message)
		return
	
	if reception_data.get("type", null) == null:
		Log.error("WS消息格式有误: %s" % reception_data)
		return
		
	var message_data := JSON.parse_string(reception_data["message"]) as Dictionary
	if reception_data == null:
		Log.error("解析WS消息具体内容失败: %s" % reception_data["message"])
		return
		
	match reception_data["type"]:
		## 大航海
		"GUARD_BUY":
			Log.info("收到大航海了")
			var gname: StringName = message_data["gname"]	## 礼物名称
			var gid: int = message_data["gid"]				## 礼物ID
			var price: int = message_data["price"]			## 礼物价值 (数值为人民币*1000)
			## 触发四叶草流星
			var yoburin: Yoburin = get_tree().get_nodes_in_group(GROUP_PLAYERS)[0]
			yoburin.cast_skill()
			
		## 礼物
		"SEND_GIFT":
			Log.info("收到礼物了")
			var gname: StringName = message_data["gname"]	## 礼物名称
			var gid: int = message_data["gid"]				## 礼物ID
			var price: int = message_data["price"]			## 礼物价值 (数值为人民币*1000)
			
			## TODO 触发礼物效果？
		
		## 醒目留言
		"SUPER_CHAT_MESSAGE":
			Log.info("收到醒目留言了")
			var gname: StringName = message_data["gname"]	## 礼物名称
			var gid: int = message_data["gid"]				## 礼物ID
			var price: int = message_data["price"]			## 礼物价值 (数值为人民币，啥比B站)
			
		_:
			pass
