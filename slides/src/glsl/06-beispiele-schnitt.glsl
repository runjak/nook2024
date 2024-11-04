precision mediump float;

uniform vec3 iResolution;
uniform float iGlobalTime;

const vec4 color1 = normalize(vec4(0, 35, 34, 255)); // #002322
const vec4 color2 = normalize(vec4(0, 99, 96, 255)); // #006360
const vec4 color3 = normalize(vec4(255, 244, 117, 255)); // #fff475

float sdfCircle(vec2 position, float radius) {
  return length(position) - radius;
}

vec4 chooseColor(float value, float gradient, vec4 inside, vec4 outside) {
  return mix(inside, outside, clamp(value * gradient, 0., 1.));
}

float sdfRectangle(vec2 position, vec2 size) {
  vec2 delta = abs(position) - size * 0.5;
  return max(delta.x, delta.y);
}

float outsideCenter(vec2 position) {
  return sdfRectangle(position, vec2(2.));
}

vec2 rotate(vec2 position, float angle) {
  float s = sin(angle);
  float c = cos(angle);

  mat2 m = mat2(c, s, -s, c);

  return m * position;
}

vec2 tile(vec2 position, vec2 counts) {
  vec2 uv = position * 0.5 + vec2(0.5);
  vec2 tiled = fract(uv * counts);
  return (tiled - vec2(0.5)) * 2.0;
}

void main() {
  float minDim = min(iResolution.x, iResolution.y);
  vec2 margins = iResolution.xy - vec2(minDim);

  vec2 base = margins / 2.;
  vec2 size = iResolution.xy - margins;

  vec2 uv = ((gl_FragCoord.xy - base) / size);
  vec2 domain = (uv - vec2(0.5)) * 2.0;

  float outside = outsideCenter(domain);
  if(outside > 0.) {
    gl_FragColor = color2;
    return;
  }

  float rect = sdfRectangle(domain  + vec2(0.25, 0.0), vec2(1.0));
  float circ = sdfCircle(domain - vec2(0.25, 0.0), 0.5);
  float inBoth = max(rect, circ);

  gl_FragColor = chooseColor(inBoth, 100., color3, color1);
}