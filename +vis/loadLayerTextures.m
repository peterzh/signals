function gltex = loadLayerTextures(layers)
%VIS.LOADLAYERTEXTURES Summary of this function goes here
%   Detailed explanation goes here

global GL;

gltex = glGenTextures(numel(layers)); % make the OGL texture names
for ii = 1:numel(layers)
%   rgba = uint8(round(255*layers(ii).rgba));
%   rgba = permute(rgba(end:-1:1,:,:), [3 2 1]);
  
  w = layers(ii).rgbaSize(1);
  h = layers(ii).rgbaSize(2);
  glBindTexture(GL.TEXTURE_2D, gltex(ii)); % bind our texture name
  glTexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, w, h, 0,...
    GL.RGBA, GL.UNSIGNED_BYTE, layers(ii).rgba);
  switch layers(ii).interpolation
    case 'linear'
      glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
      glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
    case 'nearest'
      glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
      glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
    otherwise
      error('Invalid interpolation method ''%s''', layers(ii).interpolation);
  end
  
  if layers(ii).isPeriodic
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
  else
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_BORDER);
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_BORDER);
    glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_BORDER_COLOR, single([0 0 0 0]));
  end
end

end

