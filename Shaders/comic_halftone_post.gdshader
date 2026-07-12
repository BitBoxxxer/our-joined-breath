shader_type canvas_item;

// === КОМИКС-ПОСТПРОЦЕСС v2: растр ТОЛЬКО в тенях + хроматика + статичное (не мерцающее) зерно ===
// Создаётся автоматически скриптом Scripts/Globals/ComicStyle.gd — руками вешать никуда не нужно.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear, repeat_disable;

uniform float dot_size : hint_range(2.0, 24.0) = 7.0;        // размер ячейки растра в пикселях
uniform float dot_strength : hint_range(0.0, 1.5) = 1.0;     // максимальный размер точки в глубокой тени
uniform vec4 ink_color : source_color = vec4(0.04, 0.03, 0.07, 1.0);
uniform float grid_angle_deg : hint_range(0.0, 90.0) = 45.0;

// --- вот это чинит "рябит по глазам": точки теперь появляются только там, где реально темно ---
uniform float shadow_threshold : hint_range(0.0, 1.0) = 0.2; // яркость (0-1), НИЖЕ которой начинают появляться точки
uniform float shadow_softness : hint_range(0.01, 0.4) = 0.12; // насколько плавно точки проявляются у порога (0 = резкая граница)

uniform float chroma_split : hint_range(0.0, 0.01) = 0.0015;
uniform float grain_strength : hint_range(0.0, 0.3) = 0.02;   // статичное зерно, не мерцает (не зависит от TIME)
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.3;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 px = uv * resolution;

	// --- хроматическое расслоение ---
	vec2 dir = (uv - vec2(0.5)) * chroma_split;
	float r = texture(screen_tex, uv - dir).r;
	float g = texture(screen_tex, uv).g;
	float b = texture(screen_tex, uv + dir).b;
	vec3 base_color = vec3(r, g, b);

	float lum = dot(base_color, vec3(0.299, 0.587, 0.114));

	// darkness = 0 в светлых/средних тонах (порог и выше), плавно растёт к 1 в глубокой тени
	float darkness = 1.0 - smoothstep(shadow_threshold - shadow_softness, shadow_threshold + shadow_softness, lum);

	vec3 result = base_color;

	if (darkness > 0.001) {
		float angle = radians(grid_angle_deg);
		mat2 rot = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
		vec2 grid_uv = rot * (px / dot_size);
		vec2 cell = fract(grid_uv) - 0.5;
		float dist = length(cell);

		float radius = darkness * 0.42 * dot_strength;
		float edge = 0.035;
		float dot_shape = 1.0 - smoothstep(radius - edge, radius + edge, dist);
		// доп. умножение на darkness убирает любой "призрак" точки в светлых зонах
		float dot_mask = dot_shape * darkness;

		result = mix(base_color, ink_color.rgb, dot_mask * ink_color.a);
	}

	// --- статичное зерно (без TIME — не мерцает между кадрами) ---
	float noise = (rand(px) - 0.5) * grain_strength;
	result += noise;

	// --- виньетка ---
	float vig = smoothstep(0.95, 0.35, length(uv - vec2(0.5)));
	result *= mix(1.0 - vignette_strength, 1.0, vig);

	COLOR = vec4(result, 1.0);
}
