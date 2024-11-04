precision mediump float;

uniform vec3 iResolution;

const vec4 color1 = normalize(vec4(0, 35, 34, 255)); // #002322
const vec4 color2 = normalize(vec4(0, 99, 96, 255)); // #006360
const vec4 color3 = normalize(vec4(255, 244, 117, 255)); // #fff475

float sdfCircle(vec2 position, float radius) {
  return length(position) - radius;
}

vec4 chooseColor(float value, vec4 c1, vec4 c2) {
  if(value >= 0.0) {
    return c1;
  }

  return c2;
}

void main() {
  vec2 uv = (gl_FragCoord.xy / iResolution.xy);
  vec2 centerUv = (uv - vec2(0.5)) * 2.0;

  float inCircle = sdfCircle(centerUv, 0.5);

  gl_FragColor = chooseColor(inCircle, color1, color3);
}