#version 450

layout (location = 0) in vec4 v_color;

out vec4 FragColor;

void main()
{
  FragColor = v_color;
}
