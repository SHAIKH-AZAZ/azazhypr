#version 440
// Noise dissolve: the new image burns through the old one in drifting shreds.
// Compile: /usr/lib/qt6/bin/qsb --qt6 -o shaders/dissolve.frag.qsb shaders/dissolve.frag
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;     // 0 = old image, 1 = new image
    float seed;         // different noise per transition
    float aspect;       // width / height, keeps the shreds from stretching
};
layout(binding = 1) uniform sampler2D oldTex;
layout(binding = 2) uniform sampler2D newTex;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x),
               mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 3; i++) {
        v += a * noise(p);
        p = p * 2.03 + vec2(17.1, 9.7);
        a *= 0.5;
    }
    return v / 0.875;               // 3 octaves sum to 0.875 max
}

void main() {
    vec2 uv = qt_TexCoord0;
    float n = fbm(vec2(uv.x * aspect, uv.y) * 3.2 + seed);
    n = clamp((n - 0.1) / 0.8, 0.0, 1.0);             // stretch to the full 0..1 range

    float e = 0.10;                                    // softness of the burning edge
    float p = progress * (1.0 + 2.0 * e) - e;
    float reveal = 1.0 - smoothstep(p - e, p + e, n);

    // outside the burning band only one image is visible: one fetch instead of two
    vec3 col;
    if (reveal <= 0.001) col = texture(oldTex, uv).rgb;
    else if (reveal >= 0.999) col = texture(newTex, uv).rgb;
    else col = mix(texture(oldTex, uv).rgb, texture(newTex, uv).rgb, reveal);

    float rim = reveal * (1.0 - reveal) * 4.0;         // peaks inside the edge band
    col += vec3(1.0, 0.62, 0.28) * rim * 0.45;         // warm glow along the burn line

    fragColor = vec4(col, 1.0) * qt_Opacity;
}
