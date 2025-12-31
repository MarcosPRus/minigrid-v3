shader_type canvas_item;

// --- CONFIGURABLE PARAMETERS (ENGLISH) ---

// 0 = Square, 1 = Circle, 2 = Diamond (Rhombus)
uniform int node_shape : hint_range(0, 2) = 0;

// Energy Levels
uniform int current_level = 3;
uniform int total_segments = 5;

// Availability
uniform float availability_factor : hint_range(0.0, 1.0) = 1.0;

// Colors - FILL
uniform vec4 color_fill : source_color = vec4(0.2, 0.8, 0.2, 1.0);
uniform vec4 color_background : source_color = vec4(0.15, 0.15, 0.15, 1.0);
uniform vec4 color_unavailable : source_color = vec4(0.1, 0.1, 0.1, 0.5);

// Colors - BORDER (NEW)
uniform vec4 color_border : source_color = vec4(1.0, 1.0, 1.0, 1.0); // White outline
uniform float border_thickness : hint_range(0.0, 0.05) = 0.015;      // Thickness

// Styling
uniform float separator_thickness : hint_range(0.0, 0.1) = 0.02;

// --- HELPER FUNCTIONS ---

// SDF for Rounded Box
float rounded_box(vec2 center, vec2 size, float radius) {
    vec2 d = abs(center) - size + radius;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - radius;
}

void fragment() {
    // 1. CALCULATE DISTANCE FIELD (SDF)
    // We standardize 'dist' so that:
    // < 0.0 is INSIDE the shape
    // > 0.0 is OUTSIDE the shape
    // 0.0 is exactly the EDGE

    float dist = 0.0;
    vec2 center_uv = UV - 0.5;

    if (node_shape == 0) {
        // SQUARE
        dist = rounded_box(center_uv, vec2(0.45, 0.45), 0.05);
    } else if (node_shape == 1) {
        // CIRCLE
        dist = length(center_uv) - 0.45;
    } else {
        // DIAMOND
        // Manhattan distance minus radius
        dist = (abs(center_uv.x) + abs(center_uv.y)) - 0.45;
    }

    // 2. SEGMENTATION LOGIC (Internal Fill)
    float inverted_y = 1.0 - UV.y;
    float raw_segment = inverted_y * float(total_segments);
    int segment_index = int(floor(raw_segment));

    // 3. DETERMINE FILL COLOR
    vec4 fill_color = color_background;
    float available_limit = float(total_segments) * availability_factor;

    if (segment_index < current_level) {
        fill_color = color_fill;
    }
    else if (float(segment_index) >= available_limit) {
        // Unavailable / Hatched
        float stripes = step(0.5, fract((UV.x + UV.y) * 10.0));
        fill_color = mix(color_background, color_unavailable, stripes * 0.3);
    }
    else {
        fill_color = color_background;
    }

    // Separators
    float pos_in_segment = fract(raw_segment);
    if (pos_in_segment < separator_thickness && segment_index > 0) {
         fill_color = vec4(0.0, 0.0, 0.0, 1.0);
    } else if (pos_in_segment > (1.0 - separator_thickness) && segment_index < (total_segments - 1)){
         fill_color = vec4(0.0, 0.0, 0.0, 1.0);
    }

    // 4. BORDER LOGIC (NEW)
    // We want the border to straddle the edge (dist == 0.0)
    // smoothstep creates a soft antialiased edge
    float half_border = border_thickness;

    // Mask for the internal fill (Everything inside dist 0)
    float fill_mask = 1.0 - smoothstep(0.0, 0.01, dist);

    // Mask for the border (Everything within 'thickness' distance from 0)
    float border_mask = 1.0 - smoothstep(half_border - 0.005, half_border + 0.005, abs(dist));

    // 5. COMPOSITE
    // Place border on top of fill
    vec3 final_rgb = mix(fill_color.rgb, color_border.rgb, border_mask);

    // The final alpha is the union of the fill and the border
    float final_alpha = max(fill_mask, border_mask);

    COLOR = vec4(final_rgb, final_alpha);
}