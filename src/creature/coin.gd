extends Area2D

@export var SPEED = 60.0

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _physics_process(delta: float) -> void:
	position.x -= SPEED * delta


func _on_body_entered(body: Node2D) -> void:
	game_manager.add_exp()
	animation_player.play("拾取货币")
	
