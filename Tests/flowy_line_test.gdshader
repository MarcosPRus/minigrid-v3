shader_type canvas_item;

// --- CONFIGURACIÓN DE COLORES ---
uniform vec4 color_low : source_color = vec4(0.9, 0.9, 0.4, 1.0);   // Amarillo
uniform vec4 color_med : source_color = vec4(1.0, 0.5, 0.0, 1.0);   // Naranja
uniform vec4 color_high : source_color = vec4(1.0, 0.1, 0.1, 1.0);  // Rojo

// --- VARIABLES DE CONTROL ---
// Utilization: define el color (0.0 a 1.0+)
uniform float utilization : hint_range(0.0, 1.5) = 0.0;
// Flow Offset: controla la posición de la animación (manejado por script)
uniform float flow_offset = 0.0;
// Ajustes visuales
uniform float density = 5.0;     // Cantidad de pulsos
uniform float pulse_width = 0.4; // Ancho del pulso
uniform bool is_active = true;

void fragment() {
    // 1. CÁLCULO DEL COLOR BASE (GRADIENTE)
    vec4 base_color;
    
    if (utilization < 0.5) {
        // Interpolar Amarillo -> Naranja
        base_color = mix(color_low, color_med, utilization * 2.0);
    } else {
        // Interpolar Naranja -> Rojo
        float t = clamp((utilization - 0.5) * 2.0, 0.0, 1.0);
        base_color = mix(color_med, color_high, t);
    }

    // 2. LÓGICA DE DIBUJADO
    if (!is_active) {
        // Si está inactivo, línea tenue y estática
        COLOR = vec4(base_color.rgb, 0.1);
    } else {
        // CÁLCULO DE MOVIMIENTO SUAVE
        // Usamos flow_offset en lugar de TIME
        float moving_uv = (UV.x * density) - flow_offset;
        
        // Crear el patrón repetitivo
        float pattern = fract(moving_uv);
        
        // Suavizar bordes del pulso
        float glow = smoothstep(0.0, pulse_width, pattern) * smoothstep(1.0, 1.0 - pulse_width, pattern);
        
        // Calcular transparencia final
        float base_alpha = 0.3 + (utilization * 0.4); 
        float final_alpha = max(base_alpha, glow);
        
        // Salida final
        COLOR = vec4(base_color.rgb, final_alpha * base_color.a);
    }
}