class_name GameManager
extends Node
## 此处放置全局变量、常量等


## 分组
enum NodeGroup {
	Creature,			## 全局生物类
	EnemiesInBattle,	## 玩家要攻击的敌对怪物
	Monsters,			## 全局怪物类
}

## 游戏文件所在根目录
static var ROOT := OS.get_executable_path().get_base_dir()
