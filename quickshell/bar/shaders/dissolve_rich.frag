#version 440
// "rich" wallpaper dissolve: port of the Morph Gallery web shader (WebGL1 -> Qt GLSL 440).
//   - 5-octave simplex fbm gives every pixel a threshold; `progress` sweeps past them
//   - the threshold is biased by the luminance of the INCOMING frame, so its bright areas
//     burn through first
//   - both frames slide against each other (parallax) with mirrored UVs
// Compile: /usr/lib/qt6/bin/qsb --qt6 -o shaders/dissolve_rich.frag.qsb shaders/dissolve_rich.frag
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;     // 0 = old image, 1 = new image (already eased)
    float seed;         // per-transition noise offset
    float aspect;       // width / height: keeps shreds round
    float scale;        // fbm frequency, higher = finer shreds
    float direction;    // +1 / -1: which way the frames drift
    float edge;         // width of the dissolve front
    float drift;        // how far the frames slide
};
layout(binding = 1) uniform sampler2D oldTex;
layout(binding = 2) uniform sampler2D newTex;

vec3 permute(vec3 x) { return mod(((x * 34.0) + 1.0) * x, 289.0); }

float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod(i, 289.0);
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m * m;
    m = m * m;
    vec3 x  = 2.0 * fract(p * C.www) - 1.0;
    vec3 h  = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

float fbm(vec2 v) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 5; i++) {
        value += amplitude * snoise(v);
        v *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// the drift pushes UVs past the image edge: reflect instead of smearing the last row
vec2 mirror(vec2 uv) { return 1.0 - abs(1.0 - mod(uv, 2.0)); }

void main() {
    vec2 uv = qt_TexCoord0;

    // widen the sweep by one edge at each end so progress 0 and 1 are fully one image
    float adjusted = progress * (1.0 + 2.0 * edge) - edge;

    float n = fbm(vec2(uv.x * aspect, uv.y) * scale + vec2(seed, progress * direction)) * 0.5 + 0.5;
    n = clamp((n - 0.2) / 0.6, 0.0, 1.0);                       // stretch fbm to the full 0..1 range
    // Luminance bias: bright areas of the incoming frame get a lower threshold, so they cross the
    // front first and the new image burns through. The web version adds the raw luminance and
    // smoothsteps the sum, which for dark images squeezes the whole dissolve into a few frames of
    // the sweep; mixing a bounded bias keeps the full 0..1 range, so the dissolve fills `duration`.
    float lum = dot(texture(newTex, uv).rgb, vec3(0.299, 0.587, 0.114));
    float noise = clamp(n * 0.7 + (1.0 - lum) * 0.3, 0.0, 1.0);

    float mixFactor = 1.0 - smoothstep(adjusted - edge, adjusted + edge, noise);

    // frames slide by different amounts in opposite directions: parallax between the tatters
    vec2 fromUV = mirror(uv + vec2(0.0, noise * progress * drift * direction));
    vec2 toUV   = mirror(uv + vec2(0.0, noise * (1.0 - progress) * -0.5 * drift * direction));

    // outside the front only one frame is visible: skip the other fetch
    vec4 col;
    if (mixFactor <= 0.001)      col = texture(oldTex, fromUV);
    else if (mixFactor >= 0.999) col = texture(newTex, toUV);
    else                         col = mix(texture(oldTex, fromUV), texture(newTex, toUV), mixFactor);

    fragColor = vec4(col.rgb, 1.0) * qt_Opacity;
}
