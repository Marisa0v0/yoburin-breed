class_name BilibiliValuable
extends Node
## 收到价值

## 收到礼物触发信号
signal receive_gift(gift_id: int, user_id: int, count: int, single_price: int, gift_icon: String)
## 收到SC触发信号
signal receive_superchat(user_id: int, price: int)
## 收到大航海触发信号
signal receive_guard(guard_id: int, user_id: int, price: int)
