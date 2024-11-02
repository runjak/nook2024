precision mediump float;

// https://en.wikibooks.org/wiki/Fractals/shadertoy#uniforms
uniform vec3 iResolution;

const vec4 color1 = normalize(vec4(0, 35, 34, 255)); // #002322
const vec4 color2 = normalize(vec4(0, 99, 96, 255)); // #006360

void main() {
  vec2 relCoord = gl_FragCoord.xy / iResolution.xy;

  gl_FragColor = mix(color1, color2, relCoord.y);
}