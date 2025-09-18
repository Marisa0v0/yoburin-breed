class_name PlayerRespawnTimer
extends Timer


var GROUP_PLAYERS: StringName = GameManager.NodeGroup.keys()[GameManager.NodeGroup.Players]


## 复活倒计时
func _on_player_respawn_timer_timeout() -> void:
	Log.debug("玩家复活计时器到点")
	var yoburin: Yoburin = get_tree().get_nodes_in_group(GROUP_PLAYERS)[0]
	yoburin.respawn()
