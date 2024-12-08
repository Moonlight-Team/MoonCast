
shader_type spatial;
render_mode unshaded;

uniform sampler2D sky_texture : source_color;
uniform bool lock_aspect = false;
uniform float aspect_ratio = 1.3333333;
uniform vec2 fov = vec2(180.0, 90.0);
uniform ivec2 tiling = ivec2(1, 1);
uniform vec2 offset = vec2(0.0, 0.0);

varying vec4 BG_COORDS;

void vertex() {
    //Camera YX rotation per Basis.get_euler source code
    float y = atan(VIEW_MATRIX[0][2], VIEW_MATRIX[2][2]);
    float x = asin(VIEW_MATRIX[1][2]);
    
    //Map rotation to screen space
    BG_COORDS.xy = vec2(y * -0.5, x) / PI;
    BG_COORDS.y += 0.5;
    
    BG_COORDS.w = fov.y / 180.0;
    BG_COORDS.z = !lock_aspect ? fov.x / 360.0 : VIEWPORT_SIZE.x / (VIEWPORT_SIZE.y * aspect_ratio) * BG_COORDS.w;
    
    //Keep background centered vertically when FOV changes
    BG_COORDS.y *= BG_COORDS.w > 1.0 ? 0.0 : 1.0 - BG_COORDS.w;
}

void fragment() {
    vec2 uv_offset = vec2(-offset.x, offset.y);
    vec2 uv = (SCREEN_UV + uv_offset) * BG_COORDS.zw + BG_COORDS.xy;
    uv *= vec2(tiling);
    ALBEDO = texture(sky_texture, uv).rgb;
}