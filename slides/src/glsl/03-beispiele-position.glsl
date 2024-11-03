precision mediump float;

uniform vec3 iResolution;
uniform vec4 iMouse;

const vec4 color1 = normalize(vec4(0, 35, 34, 255)); // #002322
const vec4 color2 = normalize(vec4(0, 99, 96, 255)); // #006360
const vec4 color3 = normalize(vec4(255, 244, 117, 255)); // #fff475

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 uvMouse = iMouse.xy / iResolution.xy;

    float deltaMouse = distance(gl_FragCoord.xy, iMouse.xy) / 100.0;
    float clampedDeltaMouse = clamp(deltaMouse, 0.0, 1.0);

    float t = iMouse.x / iResolution.x;

    // float lineAShape = smoothstep(1.0 - clamp(distance(deltaMouse, 0.5), 0.0, 1.0), 1.0, clampedDeltaMouse);

    gl_FragColor = vec4(mix(color3, color2, clampedDeltaMouse));
}