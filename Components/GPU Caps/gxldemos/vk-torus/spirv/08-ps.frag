#version 450

layout (location = 0) in vec4 v_color;
layout (location = 1) in vec4 v_texcoord;
layout (location = 2) in vec4 v_normal;
layout (location = 3) in vec4 v_eye_dir;
layout (location = 4) in vec4 v_light_dir;

layout (binding = 1) uniform sampler2D tex;


out vec4 FragColor;

void main()
{
  vec2 uv = v_texcoord.xy;
  //uv.y = 1.0 - uv.y;
  
  vec4 c0 = texture(tex, uv);
  
  vec4 N = normalize(v_normal);
  vec4 L = normalize(v_light_dir);  
  
  vec3 fc = vec3(0.0, 0.0, 0.0);
  
  vec4 la0 = vec4(0.2, 0.2, 0.2, 1.0);
  vec4 ld0 = vec4(0.9, 0.85, 0.8, 1.0);
  vec4 ls0 = vec4(0.9, 0.9, 0.9, 1.0);
  vec4 mA = vec4(0.8, 0.8, 0.8, 1.0);
  vec4 mD = vec4(0.9, 0.9, 0.9, 1.0);
  vec4 mS = vec4(0.9, 0.9, 0.9, 1.0);
  float mSpecExp = 60.0;  
  
  fc += (la0.rgb * mA.rgb) * c0.rgb;
  float lambert = dot(N,L);
  if (lambert > 0)
  {
    fc += ld0.rgb * mD.rgb * lambert * c0.rgb;
    
    vec4 E = normalize(v_eye_dir);
    vec4 R = reflect(-L, N);
    float specular = pow(abs(dot(R, E)), mSpecExp);
    fc += ls0.rgb * mS.rgb * specular;	
  } 
  
  FragColor = vec4(fc.xyz, 1.0);
}
