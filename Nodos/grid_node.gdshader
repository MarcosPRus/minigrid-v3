shader_type canvas_item;

// --- PARÁMETROS CONFIGURABLES DESDE GDSCRIPT ---

// 0 = Cuadrado (Generador), 1 = Círculo (Consumidor)
uniform int forma_nodo : hint_range(0, 1) = 0;

// Niveles de energía
uniform int nivel_actual = 3;    // Cuántos segmentos están llenos
uniform int nivel_maximo = 5;    // Total de segmentos

// Colores (Se cambian desde GDScript según el estado: normal, warning, alerta)
uniform vec4 color_lleno : source_color = vec4(0.2, 0.8, 0.2, 1.0); // Verde por defecto
uniform vec4 color_vacio : source_color = vec4(0.15, 0.15, 0.15, 1.0); // Gris oscuro fondo

// Grosor de la línea de separación entre segmentos (0.0 a 0.1)
uniform float grosor_separador : hint_range(0.0, 0.1) = 0.02;

// --- NUEVOS UNIFORMS ---
// Un valor de 0.0 a 1.0 que indica cuánto "clima" tenemos.
// 1.0 = Pleno sol/viento (Todo el hardware disponible).
// 0.0 = Noche/Calma (Todo bloqueado).
uniform float factor_disponibilidad : hint_range(0.0, 1.0) = 1.0;

uniform vec4 color_bloqueado : source_color = vec4(0.1, 0.1, 0.1, 0.5); // Color oscuro para lo "no disponible"
uniform float grosor_rayado = 0.5; // Para el efecto de rayas


// --- FUNCIONES AUXILIARES ---

// Función para dibujar rectángulos redondeados (para que el cuadrado no sea tan agresivo)
float rounded_box(vec2 centro, vec2 size, float radio) {
    vec2 d = abs(centro) - size + radio;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - radio;
}

void fragment() {
    // 1. DEFINIR LA FORMA (MÁSCARA)
    float mascara_forma = 0.0;
    vec2 centro_uv = UV - 0.5; // Centramos las coordenadas en (0,0)

    if (forma_nodo == 0) {
        // FORMA CUADRADA (con esquinas ligeramente redondeadas para estética SCADA)
        // El tamaño es 0.45 para dejar un pequeño margen en el ColorRect
        float dist = rounded_box(centro_uv, vec2(0.45, 0.45), 0.05);
        // smoothstep hace el borde nítido pero suave (anti-aliasing)
        mascara_forma = 1.0 - smoothstep(0.0, 0.01, dist);
    } else {
        // FORMA CIRCULAR
        // Calculamos la distancia al centro. Si es > 0.45, cortamos.
        float dist = length(centro_uv);
        mascara_forma = 1.0 - smoothstep(0.44, 0.45, dist);
    }

    // 2. LÓGICA DE SEGMENTACIÓN
    // Invertimos UV.y para que el nivel 0 esté abajo
    float y_invertida = 1.0 - UV.y;

    // Calculamos en qué segmento estamos actualmente (de 0 a nivel_maximo-1)
    float segmento_flotante = y_invertida * float(nivel_maximo);
    int indice_segmento = int(floor(segmento_flotante));

    // 3. LÓGICA DE COLOR AVANZADA
    vec4 color_final = color_vacio;

    // Calculamos el índice límite basado en la disponibilidad externa (sol/viento)
    float limite_disponible = float(nivel_maximo) * factor_disponibilidad;

    if (indice_segmento < nivel_actual) {
        // ZONA 1: GENERANDO (Verde)
        color_final = color_lleno;
    }
    else if (float(indice_segmento) >= limite_disponible) {
        // ZONA 3: BLOQUEADO POR CLIMA (Noche / Sin viento)

        // OPCIÓN A: Color sólido oscuro (más fácil de leer)
        color_final = color_bloqueado;

        // OPCIÓN B: Efecto Rayado (Hatching) estilo ingeniería
        // Usamos la coordenada de pantalla o UV para hacer rayas diagonales
        float rayas = step(0.5, fract((UV.x + UV.y) * 10.0)); // 10.0 es la frecuencia
        // Mezclamos el color de fondo con un color un poco más claro donde haya raya
        color_final = mix(color_vacio, color_bloqueado, rayas * 0.3);
    }
    else {
        // ZONA 2: DISPONIBLE PERO NO USADO (Gris normal)
        // (Ejemplo: Es mediodía pero nadie consume, el generador está "al ralentí")
        color_final = color_vacio;
    }

    // 4. DIBUJAR SEPARADORES
    // Usamos la parte fraccionaria para detectar los bordes entre segmentos
    float posicion_en_segmento = fract(segmento_flotante);

    // Si estamos muy cerca del borde superior o inferior del segmento, pintamos negro
    // No dibujamos separador en el borde absoluto superior o inferior de la figura
    if (posicion_en_segmento < grosor_separador && indice_segmento > 0) {
         color_final = vec4(0.0, 0.0, 0.0, 1.0); // Línea negra
    } else if (posicion_en_segmento > (1.0 - grosor_separador) && indice_segmento < (nivel_maximo - 1)){
         color_final = vec4(0.0, 0.0, 0.0, 1.0); // Línea negra
    }

    // 5. APLICAR RESULTADO
    // El color final se multiplica por la máscara de forma.
    // Si está fuera de la forma, la máscara es 0 y el pixel se vuelve transparente.
    COLOR = color_final;
    COLOR.a *= mascara_forma;
}