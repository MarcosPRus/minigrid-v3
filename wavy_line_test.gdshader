shader_type canvas_item;

// Quitamos la "velocidad" de aquí, la calcularemos fuera
uniform float carga : hint_range(0.0, 1.0);
uniform float offset_animacion; // Este será nuestro "tiempo manual"
uniform float grosor_visual : hint_range(0.01, 0.5) = 0.1;

uniform vec4 color_base : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform vec4 color_sobrecarga : source_color = vec4(1.0, 0.2, 0.0, 1.0);

void fragment() {
    float frecuencia = 1.0 + (carga * 3.0);
    float amplitud = 0.25 + (carga * 0.15);

    // IMPORTANTE: Ya no usamos TIME * velocidad, usamos el offset que nos manda GDScript
    float centro_onda = 0.5 + sin(UV.x * frecuencia + offset_animacion) * amplitud;

    float distancia = abs(UV.y - centro_onda);
    float forma_linea = 1.0 - smoothstep(grosor_visual - 0.01, grosor_visual + 0.01, distancia);

    vec4 color_final = mix(color_base, color_sobrecarga, carga);
    COLOR = vec4(color_final.rgb, color_final.a * forma_linea);
}