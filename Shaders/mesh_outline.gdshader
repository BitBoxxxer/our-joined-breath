shader_type spatial;
render_mode unshaded, cull_front, depth_draw_always, shadows_disabled;

// === ЧЁРНАЯ ОБВОДКА МЕШЕЙ (inverted hull) ===
// Применяется на ДУБЛИКАТ меша (см. outline_generator.gd) — не на оригинал.
// Дубликат немного "раздувается" наружу вдоль нормалей и рисуется только с обратной стороны,
// из-за cull_front это даёт тонкий чёрный контур по силуэту объекта.

uniform vec4 outline_color : source_color = vec4(0.04, 0.03, 0.07, 1.0);
uniform float outline_width : hint_range(0.0, 0.1) = 0.015; // в единицах мира, подбирай под масштаб пропсов

void vertex() {
	VERTEX += NORMAL * outline_width;
}

void fragment() {
	ALBEDO = outline_color.rgb;
	ALPHA = outline_color.a;
}
