shader_type spatial;
render_mode unshaded, cull_disabled, alpha_to_coverage_disabled, depth_draw_opaque;

// === ОБВОДКА ПЕРСОНАЖА-СПРАЙТА (DirectionalSprite3D) ===
// Ставится в material_override на тот же Sprite3D, что и обычная текстура.
// texture_albedo прокидывается из скрипта (см. SETUP_GUIDE.md — правка directional_sprite_3d.gd),
// т.к. Sprite3D не пробрасывает свою текстуру в кастомный шейдер автоматически.

uniform sampler2D texture_albedo : source_color, filter_nearest;
uniform vec4 outline_color : source_color = vec4(0.04, 0.03, 0.07, 1.0);
uniform float outline_width_px : hint_range(0.0, 6.0) = 1.5; // толщина в "текселях" спрайта

void fragment() {
	vec2 texel = TEXTURE_PIXEL_SIZE * outline_width_px;
	vec4 tex_color = texture(texture_albedo, UV);
	float alpha = tex_color.a;

	float max_neighbor_alpha = 0.0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			if (x == 0 && y == 0) {
				continue;
			}
			vec2 offset = vec2(float(x), float(y)) * texel;
			max_neighbor_alpha = max(max_neighbor_alpha, texture(texture_albedo, UV + offset).a);
		}
	}

	bool is_outline = alpha < 0.5 && max_neighbor_alpha >= 0.5;

	if (alpha < 0.5 && !is_outline) {
		discard;
	}

	ALBEDO = is_outline ? outline_color.rgb : tex_color.rgb;
	ALPHA = is_outline ? outline_color.a : tex_color.a;
}
