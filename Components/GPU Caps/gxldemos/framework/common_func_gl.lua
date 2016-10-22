

function GetGpuMemoryTotal()
  local gpu_mem_total = gh_renderer.get_gpu_memory_total_available_kb_nv()
  if (gpu_mem_total <= 0) then
    gpu_mem_total = gh_renderer.get_gpu_memory_total_available_kb_amd()
  end
  return gpu_mem_total
end


function GetGpuMemoryUsage()
  local _gpu_mem_usage = gh_renderer.get_gpu_memory_usage_kb_nv()
  if (_gpu_mem_usage <= 0) then
    _gpu_mem_usage = gh_renderer.get_gpu_memory_usage_kb_amd()
  end
  return _gpu_mem_usage
end  
   


function Init_Misc_GL()
  
  gh_renderer.set_vsync(0)
  gh_renderer.set_depth_test_state(1)
  
end


function Frame_Begin_GL(r, g, b)

  gh_renderer.clear_color_depth_buffers(r, g, b, 1.0, 1.0)
  
end  


function Frame_End_GL()
  
end  


function OSI_Init_GL(framework_dir, osi_info)


  local vs_gl2=" \
#version 120 \
uniform mat4 gxl3d_ViewProjectionMatrix; \
uniform mat4 gxl3d_ModelMatrix; \
uniform vec4 gxl3d_Viewport; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main() \
{ \
  vec4 P = gl_Vertex; \
  vec4 Pw = gxl3d_ModelMatrix * P; \
  Pw.x = Pw.x - gxl3d_Viewport.z/2; \
  Pw.y = Pw.y + gxl3d_Viewport.w/2; \
  gl_Position = gxl3d_ViewProjectionMatrix * Pw; \
  Vertex_UV = gl_MultiTexCoord0; \
  Vertex_Color = gl_Color; \
}"
  

  local ps_gl2=" \
#version 120 \
uniform sampler2D tex0; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main (void) \
{ \
  vec2 uv = Vertex_UV.xy; \
  float t = texture2D(tex0,uv).r; \
  gl_FragColor = vec4(t * Vertex_Color.rgb, 1.0);  \
}"

  local vs_gl3=" \
#version 150 \
in vec4 gxl3d_Position;\
in vec4 gxl3d_TexCoord0;\
in vec4 gxl3d_Color;\
uniform mat4 gxl3d_ViewProjectionMatrix; \
uniform mat4 gxl3d_ModelMatrix; \
uniform vec4 gxl3d_Viewport; \
out vec4 Vertex_UV; \
out vec4 Vertex_Color; \
void main() \
{ \
  vec4 P = gxl3d_Position; \
  vec4 Pw = gxl3d_ModelMatrix * P; \
  Pw.x = Pw.x - gxl3d_Viewport.z/2; \
  Pw.y = Pw.y + gxl3d_Viewport.w/2; \
  gl_Position = gxl3d_ViewProjectionMatrix * Pw; \
  Vertex_UV = gxl3d_TexCoord0; \
  Vertex_Color = gxl3d_Color; \
}"
  

  local ps_gl3=" \
#version 150 \
uniform sampler2D tex0; \
in vec4 Vertex_UV; \
in vec4 Vertex_Color; \
out vec4 FragColor; \
void main (void) \
{ \
  vec2 uv = Vertex_UV.xy; \
  float t = texture(tex0,uv).r; \
  FragColor = vec4(t * Vertex_Color.rgb, 1.0);  \
}"

  local vs = ""
  local ps = ""
  if (gh_renderer.get_api_version_major() < 3) then
    vs = vs_gl2
    ps = ps_gl2
  else
    vs = vs_gl3
    ps = ps_gl3
  end
  kx_font_prog = gh_gpu_program.create_v2("kx_font_program", vs, ps)
  -- font_prog = gh_node.getid("font_prog")
  

  kx_font_h1 = gh_font.create(framework_dir .. "data/fonts/HACKED.ttf", 30, 512, 512)
  gh_font.build_texture(kx_font_h1)
  kx_tex_font_h1 = gh_font.get_texture(kx_font_h1)

  kx_font_p = gh_font.create(framework_dir .. "data/fonts/Hack-Regular.ttf", 20, 512, 512)
  gh_font.build_texture(kx_font_p)
  kx_tex_font_p = gh_font.get_texture(kx_font_p)
  
  
  
  
  
  
  
  
  local tex_vs_gl2=" \
#version 120 \
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gl_Vertex; \
  Vertex_UV = gl_MultiTexCoord0; \
  Vertex_Color = gl_Color; \
}"
  

  local tex_ps_gl2=" \
#version 120 \
uniform sampler2D tex0; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main (void) \
{ \
  vec2 uv = Vertex_UV.xy; \
  vec3 c = texture2D(tex0,uv).rgb; \
  //gl_FragColor = vec4(c * Vertex_Color.rgb, 1.0);  \
  gl_FragColor = vec4(c, 1.0);  \
}"

  local tex_vs_gl3=" \
#version 150 \
in vec4 gxl3d_Position;\
in vec4 gxl3d_TexCoord0;\
in vec4 gxl3d_Color;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
out vec4 Vertex_UV; \
out vec4 Vertex_Color; \
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position; \
  Vertex_UV = gxl3d_TexCoord0; \
  Vertex_Color = gxl3d_Color; \
}"
  

  local tex_ps_gl3=" \
#version 150 \
uniform sampler2D tex0; \
in vec4 Vertex_UV; \
in vec4 Vertex_Color; \
out vec4 FragColor; \
void main (void) \
{ \
  vec2 uv = Vertex_UV.xy; \
  uv.y *= -1.0; \
  vec3 c = texture(tex0,uv).rgb; \
  FragColor = vec4(c * Vertex_Color.rgb, 1.0);  \
  //FragColor = vec4(c, 1.0);  \
}"

  vs = ""
  ps = ""
  if (gh_renderer.get_api_version_major() < 3) then
    vs = tex_vs_gl2
    ps = tex_ps_gl2
  else
    vs = tex_vs_gl3
    ps = tex_ps_gl3
  end
  kx_texture_prog = gh_gpu_program.create_v2("kx_texture_prog", vs, ps)
  
  
  local pixel_format = PF_U8_RGBA
  kx_tex_3dapi_logo = gh_texture.create_from_file_v5(framework_dir .. "data/textures/gl.png", pixel_format)
  kx_logo_quad = gh_mesh.create_quad(300, 124)
  
  
  
  
  
  
  
  
  
  
  osi_info.renderer_name = gh_renderer.get_renderer_model()
  osi_info.api_version = gh_renderer.get_api_version()

  osi_info.vram_total = GetGpuMemoryTotal()
  osi_info.vram_usage = GetGpuMemoryUsage()
  
  local vsync_interval = gh_renderer.get_vsync()
  if (vsync_interval > 0) then
    osi_info.vsync_status = "vsync: ON"
  else    
    osi_info.vsync_status = "vsync: OFF"
  end

end



function OSI_Display_GL(osi_info, elapsed_time)

  gh_camera.bind(kx_camera_ortho)
  
  

  --[[
  local BLEND_FACTOR_ONE = 1
  local BLEND_FACTOR_SRC_ALPHA = 2
  local BLEND_FACTOR_ONE_MINUS_DST_ALPHA = 3
  local BLEND_FACTOR_ONE_MINUS_DST_COLOR = 4
  local BLEND_FACTOR_ONE_MINUS_SRC_ALPHA = 5
  local BLEND_FACTOR_DST_COLOR = 6
  local BLEND_FACTOR_DST_ALPHA = 7
  local BLEND_FACTOR_SRC_COLOR = 8
  local BLEND_FACTOR_ONE_MINUS_SRC_COLOR = 9
  gh_renderer.set_blending_state(1)
  gh_renderer.set_blending_factors(BLEND_FACTOR_ONE, BLEND_FACTOR_ONE)
  --]]

  -- gh_renderer.blending_on("additive")
  gh_renderer.blending_on("") -- defaut is additive: BLEND_FACTOR_ONE + BLEND_FACTOR_ONE

  gh_renderer.set_depth_test_state(0)
--gh_renderer.disable_state("GL_CULL_FACE")



  local y_offset = 20
  local x_offset = 10

  gh_gpu_program.bind(kx_font_prog)


  local f = kx_font_h1
  gh_font.clear(f)
  gh_font.text_2d(f, 10, winH-10, 1, 0.8, 0, 1, osi_info.demo_caption)
  gh_font.update(f, 0)
  gh_texture.bind(kx_tex_font_h1, 0)
  gh_font.render(f)



  local f = kx_font_p
  gh_font.clear(f)

  local text = string.format("%.0f FPS", osi_info.fps)
  local text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, winW - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  text = string.format("%.2fms", osi_info.dt_ms)
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, winW - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  text = string.format("Frame: %.0f", osi_info.frames)
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, winW - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20


  if (kx_num_gpus > 0) then
    text = "avg  min   max  last"
    text_width = gh_font.get_text_width(f, text)
    gh_font.text_2d(f, winW - text_width - 20, y_offset, 1, 1, 1, 1, text)
    y_offset = y_offset + 20
    
    
    if ((elapsed_time - gpumon_last_time) > 1.0) then
      gpumon_last_time = elapsed_time
      
      gh_gml.update()
      
      local gpu, mem = gh_gml.get_usages(0)
      local gpu_usage = gpu
      osi_info.gpu_load_last = gpu_usage
      if (osi_info.gpu_load_max < gpu_usage) then
        osi_info.gpu_load_max = gpu_usage
      end
      if (osi_info.gpu_load_min > gpu_usage) then
        osi_info.gpu_load_min = gpu_usage
      end
      
      osi_info.gpu_load_counter = osi_info.gpu_load_counter + 1
      osi_info.gpu_load_sum = osi_info.gpu_load_sum + gpu
      osi_info.gpu_load_avg = osi_info.gpu_load_sum  / osi_info.gpu_load_counter
      
      osi_info.gpu_temp = gh_gml.get_temperatures(0)
      
      osi_info.vram_usage = GetGpuMemoryUsage()
      
    end
      
      text = string.format("GPU load: %.2f %.2f %.2f %.2f", osi_info.gpu_load_avg, osi_info.gpu_load_min, osi_info.gpu_load_max, osi_info.gpu_load_last)
      text_width = gh_font.get_text_width(f, text)
      gh_font.text_2d(f, winW - text_width - 20, y_offset, 0, 1, 0, 1, text)
      y_offset = y_offset + 20

      text = string.format("GPU temp: %.2f degC", osi_info.gpu_temp)
      text_width = gh_font.get_text_width(f, text)
      gh_font.text_2d(f, winW - text_width - 20, y_offset, 1, 0.5, 0, 1, text)
      y_offset = y_offset + 20
  end


  text = string.format("Time: %.3f sec", osi_info.elapsed_time)
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, winW - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  text = osi_info.renderer_name
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, winW - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  text = string.format("VRAM: %.0f MB (usage: %.0f MB)", osi_info.vram_total/1024, osi_info.vram_usage/1024)
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, winW - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  text = osi_info.api_version
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, winW - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20
   
  --text = osi_info.vsync_status
  --text_width = gh_font.get_text_width(f, text)
  --gh_font.text_2d(f, winW - text_width - 20, y_offset, 1, 1, 1, 1, text)
  --y_offset = y_offset + 20

  text = string.format("Res: %.0fx%.0f", winW, winH)
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, winW - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20
  



  gh_font.update(f, 0)
  gh_texture.bind(kx_tex_font_p, 0)
  gh_font.render(f)
  

  
  --gh_renderer.set_blending_factors(BLEND_FACTOR_DST_COLOR, BLEND_FACTOR_ZERO)
  gh_gpu_program.bind(kx_texture_prog)
  gh_gpu_program.uniform1i(kx_texture_prog, "tex0", 0)
  gh_texture.bind(kx_tex_3dapi_logo, 0)
  gh_object.set_position(kx_logo_quad, winW/2-160, -winH/2+70, 0)
  gh_object.render(kx_logo_quad)
  
  
  

  gh_renderer.blending_off()



  
end








