precision mediump float;

void main() {
  const vec4 background = normalize(vec4(36, 41, 46, 255));
  const vec4 fuchsia = normalize(vec4(134, 25, 143, 255));
  const vec4 violet = normalize(vec4(46, 16, 101, 255));

  if(gl_FragCoord.x <= 50.0 && gl_FragCoord.y <= 50.0) {
    gl_FragColor = background;
  } else if(gl_FragCoord.x > gl_FragCoord.y) {
    gl_FragColor = fuchsia;
  } else {
    gl_FragColor = violet;
  }
}