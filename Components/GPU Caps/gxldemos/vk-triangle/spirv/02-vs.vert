#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable


layout (std140, binding = 0) uniform uniforms_t
{ 
  mat4 ViewProjectionMatrix;
  mat4 ModelMatrix;
} ub;


layout (location = 0) in vec4 vposition;
layout (location = 1) in vec4 vtexcoord;
layout (location = 2) in vec4 vnormal;
layout (location = 3) in vec4 vcolor;

layout (location = 0) out vec4 v_color;

out gl_PerVertex 
{
  vec4 gl_Position;
  
};

void main()
{
  vec4 P = ub.ModelMatrix * vposition;
  gl_Position = ub.ViewProjectionMatrix * P;
   
  // GL->VK conventions
  gl_Position.y = -gl_Position.y;
  gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
  
  v_color = vcolor;
}
