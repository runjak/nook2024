/*
Sources:

rotation matrices: https://thebookofshaders.com/08/
erot: https://suricrasia.online/blog/shader-functions/
normals: https://www.youtube.com/watch?v=BNZtUB7yhX4
ray marching: https://michaelwalczyk.com/blog-ray-marching.html
reflections:
  https://math.stackexchange.com/questions/13261/how-to-get-a-reflection-vector
  http://www.sunshine2k.de/articles/coding/vectorreflection/vectorreflection.html
  https://registry.khronos.org/OpenGL-Refpages/gl4/html/reflect.xhtml
distance functions: https://iquilezles.org/articles/distfunctions/
*/

precision mediump float;

uniform vec3 iResolution;
uniform float iGlobalTime;

const float pi = 3.1415926535897932384626433832795;

vec3 erot(vec3 p, vec3 ax, float ro) {
  return mix(dot(ax, p) * ax, p, cos(ro)) + cross(ax, p) * sin(ro);
}

float dot2(vec2 v) {
  return dot(v, v);
}

float sdTorus(vec3 p, vec2 t) {
  vec2 q = vec2(length(p.xz) - t.x, p.y);
  return length(q) - t.y;
}

float sdRoundBox(vec3 p, vec3 b, float r) {
  vec3 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

float sdCappedCylinder(vec3 p, float h, float r) {
  vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdRoundedCylinder(vec3 p, float ra, float rb, float h) {
  vec2 d = vec2(length(p.xz) - 2.0 * ra + rb, abs(p.y) - h);
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - rb;
}

float sdCappedCone(vec3 p, float h, float r1, float r2) {
  vec2 q = vec2(length(p.xz), p.y);
  vec2 k1 = vec2(r2, h);
  vec2 k2 = vec2(r2 - r1, 2.0 * h);
  vec2 ca = vec2(q.x - min(q.x, (q.y < 0.0) ? r1 : r2), abs(q.y) - h);
  vec2 cb = q - k1 + k2 * clamp(dot(k1 - q, k2) / dot2(k2), 0.0, 1.0);
  float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
  return s * sqrt(min(dot2(ca), dot2(cb)));
}

float sdDisc(vec3 p, vec2 t) {
  float torus = sdTorus(p, t);
  float cylinder = sdCappedCylinder(p, t.y, t.x);
  return min(torus, cylinder);
}

float sdDoor(vec3 p, vec3 size, float r) {
  float box = sdRoundBox(p, size, r);
  float cylinder = sdCappedCylinder(erot(p - vec3(0., size.y - r, 0.), vec3(1., 0., 0.), pi * 0.5), size.z, size.x);

  return min(box, cylinder);
}

float sdDoors(vec3 p, vec3 size, float r) {
  float door1 = sdDoor(p, size, r);
  p = erot(p, vec3(0., 1., 0.), pi * 0.5);
  float door2 = sdDoor(p, size, r);

  return min(door1, door2);
}

float sdRailing(vec3 p, float ra, float rb, float h) {
  const int NUMBER_OF_POSTS = 16;
  const float postAngle = 2.0 * pi / float(NUMBER_OF_POSTS);

  float rail = sdTorus(p - vec3(0.0, h + 4.0 * rb, 0.0), vec2(ra, rb));

  float posts = 1.0 / 0.0;
  for(int i = 0; i < NUMBER_OF_POSTS; i++) {
    float angle = (float(i) + 0.5) * postAngle;
    vec3 pDelta = erot(vec3(0.0, h, ra), vec3(0.0, 1.0, 0.0), angle);

    float post = sdCappedCylinder(p - pDelta, h, rb * 0.5);
    posts = min(posts, post);
  }

  return min(rail, posts);
}

vec3 up(float y) {
  return vec3(0.0, y, 0.0);
}

float sdLighthouse(vec3 p) {
  // Positives
  float disc1 = sdDisc(p - vec3(0.0), vec2(63.5, 9.0));
  float disc2 = sdDisc(p - up(100.0), vec2(50.0, 4.5));
  float disc3 = sdDisc(p - up(180.0), vec2(40.75, 4.5));

  float cone1 = sdCappedCone(p - up(110.0), 110.0, 63.5, 35.5);
  float cone2 = sdCappedCone(p - up(220.0), 7.5, 35.5, 44.0);

  float tower = min(min(disc1, min(disc2, disc3)), min(cone1, cone2));

  float disc4 = sdRoundedCylinder(p - up(245.0), 22.5, 4.5, 10.0);
  float disc5 = sdDisc(p - up(255.0), vec2(50.0, 4.5));
  float railing = sdRailing(p - up(258.0), 50.0, 2.5, 10.0);

  float balcony = min(min(disc4, disc5), railing);

  float cabinBase = sdRoundedCylinder(p - up(305.0), 17.5, 4.5, 40.0);
  float disc6 = sdDisc(p - up(345.0), vec2(37.5, 4.5));
  float disc7 = sdDisc(p - up(355.0), vec2(32.5, 4.5));

  float cabin = min(cabinBase, min(disc6, disc7));

  float cone3 = sdCappedCone(p - up(365.0), 9.0, 32.5, 15.0);
  float cone4 = sdCappedCone(p - up(383.0), 9.0, 15.0, 5.0);
  float cone5 = sdCappedCone(p - up(401.0), 9.0, 5.0, 2.5);
  float cone6 = sdCappedCone(p - up(410.0), 4.5, 5.0, 0.0);
  float roof = min(min(cone3, cone4), min(cone5, cone6));

  float wanted = min(min(tower, balcony), min(cabin, roof));

  // Negatives
  float doors1 = sdDoors(p - up(28.0), vec3(17.0, 19.0, 63.5), 5.0);
  float doors2 = sdDoors(p - up(120.0), vec3(13.5, 18.0, 63.5), 5.0);
  float doors3 = sdDoors(p - up(200.0), vec3(7.5, 11.0, 63.5), 5.0);
  float doors4 = sdDoors(p - up(295.0), vec3(15.0, 19.0, 37.5), 5.0);

  float unwanted = min(min(doors1, doors2), min(doors3, doors4));

  return max(wanted, -unwanted);
}

float sdf(vec3 p) {
  p = vec3(p.xy - vec2(0.0, 18.0), p.z);
  p = erot(p, normalize(vec3(0.075, 1.0, 0.0)), -0.5 * iGlobalTime);

  return sdLighthouse(p);
}

vec3 sdfNormal(vec3 p) {
  const float EPS = 0.001;

  vec3 v1 = vec3(sdf(p + vec3(EPS, 0.0, 0.0)), sdf(p + vec3(0.0, EPS, 0.0)), sdf(p + vec3(0.0, 0.0, EPS)));
  vec3 v2 = vec3(sdf(p - vec3(EPS, 0.0, 0.0)), sdf(p - vec3(0.0, EPS, 0.0)), sdf(p - vec3(0.0, 0.0, EPS)));

  return normalize(v1 - v2);
}

float rayMarch(vec3 start, vec3 direction) {
  const int NUMBER_OF_STEPS = 128;
  const float MINIMUM_HIT_DISTANCE = 0.001;
  const float MAXIMUM_TRACE_DISTANCE = 1000.0;

  float distance_traveled = 0.0;

  for(int i = 0; i < NUMBER_OF_STEPS; i++) {
    vec3 current_position = start + direction * distance_traveled;

    float distance_to_closest = sdf(current_position);
    distance_traveled += distance_to_closest;

    if(distance_to_closest < MINIMUM_HIT_DISTANCE) {
      return distance_traveled;
    }

    if(distance_traveled > MAXIMUM_TRACE_DISTANCE) {
      break;
    }
  }

  return -1.0;
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;

  vec3 start = vec3((uv - vec2(0.5, 0.0)) * 512.0, 127.0);
  const vec3 direction = vec3(0.0, 0.0, -1.0);

  float hitDistance = rayMarch(start, direction);

  if(hitDistance >= 0.0) {
    vec3 hitPoint = start + direction * hitDistance;
    vec3 normal = sdfNormal(hitPoint);
    vec3 color = normal * 0.5 + 0.5;

    gl_FragColor = vec4(color, 1.0);
  } else {
    gl_FragColor = vec4(0.0);
  }
}