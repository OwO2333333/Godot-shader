extends ColorRect

#func _ready():
	## 连接尺寸变化信号
	#connect("resized", Callable(self, "_on_resized"))
	## 初始化调用一次
	#_update_shader_params()
#
#func _on_resized():
	#_update_shader_params()
#
#func _update_shader_params():
	#if material is ShaderMaterial:
		## 将节点实际大小传递给着色器
		#material.set_shader_parameter("node_size", size)
		## 【可选但建议】同时更新矩形大小，使其按比例缩放
		## 例如，保持rect_size为node_size的80%：
		#material.set_shader_parameter("rect_size", size * 0.8)
		## 同步更新圆角半径（示例：按高度的10%）
		#material.set_shader_parameter("corner_radius_top_left", size.y * 0.05)
