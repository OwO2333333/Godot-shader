shader_type canvas_item;

//颜色参数
uniform vec3 base_color : source_color = vec3(1.0, 1.0, 1.0);

//图像参数
uniform vec2 rect_size = vec2(600.0, 400.0);//矩形的长宽
uniform float radius = 100;//圆角的半径

//抗锯齿参数
uniform float aa_range = 1;//抗锯齿的宽度
uniform int aa_method = 1;//抗锯齿的方法

//模糊参数
uniform bool enable_screen_blur = true; // 毛玻璃开关
uniform float blur_amount = 3.0; // 模糊强度
uniform int blur_samples = 4; // 模糊采样数量（越多越模糊，开销越大）
uniform float glass_opacity = 0.2; // 形状颜色与模糊背景的混合权重

//屏幕采样器
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

//模糊
// 输入：屏幕UV坐标、屏幕像素尺寸（适配不同分辨率）
// 输出：模糊后的屏幕背景颜色
vec3 blur_sceen(vec2 screen_uv, vec2 pixel_size)
{
	vec3 blur_color = vec3(0.0);
	float total_weight = 0.0;

	for(int x=-blur_samples;x<=blur_samples;x++)
	{
		for(int y=-blur_samples;y<=blur_samples;y++)
		{
			vec2 offset = vec2(float(x), float(y)) * pixel_size * blur_amount;
			float weight = 1.0 / (1.0 + float(x * x + y * y));
			blur_color += texture(screen_texture, screen_uv + offset).rgb * weight;
			total_weight += weight;
		}

	}
	return blur_color / total_weight;
}

//抗锯齿
float apply_antialiasing(float _distance)
{
	//方法0：线性插值法（Linear）
	if(aa_method==0)
	{
		return clamp(0.5 - _distance/(2.0 * aa_range), 0.0, 1.0);
	}

	else if(aa_method==1)
	{
		//基础遮罩
		float base = step(0.0, - _distance);
		float t = abs(_distance) / aa_range;
		float smooth_factor = 1.0 - smoothstep(0.0, 1.0, t);
		return mix(base, 0.98, smooth_factor);

	}
	else
	{
		return 0.0;
	}
}



//圆角矩形
// p: 当前点坐标
// b: 矩形从中心到边缘的尺寸 (half-size)，例如 vec2(0.3, 0.2)
// r: 收缩半径(四个角， 右下，右上，左下，左上)
float sdRoundedBox( in vec2 p, in vec2 b, in vec4 r )
{
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}
// 输出参数r
vec4 _sdRoundedBox_r()
{
	float r = radius/min(rect_size.x, rect_size.y);
	return vec4(r, r, r, r);
}


void fragment()
{
	//映射笛卡尔坐标系并保持宽高比
	//应用圆角矩形
	float aspect = rect_size.x / rect_size.y;
	vec2 p = vec2(UV * 2.0 -1.0) * vec2(aspect, 1.0);//[-1, 1]
	vec2 b = vec2(aspect, 1.0);
	float test = sdRoundedBox(p, b, _sdRoundedBox_r());

	vec3 final_color = base_color;


	if(enable_screen_blur)
	{
		vec2 screen_uv = SCREEN_UV;
		vec2 screen_pixel_size = SCREEN_PIXEL_SIZE;

		vec3 blurred_background = blur_sceen(screen_uv, screen_pixel_size);

		final_color = mix(blurred_background, base_color, glass_opacity);

	}
	COLOR = vec4(final_color, 1.0);

}













////矩形的SDF
//// p: 当前点坐标
//// b: 矩形从中心到边缘的尺寸 (half-size)，例如 vec2(0.3, 0.2)
//float RECT_SDF(vec2 p, vec2 b)
//{
	////q 向量描述了点 p 在两个轴向上“超出”矩形边界的量
	//vec2 q = abs(p) - b;
	////length(max(q, 0.0)) 点到矩形区域的最近欧氏距离
	////+ min(max(q.x, q.y), 0.0) 相当于从总距离中减去这个穿透深度，从而使最终的SDF值在内部为负
	//return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
//}
