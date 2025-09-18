class_name GameManager
extends Node
## 此处放置全局变量、常量等


## 分组
enum NodeGroup {
	Creature,			## 全局生物类
	EnemiesInBattle,	## 玩家要攻击的敌对怪物
	Monsters,			## 全局怪物类
	Players,			## 全局玩家类
}

## 怪物类型
## NOTE 添加新怪物类型时要修改
enum MonsterType {
	SlimeGreen,		## 绿色史莱姆
	SlimePurple,	## 紫色史莱姆
}

## 怪物类型对应的名称
## NOTE 添加新怪物类型时要修改
const MonsterTypeMapping = {
	"SlimeGreen": "绿色史莱姆",
	"SlimePurple": "紫色史莱姆"
}

## 游戏文件所在根目录
static var ROOT := OS.get_executable_path().get_base_dir()
