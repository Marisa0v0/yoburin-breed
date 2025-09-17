class_name File
extends Node
## 文件处理


## 文件读取
func read(filepath: String) -> String:
	pass
	
	
## 文件写入
func write(filepath: String) -> void:
	pass
	
	
## 防御性检查 传入的是不是路径 路径是不是文件 文件存不存在
func _is_valid_filepath(filepath: String) -> bool:
	if !filepath.is_absolute_path():
		Log.warn("请传入文件绝对路径！%s" % filepath)
		return false
	
	if filepath.get_extension().is_empty():
		Log.warn("文件路径无效 - %s" % filepath)
		return false
	
	FileAccess
