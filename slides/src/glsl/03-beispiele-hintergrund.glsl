precision mediump float;

// #002322 -> vec4(0, 35, 34, 255)
const vec4 background = normalize(vec4(0, 35, 34, 255));

void main() {
    gl_FragColor = background;
}