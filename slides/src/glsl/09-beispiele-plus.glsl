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

vec3 erot(vec3 p, vec3 ax, float ro) {
  return mix(dot(ax, p)*ax, p, cos(ro)) + cross(ax,p)*sin(ro);
}

float sdTorus(vec3 p, vec2 t){
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float torus(in vec3 p) {
  const float r1 = 0.25;
  const float r2 = 0.125;
  
  return sdTorus(p, vec2(r1, r2));
}

float sdRoundBox(vec3 p, vec3 b, float r) {
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float opSmoothUnion(float d1, float d2, float k) {
  float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
  return mix(d2, d1, h) - k * h * (1.0 - h);
}

float sdPlus(vec3 p, vec2 b, float r) {
  float b1 = sdRoundBox(p, b.xyy, r);
  float b2 = sdRoundBox(p, b.yxy, r);
  float b3 = sdRoundBox(p, b.yyx, r);
  
  return opSmoothUnion(b1, opSmoothUnion(b2, b3, 0.025), 0.025);
}

float sdf(in vec3 p) {
  p = vec3(p.xy - vec2(0.5), p.z);
  p = erot(p, normalize(vec3(1.0, 1.0, 0.0)), 0.5 * iGlobalTime);
  // p = vec3(fract(p.xy), p.z);

  return sdPlus(p, vec2(0.25, 0.25/3.0), 0.025);
  //return sdRoundBox(p, vec3(0.25),0.025);
  return torus(p);
}

vec3 sdfNormal(in vec3 p) {
  const float EPS = 0.001;
  
  vec3 v1 = vec3(sdf(p + vec3(EPS, 0.0, 0.0)), sdf(p + vec3(0.0, EPS, 0.0)), sdf(p + vec3(0.0, 0.0, EPS)));
  vec3 v2 = vec3(sdf(p - vec3(EPS, 0.0, 0.0)), sdf(p - vec3(0.0, EPS, 0.0)), sdf(p - vec3(0.0, 0.0, EPS)));
  
  return normalize(v1 - v2);
}

float rayMarch(in vec3 start, in vec3 direction) {
  const int NUMBER_OF_STEPS = 32;
  const float MINIMUM_HIT_DISTANCE = 0.001;
  const float MAXIMUM_TRACE_DISTANCE = 1000.0;
  
  float distance_traveled = 0.0;
  
  for (int i = 0; i < NUMBER_OF_STEPS; i++) {
    vec3 current_position = start + direction * distance_traveled;
    
    float distance_to_closest = sdf(current_position);
    distance_traveled += distance_to_closest;
    
    if (distance_to_closest < MINIMUM_HIT_DISTANCE) {
      return distance_traveled;
    }
    
    if (distance_traveled > MAXIMUM_TRACE_DISTANCE) {
      break;
    }
  }
  
  return -1.0;
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
  vec3 start = vec3(uv, 1.0);
  const vec3 direction = vec3(0.0, 0.0, -1.0);
    
  float hitDistance = rayMarch(start, direction);
  
  if (hitDistance >= 0.0) {
    vec3 hitPoint = start + direction * hitDistance;
    vec3 normal = sdfNormal(hitPoint);
    vec3 color = normal * 0.5 + 0.5;
    
    vec3 reflectDirection = reflect(direction, normal);
    float reflectDistance = rayMarch(hitPoint + reflectDirection * 2.0, direction);
    
    if (reflectDistance >= 0.0) {
      vec3 reflectPoint = hitPoint + reflectDirection * reflectDistance;
      vec3 reflectNormal = sdfNormal(reflectPoint);
      vec3 reflectColor = reflectNormal * 0.5 + 0.5;
      
      gl_FragColor = vec4(reflectColor, 1.0);
    } else {
      gl_FragColor = vec4(color, 1.0);
    }
  } else {
    gl_FragColor = vec4(0.0);
  } 
}