{
  LIBGL_DRIVERS_PATH = [
    "/usr/lib/x86_64-linux-gnu/dri"
  ];
  
  libdirs = [
    "/usr/lib/x86_64-linux-gnu"
  ];
  
  libs = [
    "libGLX_mesa.so.0"
    "libdrm_intel.so.1"
    "libdrm_nouveau.so.2"
    "libdrm_radeon.so.1"
    
    "libGLX_nvidia.so.0"
  ];
}
