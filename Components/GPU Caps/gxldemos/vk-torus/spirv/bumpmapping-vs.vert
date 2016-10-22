#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable


layout (std140, binding = 0) uniform uniforms_t
{ 
  mat4 ProjectionMatrix;
  mat4 ViewMatrix;
  mat4 ModelMatrix;
  vec4 uv_tiling;
} ub;


layout (location = 0) in vec4 vposition;
layout (location = 1) in vec4 vtexcoord;
layout (location = 2) in vec4 vnormal;
layout (location = 3) in vec4 vcolor;

layout (location = 0) out vec4 v_color;
layout (location = 1) out vec4 v_texcoord;
layout (location = 2) out vec4 v_normal;
layout (location = 3) out vec4 v_eye_dir;
layout (location = 4) out vec4 v_light_dir;

out gl_PerVertex 
{
  vec4 gl_Position;
  
};

void main()
{
  mat4 ModelViewMatrix = ub.ViewMatrix * ub.ModelMatrix;
  vec4 P = ModelViewMatrix * vposition;
 
  gl_Position = ub.ProjectionMatrix * P;
  // GL->VK conventions
  gl_Position.y = -gl_Position.y;
  gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
  
 
 v_normal = ModelViewMatrix * vnormal;
  
  vec4 v = P;
  v_eye_dir = -v;
  vec4 lp = ub.ViewMatrix * vec4(0.0, 50.0, 50.0, 1.0);
  v_light_dir = lp - v;  
  
  v_color = vcolor;
  v_texcoord = vtexcoord * ub.uv_tiling;
}
