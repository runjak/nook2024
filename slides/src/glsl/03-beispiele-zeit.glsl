precision mediump float;

uniform vec3 iResolution;
uniform float iGlobalTime;

const vec4 color1 = normalize(vec4(0, 35, 34, 255)); // #002322
const vec4 color2 = normalize(vec4(0, 99, 96, 255)); // #006360
const vec4 color3 = normalize(vec4(255, 244, 117, 255)); // #fff475

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;

  float curve = 0.5 * sin((9.25 * uv.x) + (2 * iGlobalTime));
  float lineAShape = smoothstep(1.0 - clamp(distance(curve + uv.y, 0.5), 0.0, 1.0), 1.0, 0.99);

  gl_FragColor = (1.0 - lineAShape) * vec4(mix(color3, color2, lineAShape));
}