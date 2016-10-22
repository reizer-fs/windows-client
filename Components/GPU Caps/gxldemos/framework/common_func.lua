
kx_camera = 0
kx_camera_ortho = 0


function Camera_Init()

  local aspect = 1.333
  if (winH > 0) then
    aspect = winW / winH
  end  
  kx_camera = gh_camera.create_persp(60, aspect, 0.1, 1000.0)
  gh_camera.set_viewport(kx_camera, 0, 0, winW, winH)
  gh_camera.setpos(kx_camera, 0, 0, 20)
  gh_camera.setlookat(kx_camera, 0, 0, 0, 1)
  gh_camera.setupvec(kx_camera, 0, 1, 0, 0)

end


function Camera_Ortho_Init()

  kx_camera_ortho = gh_camera.create_ortho(-winW/2, winW/2, -winH/2, winH/2, 1.0, 10.0)
  gh_camera.set_viewport(kx_camera_ortho, 0, 0, winW, winH)
  gh_camera.set_position(kx_camera_ortho, 0, 0, 4)

end



function Init()

  winW, winH = gh_window.getsize(0)

  Camera_Init()
  Camera_Ortho_Init()
 
  
    
  g_last_time = gh_utils.get_elapsed_time()
  g_fps_time = 0
  g_fps_frames = 0
  g_fps = 0
  g_frame_time = 0

  kx_num_gpus = gh_gml.get_num_gpus()
  gpumon_interval = 1.0
  gpumon_last_time = 0
  
end


function Update(osi_info, elapsed_time)

  local dt = elapsed_time - g_last_time
  g_last_time = elapsed_time
  local dt_ms = dt * 1000
  g_frame_time = dt

  g_fps_time = g_fps_time + dt
  if (g_fps_time >= 1.0) then
    g_fps_time = 0
    g_fps = g_fps_frames
    g_fps_frames = 0
    osi_info.fps = g_fps
  end

  g_fps_frames = g_fps_frames + 1
  osi_info.frames = osi_info.frames + 1

  osi_info.elapsed_time = elapsed_time
  osi_info.dt_ms = dt_ms

end



function Resize()
  winW, winH = gh_window.getsize(0)

  local aspect = 1.333
  if (winH > 0) then
    aspect = winW / winH
  end  
  gh_camera.update_persp(kx_camera, 60, aspect, 0.1, 1000.0)
  gh_camera.set_viewport(kx_camera, 0, 0, winW, winH)


  gh_camera.update_ortho(kx_camera_ortho, -winW/2, winW/2, -winH/2, winH/2, 1.0, 10.0)
  gh_camera.set_viewport(kx_camera_ortho, 0, 0, winW, winH)

end