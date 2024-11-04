precision mediump float;

uniform vec3 iResolution;

const vec4 color1 = normalize(vec4(0, 35, 34, 255)); // #002322
const vec4 color2 = normalize(vec4(0, 99, 96, 255)); // #006360
const vec4 color3 = normalize(vec4(255, 244, 117, 255)); // #fff475

float sdfCircle(vec2 position, float radius) {
  return length(position) - radius;
}

vec4 chooseColor(float value, float gradient, vec4 inside, vec4 outside) {
  return mix(inside, outside, clamp(value * gradient, 0., 1.));
}

float outsideCenter(vec2 position) {
  vec2 delta = abs(position) - vec2(1.);
  return max(delta.x, delta.y);
}

void main() {
  float minDim = min(iResolution.x, iResolution.y);
  vec2 margins = iResolution.xy - vec2(minDim);

  vec2 base = margins / 2.;
  vec2 size = iResolution.xy - margins;

  vec2 uv = ((gl_FragCoord.xy - base) / size);
  vec2 centerUv = (uv - vec2(0.5)) * 2.0;

  float outside = outsideCenter(centerUv);
  if(outside > 0.) {
    gl_FragColor = color2;
    return;
  }

  float inCircle = sdfCircle(centerUv, 0.5);

  gl_FragColor = chooseColor(inCircle, 100., color3, color1);
}