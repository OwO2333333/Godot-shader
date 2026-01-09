https://godotshaders.com/shader/frosted-glass-shader-rounded-rect-outline-shadow/

本文中的着色器代码及所有代码片段均受 MIT 许可保护，可自由使用。

Frosted Glass Shader (Rounded Rect, Outline, Shadow)
磨砂玻璃着色器（圆角矩形、轮廓、阴影）

1. Setup  1. 设定

Create a ColorRect or TextureRect node in your scene.
在你的场景中创建一个 ColorRect 或 TextureRect 节点。

Assign a new ShaderMaterial to the node.
给节点分配一个新的 ShaderMaterial。

Load this shader file (CircleFrostedGlass.gdshader) into the material.
把这个着色器文件（CircleFrostedGlass.gdshader）加载到材质里。

Important: Ensure the ColorRect is large enough to contain your shape + shadow + outline. The shader draws inside the node’s bounds.
重要提示：确保 ColorRect 足够大，能容纳你的形状+阴影+轮廓。着色器会在节点的边界内绘制。

2. Essential Parameters  2. 基本参数

node_size: This MUST match the size of your node (e.g., (400, 300)). You can set this manually in the inspector or use a script to update it automatically (see below).
node_size：这必须与你的节点大小匹配（例如，（400,300））。你可以在检查器中手动设置，或者用脚本自动更新（见下文）。

shape_type: Choose 0 for Circle or 1 for Rounded Rectangle.
shape_type：选择 0 表示圆圈，选择 1 表示圆角矩形。

rect_size: The size of the visible glass pane in pixels.
rect_size：可见玻璃的像素大小。

corner_radius_*: Adjust the roundness of each corner independently (in pixels).
corner_radius_*：独立调整每个角的圆度（以像素为单位）。
