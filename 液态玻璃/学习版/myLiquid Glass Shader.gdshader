shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform bool u_clear_ui = false;//只应用了扭曲效果
uniform float alpha : hint_range(0.0, 1.0, 0.1) = 1.0;//调整透明度
uniform int Sample_Precision : hint_range(1, 8) = 3;
//uniform bool u_enable_edge_distortion = true;// 启用/禁用 边缘扭曲效果
//uniform bool u_enable_chromatic_abberation = true;// 启用/禁用 色散效果
//uniform bool u_enable_dynamic_blur = true;// 启用/禁用 动态模糊效果
uniform float r_sdf : hint_range(0.0, 1.0, 0.1);//调整直角圆角
uniform float u_blur_radius = 1.0;//调整模糊程度
uniform float u_distortion_intensity = 1.0;//调整折射强度
uniform float Brightness_Parameter = 1.0;//调整玻璃的亮度
uniform float Color_Difference_Parameter = 3.0;//调整色差强度
uniform float u_edge_distortion_strength : hint_range(0.0, 5.0, 0.1) = 1.0;// 控制边缘扭曲的程度（强度）
uniform float u_edge_distortion_range : hint_range(0.01, 1.0, 0.01) = 0.3;// 控制边缘扭曲的作用范围（宽度）
uniform float u_edge_transition_range : hint_range(0.005, 0.1, 0.005) = 0.02;// 控制边缘扭曲/色散的平滑过渡范围(看不出效果)





//高斯模糊
vec3 get_blurred_color(sampler2D _texture,  vec2 screen_uv, vec2 pixel_size, vec2 blur_radius)
{
	vec3 color = vec3(0.0);
	float total_weight = 0.0;

	for(int x=-2;x<=2;x++)
	{
		for(int y=-2;y<=2;y++)
		{
			vec2 offset = vec2(float(x), float(y)) * blur_radius * pixel_size;
			float weight = exp(-0.5 * (float(x*x + y*y)) / 2.0);

			color += texture(screen_texture, screen_uv+offset).rgb * weight;
			total_weight += weight;
		}
	}

	return color / total_weight;
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



void fragment()
{
	vec2 pixel_scale = fwidth(UV);
	vec2 rect_size = 1.0 / pixel_scale;
	vec2 half_size = 0.5 * rect_size;
	vec2 local_pos = (UV - 0.5) * rect_size;
	float max_radius = min(rect_size.x, rect_size.y) * 0.5;


	//映射笛卡尔坐标系并保持宽高比
	float aspect = rect_size.x / rect_size.y;
	vec2 p = vec2(UV * 2.0 -1.0) * vec2(aspect, 1.0);//[-1, 1]
	vec2 b = vec2(aspect, 1.0);
	vec4 r = vec4(r_sdf);//导出r


	//SDF是uv值
	float SDF = sdRoundedBox(p, b, r);
	float inversed_SDF = -SDF;//（1=中心，0=边缘）


	vec2 screen_uv = SCREEN_UV;
	vec2 pixel_size = SCREEN_PIXEL_SIZE;


	//计算玻璃像素的归一化方向向量
	vec2 normalized_glass_coord = normalize(local_pos);


	//计算中心距离因子（0=中心，1=边缘）
	float dist_from_center = 1.0 - clamp(inversed_SDF/u_edge_distortion_range, 0.0, 1.0);


	//非线性畸变强度
	float distortion = 1.0 - sqrt(1.0 - pow(dist_from_center, 2.0));


	//将畸变强度转化为屏幕 UV 偏移（实现视觉折射效果）
	vec2 offset_pixels = distortion * normalized_glass_coord * half_size * u_distortion_intensity * u_edge_distortion_strength;


	//转化为屏幕 UV 偏移量
	vec2 screen_uv_offset = offset_pixels * SCREEN_PIXEL_SIZE;
	vec2 target_uv = screen_uv - screen_uv_offset;


	//动态模糊
	float current_blur_radius = u_blur_radius * (1.0 - dist_from_center * 0.5);


	//色散效果
	float edge_factor = smoothstep(0.0, u_edge_transition_range, inversed_SDF);
	vec2 chromatic_offset = normalized_glass_coord * edge_factor * Color_Difference_Parameter * SCREEN_PIXEL_SIZE;
	float rgb_r = get_blurred_color(screen_texture, target_uv - chromatic_offset, SCREEN_PIXEL_SIZE, vec2(current_blur_radius)).r;
	float rgb_g = get_blurred_color(screen_texture, target_uv, SCREEN_PIXEL_SIZE, vec2(current_blur_radius)).g;
	float rgb_b = get_blurred_color(screen_texture, target_uv + chromatic_offset, SCREEN_PIXEL_SIZE, vec2(current_blur_radius)).b;


	vec3 glass_color = vec3(rgb_r, rgb_g, rgb_b);
	glass_color *= Brightness_Parameter;


	if(SDF<0.0)
	{
		if(u_clear_ui)
		{
			vec3 temp_color = get_blurred_color(screen_texture, target_uv, pixel_size, vec2(u_blur_radius));
			COLOR = vec4(temp_color, alpha);
		}
		else
		{
			COLOR = vec4(glass_color, alpha);
		}

	}
	else
	{
		discard;
	}


}