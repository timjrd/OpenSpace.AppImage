{ gcc8Stdenv, makeWrapper, fetchFromGitHub, cmake, pkg-config
, boost, glib, pcre, libpng, bzip2, minizip, curl, gdal
, glew, vulkan-loader, freeimage, libdevil, harfbuzz
, libX11, libXxf86vm, libXext, libXi, libXcursor, libXrandr, libXinerama
, nodejs-8_x }:

gcc8Stdenv.mkDerivation rec {
  name = "openspace-${version}";
  version = "0.14.0";
  
  raw = gcc8Stdenv.mkDerivation {
    name = "openspace-raw-${version}";
    
    src = fetchFromGitHub {
      owner  = "OpenSpace";
      repo   = "OpenSpace";
      rev    = "cdeaae5068444f09129c703c40c9733a7d47e7d1";
      sha256 = "1l8fc221kqgywrsd27pzzvhxszzx7jk6hvm07jm0y4qv3n76ydhn";
      fetchSubmodules = true;
    };
    
    buildInputs = [
      cmake pkg-config
      boost glib pcre libpng bzip2 minizip curl gdal
      glew vulkan-loader freeimage libdevil harfbuzz
      libX11 libXxf86vm libXext libXi libXcursor libXrandr libXinerama
    ];
    
    patches = [ ./glext.patch ];
    
    preConfigure = ''
      mkdir modules/webgui/ext
      ln -s ${nodejs-8_x} modules/webgui/ext/nodejs
    '';
    
    cmakeFlags = [ "-DOpenGL_GL_PREFERENCE=GLVND" ];
    
    installPhase = ''
      mkdir -p $out/lib
      mv ext/spice/libSpice.so       $out/lib
      mv ext/ghoul/ext/lua/libLua.so $out/lib
      mv ../openspace.cfg $out
      mv ../bin     $out
      mv ../config  $out
      mv ../data    $out
      mv ../modules $out
      mv ../scripts $out
      mv ../shaders $out
    '';
    
    inherit meta;
  };
  
  buildInputs = [ makeWrapper ];
  
  phases = [ "installPhase" ];
  
  installPhase = ''
    icons=$out/share/icons/hicolor/128x128/apps
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $icons
    
    ln -s ${raw}/data/openspace-icon.png $icons/openspace.png
    cp ${./openspace.desktop} $out/share/applications/openspace.desktop
    ln -s ${raw} $out/share/openspace
    
    bin=${raw}/bin/OpenSpace
    makeWrapper $bin $out/bin/$(basename $bin) --run "${setup}"
  '';
  setup = ''
    function update {
      [[ ( ! -e \$2 ) || ( -L \$2 ) ]] && ln -snf \$1 \$2
    }
    base=\$HOME/.openspace
    mkdir -p \$base
    
    update ${raw}/config  \$base/config
    update ${raw}/data    \$base/data
    update ${raw}/modules \$base/modules
    update ${raw}/scripts \$base/scripts
    update ${raw}/shaders \$base/shaders
    
    [[ ! -e \$base/openspace.cfg ]] && echo 'dofile(\"${raw}/openspace.cfg\")' > \$base/openspace.cfg
    
    extraFlagsArray=(--file \$base/openspace.cfg)
  '';
  
  meta = with gcc8Stdenv.lib; {
    description = "Open source astrovisualization project";
    longDescription = ''
      OpenSpace is open source interactive data visualization software
      designed to visualize the entire known universe and portray our
      ongoing efforts to investigate the cosmos.
    '';
    homepage  = https://www.openspaceproject.com/;
    license   = licenses.mit;
    platforms = platforms.linux;
  };  
}
