

------------------------------------------------------------------------------
--
kx_framework_elapsed_time = 0
kx_framework_camera = 0
kx_framework_camera_ortho = 0

kx_framework_cmdbuffer = 0
kx_framework_ub = 0


------------------------------------------------------------------------------
--
function VK_Framework_Init_Begin(framework_dir)

  dofile(framework_dir .. "common_defines.lua")
  dofile(framework_dir .. "common_func.lua")
  dofile(framework_dir .. "common_func_vk.lua")


  osi_info = {demo_caption="GeeXLab - Vulkan demo",
                   renderer_name="", 
                   api_version="", 
                   vram_total=0, 
                   vram_usage=0, 
                   frames=0, 
                   fps=0, 
                   dt_ms=0, 
                   elapsed_time=0, 
                   gpu_load_avg=0, 
                   gpu_load_min=100, 
                   gpu_load_max=0, 
                   gpu_load_last=0, 
                   gpu_load_counter=0, 
                   gpu_load_sum=0, 
                   gpu_temp=0
                 }


  kx_framework_cmdbuffer = CommandBuffer_Create_VK()
  CommandBuffer_Open_VK(kx_framework_cmdbuffer)

  Init()

  kx_framework_ub = UniformBuffer_Create_VK(512)

  OSI_Init_VK(framework_dir, osi_info, kx_framework_ub)
  
  
  kx_framework_camera = kx_camera
  kx_framework_camera_ortho = kx_camera_ortho 
  
end


------------------------------------------------------------------------------
--
function VK_Framework_Init_End()

  CommandBuffer_Exe_VK(kx_framework_cmdbuffer, 1)

  UniformBuffer_Update_Font_VK(kx_framework_ub)

end



------------------------------------------------------------------------------
--
function VK_Framework_Set_Main_Title(title)
  osi_info.demo_caption = title
end  




------------------------------------------------------------------------------
--
function VK_Framework_Frame_Begin(r, g, b)

  local elapsed_time = gh_utils.get_elapsed_time()
  kx_framework_elapsed_time = elapsed_time
 
  Update(osi_info, elapsed_time)

  Frame_Begin_VK(kx_framework_cmdbuffer, r, g, b)
end





------------------------------------------------------------------------------
--
function VK_Framework_Frame_End(display_osi)

  if (display_osi == 1) then
    OSI_Display_VK(osi_info, kx_framework_elapsed_time)
  end
  Frame_End_VK(kx_framework_cmdbuffer)

end



------------------------------------------------------------------------------
--
function VK_Framework_GetTime()
  return kx_framework_elapsed_time
end  

------------------------------------------------------------------------------
--
function VK_Framework_Get_CommandBuffer()
  return kx_framework_cmdbuffer
end  

------------------------------------------------------------------------------
--
function VK_Framework_Get_Camera()
  return kx_framework_camera
end  

------------------------------------------------------------------------------
--
function VK_Framework_Get_OrthoCamera()
  return kx_framework_camera_ortho
end  




------------------------------------------------------------------------------
--
function VK_Framework_Resize()
  
  Resize()
  UniformBuffer_Update_Font_VK(kx_framework_ub)

  end


------------------------------------------------------------------------------
--
function VK_Framework_Terminate()

  UniformBuffer_Cleanup_VK(kx_framework_ub)

end

