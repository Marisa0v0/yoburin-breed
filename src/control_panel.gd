class_name ControlPanel
extends Control
## 控制面板

## 菜单需要有
## 1.停止yoburin行动（表现为待机动画+不刷怪，如果当前有怪就把yoburin动画改为移动，镜像，把怪往右边拉，就像逃跑，点击后记得保存游戏）

## 2.更改当前yoburin属性（可以在菜单里改变yoburin属性，并恢复成默认值（最开始的yoburin属性）和读档（存档中的yoburin属性）并可以手动保存，以及修改yoburin属性存档）

## 3.更改当前怪物属性（包括一键击杀，更改目前生成的那只怪物的属性，以及修改怪物文件修改以后生成的怪物属性，以及把文件恢复成默认值）

## 4.手动刷怪（点击按钮刷怪而不是快捷键，避免不兼容其他软件）

## 5.一键复活yoburin（把yoburin拉起来，清除当前怪物）
## 6.设置礼物对应属性（一个礼物可以对应多种属性，一个属性可以接收多种礼物，一个电池等价多少属性，某个礼物直接等价多少（保证送特定礼物活动时也可以用），礼物包括送礼，连击，sc，上舰，以及大招触发条件也算）
## 7.保存游戏（保存当前ybr属性就行）
## 还没写
## 复制粘贴的


var GROUP_PLAYERS: StringName = GameManager.NodeGroup.keys()[GameManager.NodeGroup.Players]
var GROUP_MONSTERS: StringName = GameManager.NodeGroup.keys()[GameManager.NodeGroup.Monsters]
var GROUP_ENEMIES_IN_BATTLE: StringName = GameManager.NodeGroup.keys()[GameManager.NodeGroup.EnemiesInBattle]

## 标识变量
@onready var peaceful_mode := false


## 优布林菜单
@onready var yoburin_health_point_line: LineEdit = $"选项卡切换/优布林菜单/H/V/H/生命值数值"
@onready var yoburin_attack_point_line: LineEdit = $"选项卡切换/优布林菜单/H/V/H2/攻击力数值"
@onready var yoburin_defence_point_line: LineEdit = $"选项卡切换/优布林菜单/H/V/H3/防御力数值"
@onready var yoburin_attack_speed_line: LineEdit = $"选项卡切换/优布林菜单/H/V/H4/攻击速度数值"
@onready var yoburin_property_confirm_button: Button = $"选项卡切换/优布林菜单/H/V/确定修改按钮"

@onready var yoburin_peaceful_mode_checkbutton: CheckButton = $"选项卡切换/优布林菜单/H/V2/H2/和平模式按钮"
@onready var yoburin_respawn_button: Button = $选项卡切换/优布林菜单/H/V2/H3/复活优里按钮

@onready var yoburin_save_data_button: Button = $"选项卡切换/优布林菜单/H/V3/H2/导出数据按钮"
@onready var yoburin_load_data_button: Button = $"选项卡切换/优布林菜单/H/V3/H3/导入数据按钮"
@onready var yoburin_reset_data_button: Button = $"选项卡切换/优布林菜单/H/V3/H4/重置数据按钮"

## 怪物菜单
@onready var monster_health_point_line: LineEdit = $"选项卡切换/怪物菜单/H/V/H/生命值数值"
@onready var monster_attack_point_line: LineEdit = $"选项卡切换/怪物菜单/H/V/H2/攻击力数值"
@onready var monster_defence_point_line: LineEdit = $"选项卡切换/怪物菜单/H/V/H3/防御力数值"
@onready var monster_attack_speed_line: LineEdit = $"选项卡切换/怪物菜单/H/V/H4/攻击速度数值"

@onready var monster_current_kill_button: Button = $"选项卡切换/怪物菜单/H/V2/H/击杀怪物按钮"
@onready var monster_spawn_button: Button = $"选项卡切换/怪物菜单/H/V2/H2/生成新怪物按钮"
@onready var monster_spawn_options: OptionButton = $"选项卡切换/怪物菜单/H/V2/H2/生成新怪物下拉菜单"
## 其他菜单

func _init() -> void:
	Log.debug("初始化控制面板实例")


func _ready() -> void:
	Log.debug("控制面板实例准备完毕")
	self._generate_monster_spawn_options()
	

## 帧处理
func _process(_delta: float) -> void:
	## 和平模式且场上有怪物下，不能切换至非和平模式
	## 玩家死了就没有开和平模式的必要了
	self.yoburin_peaceful_mode_checkbutton.disabled = true if (self.peaceful_mode and !get_tree().get_nodes_in_group(GROUP_MONSTERS).is_empty()) or get_tree().get_nodes_in_group(GROUP_PLAYERS)[0].be_defeated else false
	
	## 没死不能复活
	self.yoburin_respawn_button.disabled = true if !get_tree().get_nodes_in_group(GROUP_PLAYERS)[0].be_defeated else false
	
	## 场上没有怪物时，不能一键击杀
	self.monster_current_kill_button.disabled = true if get_tree().get_nodes_in_group(GROUP_MONSTERS).is_empty() else false
	
	## 场上有怪物时，不能生成新怪物
	self.monster_spawn_button.disabled = true if !get_tree().get_nodes_in_group(GROUP_MONSTERS).is_empty() else false
	
	
## 生成怪物生成下拉菜单
func _generate_monster_spawn_options() -> void:
	for type in GameManager.MonsterType.keys():
		self.monster_spawn_options.add_item(GameManager.MonsterTypeMapping[type])
		
		
## 具体功能连接
## 优布林菜单
## 监测数值修改，不合规 则改为默认值
func _on_yoburin_health_point_changed(new_text: String) -> void:
	if !new_text.is_valid_float():
		self.yoburin_health_point_line.text = "%.0f" % Yoburin.new().health_point
	
	
func _on_yoburin_attack_point_changed(new_text: String) -> void:
	if !new_text.is_valid_float():
		self.yoburin_attack_point_line.text = "%.0f" % Yoburin.new().attack_point
	
	
func _on_yoburin_defence_point_changed(new_text: String) -> void:
	if !new_text.is_valid_float():
		self.yoburin_defence_point_line.text = "%.0f" % Yoburin.new().defence_point
	
	
func _on_yoburin_attack_speed_changed(new_text: String) -> void:
	if !new_text.is_valid_float():
		self.yoburin_attack_speed_line.text = "%.0f" % Yoburin.new().attack_speed


## 属性修改
func _on_yoburin_property_confirm_button_pressed() -> void:
	var yoburin: Yoburin = get_tree().get_nodes_in_group(GROUP_PLAYERS)[0]
	yoburin.health_point = self.yoburin_health_point_line.text.to_float()
	yoburin.attack_point = self.yoburin_attack_point_line.text.to_float()
	yoburin.defence_point = self.yoburin_defence_point_line.text.to_float()
	yoburin.attack_speed = self.yoburin_attack_speed_line.text.to_float()
	Log.debug("优布林的数值已修改为: %s, %s, %s, %s" % [yoburin.health_point, yoburin.attack_point, yoburin.defence_point, yoburin.attack_speed])


## 和平模式按钮
func _on_peaceful_mode_button_pressed() -> void:
	## 开启和平模式
	if self.peaceful_mode == false:
		self.peaceful_mode = true
		## 停止新怪物生成
		Log.info("开启和平模式")
		var timer: Timer = get_node("/root/主场景/功能组件集合/刷怪倒计时")		## NOTE 修改结构时要修改
		timer.paused = true
		
		for monster in get_tree().get_nodes_in_group(GROUP_MONSTERS):
			if monster is MarisaSlime:	## FIXME 暂时只有史莱姆
				await monster.animation_end  ## FIXME ? 不确定能不能这么写
				## 如果当前有正在交战的怪物，停止交战
				if monster.target_player != null:
					## 退出交战状态
					monster.in_battle_position = false
					monster.target_player = null
					monster.remove_from_group(GROUP_ENEMIES_IN_BATTLE)
				## 所有怪物反向加速逃离
				## 修改贴图方向
				monster.animated_sprite_2d.flip_h = false
				## 修改速度
				monster.move_speed = - 2.0 * monster.move_speed
				## 修改状态
				monster.update_state(MarisaCreature.Status.Move)
		
	## 关闭
	else:
		## 重新开始刷怪计时
		Log.info("关闭和平模式")
		var timer: Timer = get_node("/root/主场景/功能组件集合/刷怪倒计时")		## NOTE 修改结构时要修改
		timer.paused = false
		self.peaceful_mode = false
		
		
## 复活优里
func _on_yoburin_respawn_button_pressed() -> void:
	var yoburin: Yoburin = get_tree().get_nodes_in_group(GROUP_PLAYERS)[0]
	yoburin.respawn()

		
## 导出优布林数据
func _on_yoburin_save_data_button_pressed() -> void:
	var yoburin: Yoburin = get_tree().get_nodes_in_group(GROUP_PLAYERS)[0]
	var default_data: Dictionary = {
				"health_point": yoburin.health_point,
				"attack_speed": yoburin.attack_speed,
				"attack_point": yoburin.attack_point,
				"defence_point": yoburin.defence_point
			}
	var result_data := yoburin.save_data(default_data)
	Log.debug("手动导出优布林数据 %s" % result_data)


## 导入优布林数据
func _on_yoburin_load_data_button_pressed() -> void:
	var yoburin: Yoburin = get_tree().get_nodes_in_group(GROUP_PLAYERS)[0]
	var result_data := yoburin.load_data()
	Log.debug("手动导入优布林数据 %s" % result_data)


## 重置优布林数据
func _on_yoburin_reset_data_button_pressed() -> void:
	var yoburin: Yoburin = get_tree().get_nodes_in_group(GROUP_PLAYERS)[0]
	for property in yoburin.DEFAULT_DATA.keys():
		yoburin.set(property, yoburin.DEFAULT_DATA[property])
	Log.debug("手动重置优布林数据 %s" % yoburin.DEFAULT_DATA)
	

## 怪物菜单 FIXME 当前只有史莱姆
## 监测数值修改，不合规 则改为默认值
func _on_monster_health_point_changed(new_text: String) -> void:
	if !new_text.is_valid_float():
		self.monster_health_point_line.text = "%.0f" % MarisaSlime.new().health_point
	
	
func _on_monster_attack_point_changed(new_text: String) -> void:
	if !new_text.is_valid_float():
		self.monster_attack_point_line.text = "%.0f" % MarisaSlime.new().attack_point
	
	
func _on_monster_defence_point_changed(new_text: String) -> void:
	if !new_text.is_valid_float():
		self.monster_defence_point_line.text = "%.0f" % MarisaSlime.new().defence_point
	
	
func _on_monster_attack_speed_changed(new_text: String) -> void:
	if !new_text.is_valid_float():
		self.monster_attack_speed_line.text = "%.0f" % MarisaSlime.new().attack_speed


## 属性修改
func _on_monster_property_confirm_button_pressed() -> void:
	var health_point := self.monster_health_point_line.text.to_float()
	var attack_point := self.monster_attack_point_line.text.to_float()
	var defence_point := self.monster_defence_point_line.text.to_float()
	var attack_speed := self.monster_attack_speed_line.text.to_float()
	
	## 先看场上有没有怪物
	var monster: MarisaSlime = null
	if !get_tree().get_nodes_in_group(GROUP_MONSTERS).is_empty():
		## 修改当前场上怪物的数据 FIXME 当前只有史莱姆
		monster = get_tree().get_nodes_in_group(GROUP_MONSTERS)[0]
		monster.health_point = health_point
		monster.attack_point = attack_point
		monster.defence_point = defence_point
		monster.attack_speed = attack_speed
		
	## 修改以后刷出怪物的数据 FIXME 前只有史莱姆
	monster = MarisaSlime.new() if monster == null else monster
	monster.type_ = "slime"
	monster.save_data({
		"health_point": health_point,
		"attack_point": attack_point,
		"defence_point": defence_point,
		"attack_speed": attack_speed,
	})
	Log.debug("怪物的数值已修改为: %s, %s, %s, %s" % [health_point, attack_point, defence_point, attack_speed])


## 击杀当前怪物 FIXME 当前只有史莱姆
func _on_monster_current_kill_button_pressed() -> void:
	var monster: MarisaSlime = get_tree().get_nodes_in_group(GROUP_MONSTERS)[0]
	monster.health_point = 0
	
	
## 生成新怪物 FIXME 当前只有史莱姆
func _on_monster_spawn_button_pressed() -> void:
	var monster_type_cn := self.monster_spawn_options.get_item_text(self.monster_spawn_options.selected)
	var main: Main = get_node("/root/主场景")
	var monster_type = GameManager.MonsterTypeMapping.find_key(monster_type_cn)
		## 绿色史莱姆
	if monster_type == GameManager.MonsterType.keys()[GameManager.MonsterType.SlimeGreen]:
		Log.debug("选中生成怪物类型: %s (%s)" % [monster_type_cn, GameManager.MonsterTypeMapping.find_key(monster_type_cn)])
		main.spawn_monster(GameManager.MonsterType.SlimeGreen)
		
	elif monster_type == GameManager.MonsterType.keys()[GameManager.MonsterType.SlimePurple]:
		Log.debug("选中生成怪物类型: %s (%s)" % [monster_type_cn, GameManager.MonsterTypeMapping.find_key(monster_type_cn)])
		main.spawn_monster(GameManager.MonsterType.SlimePurple)
			

## 其他菜单
