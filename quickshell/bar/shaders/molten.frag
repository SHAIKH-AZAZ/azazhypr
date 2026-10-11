#version 440
// Molten ring carousel: up to 7 rounded cards on an arc, fused into one liquid shape with a
// smooth union. Where neighbours are closer than `k`, a bridge (strand) of blended colour and a
// hot glow connects them. Cheap by design for integrated GPUs: hidden slots are skipped, pixels
// far from every card only get the halo, and textures are only fetched for nearby cards.
// Compile: /usr/lib/qt6/bin/qsb --qt6 -o shaders/molten.frag.qsb shaders/molten.frag
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 res;           // size of the item in px
    float k;            // smooth-union radius (bridge reach), px
    float cr;           // corner radius at scale 1, px
    vec4 accent;
    vec4 base;
    vec4 g0;
    vec4 g1;
    vec4 g2;
    vec4 g3;
    vec4 g4;
    vec4 g5;
    vec4 g6;
    vec4 m0;
    vec4 m1;
    vec4 m2;
    vec4 m3;
    vec4 m4;
    vec4 m5;
    vec4 m6;
};
layout(binding = 1) uniform sampler2D t0;
layout(binding = 2) uniform sampler2D t1;
layout(binding = 3) uniform sampler2D t2;
layout(binding = 4) uniform sampler2D t3;
layout(binding = 5) uniform sampler2D t4;
layout(binding = 6) uniform sampler2D t5;
layout(binding = 7) uniform sampler2D t6;

float sdRoundBox(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

float smin(float a, float b, float k) {
    float h = max(k - abs(a - b), 0.0) / k;
    return min(a, b) - h * h * k * 0.25;
}

void main() {
    vec2 frag = qt_TexCoord0 * res;
    float d[7];
    vec2 uv[7];
    float sel[7];

    if (m0.y >= 0.01) {                                   // hidden slots cost nothing
        vec2 p = frag - g0.xy;
        float c = cos(m0.x), s = sin(m0.x);
        p = vec2(c * p.x + s * p.y, -s * p.x + c * p.y);     // into the card's own (rotated) frame
        float r = min(cr * g0.w / 70.0, g0.w);
        d[0] = sdRoundBox(p, g0.zw, r) + (1.0 - m0.y) * 40.0;
        uv[0] = clamp(p / (2.0 * g0.zw) + 0.5, 0.002, 0.998);
        sel[0] = m0.z;
    } else {
        d[0] = 1000.0; uv[0] = vec2(0.5); sel[0] = 0.0;
    }

    if (m1.y >= 0.01) {                                   // hidden slots cost nothing
        vec2 p = frag - g1.xy;
        float c = cos(m1.x), s = sin(m1.x);
        p = vec2(c * p.x + s * p.y, -s * p.x + c * p.y);     // into the card's own (rotated) frame
        float r = min(cr * g1.w / 70.0, g1.w);
        d[1] = sdRoundBox(p, g1.zw, r) + (1.0 - m1.y) * 40.0;
        uv[1] = clamp(p / (2.0 * g1.zw) + 0.5, 0.002, 0.998);
        sel[1] = m1.z;
    } else {
        d[1] = 1000.0; uv[1] = vec2(0.5); sel[1] = 0.0;
    }

    if (m2.y >= 0.01) {                                   // hidden slots cost nothing
        vec2 p = frag - g2.xy;
        float c = cos(m2.x), s = sin(m2.x);
        p = vec2(c * p.x + s * p.y, -s * p.x + c * p.y);     // into the card's own (rotated) frame
        float r = min(cr * g2.w / 70.0, g2.w);
        d[2] = sdRoundBox(p, g2.zw, r) + (1.0 - m2.y) * 40.0;
        uv[2] = clamp(p / (2.0 * g2.zw) + 0.5, 0.002, 0.998);
        sel[2] = m2.z;
    } else {
        d[2] = 1000.0; uv[2] = vec2(0.5); sel[2] = 0.0;
    }

    if (m3.y >= 0.01) {                                   // hidden slots cost nothing
        vec2 p = frag - g3.xy;
        float c = cos(m3.x), s = sin(m3.x);
        p = vec2(c * p.x + s * p.y, -s * p.x + c * p.y);     // into the card's own (rotated) frame
        float r = min(cr * g3.w / 70.0, g3.w);
        d[3] = sdRoundBox(p, g3.zw, r) + (1.0 - m3.y) * 40.0;
        uv[3] = clamp(p / (2.0 * g3.zw) + 0.5, 0.002, 0.998);
        sel[3] = m3.z;
    } else {
        d[3] = 1000.0; uv[3] = vec2(0.5); sel[3] = 0.0;
    }

    if (m4.y >= 0.01) {                                   // hidden slots cost nothing
        vec2 p = frag - g4.xy;
        float c = cos(m4.x), s = sin(m4.x);
        p = vec2(c * p.x + s * p.y, -s * p.x + c * p.y);     // into the card's own (rotated) frame
        float r = min(cr * g4.w / 70.0, g4.w);
        d[4] = sdRoundBox(p, g4.zw, r) + (1.0 - m4.y) * 40.0;
        uv[4] = clamp(p / (2.0 * g4.zw) + 0.5, 0.002, 0.998);
        sel[4] = m4.z;
    } else {
        d[4] = 1000.0; uv[4] = vec2(0.5); sel[4] = 0.0;
    }

    if (m5.y >= 0.01) {                                   // hidden slots cost nothing
        vec2 p = frag - g5.xy;
        float c = cos(m5.x), s = sin(m5.x);
        p = vec2(c * p.x + s * p.y, -s * p.x + c * p.y);     // into the card's own (rotated) frame
        float r = min(cr * g5.w / 70.0, g5.w);
        d[5] = sdRoundBox(p, g5.zw, r) + (1.0 - m5.y) * 40.0;
        uv[5] = clamp(p / (2.0 * g5.zw) + 0.5, 0.002, 0.998);
        sel[5] = m5.z;
    } else {
        d[5] = 1000.0; uv[5] = vec2(0.5); sel[5] = 0.0;
    }

    if (m6.y >= 0.01) {                                   // hidden slots cost nothing
        vec2 p = frag - g6.xy;
        float c = cos(m6.x), s = sin(m6.x);
        p = vec2(c * p.x + s * p.y, -s * p.x + c * p.y);     // into the card's own (rotated) frame
        float r = min(cr * g6.w / 70.0, g6.w);
        d[6] = sdRoundBox(p, g6.zw, r) + (1.0 - m6.y) * 40.0;
        uv[6] = clamp(p / (2.0 * g6.zw) + 0.5, 0.002, 0.998);
        sel[6] = m6.z;
    } else {
        d[6] = 1000.0; uv[6] = vec2(0.5); sel[6] = 0.0;
    }

    float D = d[0];
    float dmin = d[0];
    for (int i = 1; i < 7; i++) { D = smin(D, d[i], k); dmin = min(dmin, d[i]); }

    // empty space: just the soft halo, no texture work
    if (D > 1.0) {
        float halo = exp(-D * 0.10) * 0.22;
        if (halo < 0.004) { fragColor = vec4(0.0); return; }
        fragColor = vec4(accent.rgb * halo, halo) * qt_Opacity;
        return;
    }

    vec3 col = vec3(0.0);
    float wsum = 1e-4;
    if (d[0] < 28.0) {                                   // far cards add nothing: skip the fetch
        vec4 t = texture(t0, uv[0]);
        float w = exp(-max(d[0], 0.0) * 0.22);
        col += mix(base.rgb, t.rgb, t.a) * w; wsum += w;
    }
    if (d[1] < 28.0) {                                   // far cards add nothing: skip the fetch
        vec4 t = texture(t1, uv[1]);
        float w = exp(-max(d[1], 0.0) * 0.22);
        col += mix(base.rgb, t.rgb, t.a) * w; wsum += w;
    }
    if (d[2] < 28.0) {                                   // far cards add nothing: skip the fetch
        vec4 t = texture(t2, uv[2]);
        float w = exp(-max(d[2], 0.0) * 0.22);
        col += mix(base.rgb, t.rgb, t.a) * w; wsum += w;
    }
    if (d[3] < 28.0) {                                   // far cards add nothing: skip the fetch
        vec4 t = texture(t3, uv[3]);
        float w = exp(-max(d[3], 0.0) * 0.22);
        col += mix(base.rgb, t.rgb, t.a) * w; wsum += w;
    }
    if (d[4] < 28.0) {                                   // far cards add nothing: skip the fetch
        vec4 t = texture(t4, uv[4]);
        float w = exp(-max(d[4], 0.0) * 0.22);
        col += mix(base.rgb, t.rgb, t.a) * w; wsum += w;
    }
    if (d[5] < 28.0) {                                   // far cards add nothing: skip the fetch
        vec4 t = texture(t5, uv[5]);
        float w = exp(-max(d[5], 0.0) * 0.22);
        col += mix(base.rgb, t.rgb, t.a) * w; wsum += w;
    }
    if (d[6] < 28.0) {                                   // far cards add nothing: skip the fetch
        vec4 t = texture(t6, uv[6]);
        float w = exp(-max(d[6], 0.0) * 0.22);
        col += mix(base.rgb, t.rgb, t.a) * w; wsum += w;
    }
    col /= wsum;

    float cover = 1.0 - smoothstep(-1.2, 1.0, D);
    // bridges: inside the fused shape but outside every card
    float strand = smoothstep(0.0, 5.0, dmin) * cover;
    col = mix(col, col * 0.55 + vec3(1.0, 0.52, 0.16) * 0.6, strand * 0.65);

    // accent rim on the selected card
    float rim = 0.0;
    for (int i = 0; i < 7; i++) rim = max(rim, sel[i] * (1.0 - smoothstep(0.0, 2.2, abs(d[i]))));
    col = mix(col, accent.rgb, rim * 0.95);

    float halo = exp(-max(D, 0.0) * 0.10) * 0.22 * (1.0 - cover);
    float a = max(cover, halo);
    vec3 outc = mix(col, accent.rgb, 1.0 - cover);
    fragColor = vec4(outc * a, a) * qt_Opacity;
}
