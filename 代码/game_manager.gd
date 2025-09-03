extends Node



@onready var player = %Yoburin


	
#我想想看...
#需要在游戏管理器里写出来的是用速度获得攻击进度条每帧怎么涨

# 总结
# 1. 攻击进度条 atk_progress_bar 初始值为 0
# 2. 攻击进度条 atk_progress_bar 最大值为 1
# 3. 攻击速度 atk_speed 初始值为 1
# 4. 攻击进度条每帧增加值为 delta
# 	- delta = atk_speed * (1 + amplifier(x))
# 	- amplifier 是非负单调递增收敛凹函数，暂定 1-e^-x
# 	- x 与礼物价格、礼物数量有关
# 		- 礼物价格越高，x 越大
# 		- 礼物数量越多，x 越大
