



function CommandBuffer_Create_VK()
  local cmd = gh_renderer.command_list_create(0)
  return cmd
end  

function CommandBuffer_Open_VK(cmd)
  gh_renderer.command_list_open(cmd)
end  

function CommandBuffer_Exe_VK(cmd, waitgpu)
  gh_renderer.command_list_close(cmd)
  gh_renderer.command_list_execute(cmd)
  if (waitgpu == 1) then
    gh_renderer.wait_for_gpu()
  end
end  



function Frame_Begin_VK(cmd, r, g, b)

  gh_renderer.command_list_open(cmd)

  gh_renderer.clear_color_depth_buffers(r, g, b, 1.0, 1.0)
  gh_renderer.vk_command_list_render_pass_begin(cmd, 0)
  
  gh_renderer.set_viewport_scissor(0, 0, winW, winH)
end  


function Frame_End_VK(cmd)
  gh_renderer.vk_command_list_render_pass_end(cmd)
  gh_renderer.vk_command_list_pipeline_barrier(cmd)

  gh_renderer.command_list_close(cmd)
  gh_renderer.command_list_execute(cmd)
end  




function VK_UpdateCameraTransform(cam, ub)
  local vec4_size = 16
  local buffer_offset_bytes = vec4_size
  gh_gpu_buffer.set_matrix4x4(ub, buffer_offset_bytes, cam, "camera_view_projection")
end

function VK_UpdateObjectTransform(obj, ub, block_index)
  local vec4_size = 16 -- viewport
  local mat4x4_size = 64 -- camera
  local block_size = mat4x4_size 
  local buffer_offset_bytes = vec4_size + mat4x4_size + (block_size * block_index)
  gh_gpu_buffer.set_matrix4x4(ub, buffer_offset_bytes, obj, "object_global_transform")
end

function VK_UpdateViewportTransform(vp, ub)
  local buffer_offset_bytes = 0
  gh_gpu_buffer.set_value_4f(ub, buffer_offset_bytes, vp.x, vp.y, vp.w, vp.h)
end

function UniformBuffer_Create_VK(ub_size)
  --local vec4_size = 4*4 -- one vec4
  --local mat4x4_size = 16*4 -- one matrix
  --block_size = mat4x4_size * 2 -- two matrices
  --local num_font_objects = 1
  --local ub_size = vec4_size + (block_size * num_font_objects)
  local ub = gh_gpu_buffer.create("UNIFORM", "NONE", ub_size, "")
  gh_gpu_buffer.bind(ub)
  gh_gpu_buffer.map(ub)
  return ub
end  


function UniformBuffer_Cleanup_VK(ub)

  gh_gpu_buffer.unmap(ub)

end



function UniformBuffer_Update_Font_VK(ub)

  local viewport = {x=0, y=0, w=winW, h=winH}
  VK_UpdateViewportTransform(viewport, ub)
  VK_UpdateCameraTransform(kx_camera_ortho, ub)
  --VK_UpdateObjectTransform(kx_font_h1, ub, 0)  
end











function OSI_Init_VK(framework_dir, osi_info, ub)

  ------------------------------------------------------------------------
  --
  kx_ub0 = ub
  
  
  ------------------------------------------------------------------------
  --
  local gpu_index = gh_renderer.get_current_gpu()
  osi_info.renderer_name = gh_renderer.vk_gpu_get_name(gpu_index)
  local major, minor, patch = gh_renderer.vk_gpu_get_api_version(gpu_index)
  osi_info.api_version = string.format("Vulkan %d.%d.%d", major, minor, patch)


  -----------------------------------------------------------------------
  --
  kx_font_h1 = gh_font.create(framework_dir .. "data/fonts/HACKED.ttf", 30, 512, 512)
  gh_font.build_texture(kx_font_h1)
  kx_tex_font_h1 = gh_font.get_texture(kx_font_h1)

  kx_font_p = gh_font.create(framework_dir .. "data/fonts/Hack-Regular.ttf", 20, 512, 512)
  gh_font.build_texture(kx_font_p)
  kx_tex_font_p = gh_font.get_texture(kx_font_p)

  -- Init static text.
  --
  --[[
  r, g, b = gh_utils.hex_color_to_rgb("#ffff00")
  gh_font.clear(font_p)
  gh_font.text_2d(font_p, 20, 60, r, g, b, 1.0, "GeeXLab + Vulkan API")
  gh_font.update(font_p, 0)
  --]]


  -----------------------------------------------------------------------
  --
  local vertex_shader = framework_dir .. "data/spirv/06-vs.spv"
  local pixel_shader = framework_dir .. "data/spirv/06-ps.spv"
  kx_font_prog = gh_gpu_program.vk_create_from_spirv_module_file("kx_font_prog",   vertex_shader, "main",     pixel_shader, "main",    "", "",    "", "",     "", "",    "", "") 


  -----------------------------------------------------------------------
  --
  kx_sampler = gh_renderer.texture_sampler_create("LINEAR", "CLAMP", 0.0, 0)

    



  -----------------------------------------------------------------------
  --

  kx_ds_font_p = gh_renderer.vk_descriptorset_create()
  local ub_binding_point_ = 0
  gh_renderer.vk_descriptorset_add_resource_gpu_buffer(kx_ds_font_p, ub, ub_binding_point_, VK_SHADER_STAGE_VERTEX)
  local tex_binding_point_ = 1
  gh_renderer.vk_descriptorset_add_resource_texture(kx_ds_font_p, kx_tex_font_p, kx_sampler, tex_binding_point_, VK_SHADER_STAGE_FRAGMENT)
  gh_renderer.vk_descriptorset_build(kx_ds_font_p)
  gh_renderer.vk_descriptorset_update(kx_ds_font_p)



  kx_ds_font_h1 = gh_renderer.vk_descriptorset_create()
  ub_binding_point_ = 0
  gh_renderer.vk_descriptorset_add_resource_gpu_buffer(kx_ds_font_h1, ub, ub_binding_point_, VK_SHADER_STAGE_VERTEX)
  tex_binding_point_= 1
  gh_renderer.vk_descriptorset_add_resource_texture(kx_ds_font_h1, kx_tex_font_h1, kx_sampler, tex_binding_point_, VK_SHADER_STAGE_FRAGMENT)
  gh_renderer.vk_descriptorset_build(kx_ds_font_h1)
  gh_renderer.vk_descriptorset_update(kx_ds_font_h1)



  -----------------------------------------------------------------------
  --

  kx_pso_font_p = gh_renderer.pipeline_state_create("pso_font_p", kx_font_prog, "")
  local pso = kx_pso_font_p
  gh_renderer.pipeline_state_set_attrib_4i(pso, "DEPTH_TEST", 0, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "FILL_MODE", POLYGON_MODE_SOLID, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "PRIMITIVE_TYPE", PRIMITIVE_TRIANGLE, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "CULL_MODE", POLYGON_FACE_NONE, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "CCW", 0, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "BLENDING", 1, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "BLENDING_FACTORS_COLOR", BLEND_FACTOR_ONE, BLEND_FACTOR_ONE, 0, 0)
  kx_pso_font_p_valid = gh_renderer.vk_pipeline_state_build(pso, kx_ds_font_p)


  kx_pso_font_h1 = gh_renderer.pipeline_state_create("pso_font_h1", kx_font_prog, "")
  pso = kx_pso_font_h1
  gh_renderer.pipeline_state_set_attrib_4i(pso, "DEPTH_TEST", 0, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "FILL_MODE", POLYGON_MODE_SOLID, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "PRIMITIVE_TYPE", PRIMITIVE_TRIANGLE, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "CULL_MODE", POLYGON_FACE_NONE, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "CCW", 0, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "BLENDING", 1, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "BLENDING_FACTORS_COLOR", BLEND_FACTOR_ONE, BLEND_FACTOR_ONE, 0, 0)
  kx_pso_font_h1_valid = gh_renderer.vk_pipeline_state_build(pso, kx_ds_font_h1)
  
  
  
  
  
  
  
  
  
  

  ---[[
  local pixel_format = PF_U8_RGBA
  kx_logo_tex = gh_texture.create_from_file_v5(framework_dir .. "data/textures/vk.png", pixel_format)
  kx_logo_quad = gh_mesh.create_quad(300, 80)

  
  vertex_shader = framework_dir .. "data/spirv/03-vs.spv"
  pixel_shader = framework_dir .. "data/spirv/03-ps.spv"
  kx_texture_prog = gh_gpu_program.vk_create_from_spirv_module_file("kx_texture_prog",   vertex_shader, "main",     pixel_shader, "main",    "", "",    "", "",     "", "",    "", "") 

  

  kx_ds_tex = gh_renderer.vk_descriptorset_create()
  ub_binding_point_ = 0
  gh_renderer.vk_descriptorset_add_resource_gpu_buffer(kx_ds_tex, ub, ub_binding_point_, VK_SHADER_STAGE_VERTEX)
  tex_binding_point_ = 1
  gh_renderer.vk_descriptorset_add_resource_texture(kx_ds_tex, kx_logo_tex, kx_sampler, tex_binding_point_, VK_SHADER_STAGE_FRAGMENT)
  gh_renderer.vk_descriptorset_build(kx_ds_tex)
  gh_renderer.vk_descriptorset_update(kx_ds_tex)

  kx_pso_tex = gh_renderer.pipeline_state_create("kx_pso_tex", kx_texture_prog, "")
  pso = kx_pso_tex
  gh_renderer.pipeline_state_set_attrib_4i(pso, "DEPTH_TEST", 0, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "FILL_MODE", POLYGON_MODE_SOLID, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "PRIMITIVE_TYPE", PRIMITIVE_TRIANGLE, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "CULL_MODE", POLYGON_FACE_NONE, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "CCW", 0, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "BLENDING", 1, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "BLENDING_FACTORS_COLOR", BLEND_FACTOR_ONE, BLEND_FACTOR_ONE, 0, 0)
  kx_pso_tex_valid = gh_renderer.vk_pipeline_state_build(pso, kx_ds_tex)
  --]]
  
  

  
  
  

end







function OSI_Display_VK(osi_info, elapsed_time)
		
  local y_offset = 20
  local x_offset = 10
  
  
  VK_UpdateObjectTransform(kx_font_h1, kx_ub0, 0)  
  

  if (kx_pso_font_h1_valid == 1) then
    --print("OSI_Display - pso_font_h1_valid")
    gh_renderer.vk_descriptorset_bind(kx_ds_font_h1)
    gh_renderer.pipeline_state_bind(kx_pso_font_h1)
    --gh_renderer.vk_descriptorset_update_resource_texture(ds, tex_res_index, tex_font_h1, sampler, tex_binding_point, VK_SHADER_STAGE_FRAGMENT)
    --gh_renderer.vk_descriptorset_update(ds)
    local f = kx_font_h1
    gh_font.clear(f)
    gh_font.text_2d(f, 10, winH-10, 1, 0.8, 0, 1, osi_info.demo_caption)
    gh_font.update(f, 0)
    gh_font.render(f)
  end

    
  if (kx_pso_font_p_valid == 1) then
    gh_renderer.vk_descriptorset_bind(kx_ds_font_p)
    gh_renderer.pipeline_state_bind(kx_pso_font_p)
    --gh_renderer.vk_descriptorset_update_resource_texture(ds, tex_res_index, tex_font_p, sampler, tex_binding_point, VK_SHADER_STAGE_FRAGMENT)
    --gh_renderer.vk_descriptorset_update(ds)
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
    
    
    text = string.format("Res: %.0fx%.0f", winW, winH)
    text_width = gh_font.get_text_width(f, text)
    gh_font.text_2d(f, winW - text_width - 20, y_offset, 1, 1, 1, 1, text)
    y_offset = y_offset + 20
    
    
    
    gh_font.update(f, 0)
    gh_font.render(f)
  end
  

  ---[[
  if (kx_pso_tex_valid == 1) then
    gh_renderer.vk_descriptorset_bind(kx_ds_tex)
    gh_renderer.pipeline_state_bind(kx_pso_tex)
    gh_object.set_position(kx_logo_quad, winW/2-160, -winH/2+50, 0)
    VK_UpdateObjectTransform(kx_logo_quad, kx_ub0, 1)  
    gh_object.render(kx_logo_quad)
  end
  --]]
  
  
end
