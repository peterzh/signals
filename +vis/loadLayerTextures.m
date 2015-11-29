function gltex = loadLayerTextures(win, layers)
%VIS.LOADLAYERTEXTURES Summary of this function goes here
%   Detailed explanation goes here

global GL;

Screen('BeginOpenGL', win);
try
  gltex = glGenTextures(numel(layers));
  for ii = 1:numel(layers)
    
%     rgb = layers(ii).colour;
%     alpha = layers(ii).alpha;
%     
%     h = max(size(rgb, 1), size(alpha, 1));
%     w = max(size(rgb, 2), size(alpha, 2));
%     
%     if ~isscalar(rgb) && size(rgb, 3) == 1
%       rgb = repmat(rgb, [1 1 3]);
%     end
% 
%     
%     rgba = zeros(h, w, 4);    
%     
%     rgba(:,:,1:3) = rgb;
%     rgba(:,:,4) = alpha;
    w = layers(ii).rgbaSize(1);
    h = layers(ii).rgbaSize(2);
    rgba = uint8(round(255*layers(ii).rgba));
    rgba = permute(rgba(end:-1:1,:,:), [3 2 1]);
    
%     gltex(ii) = glGenTextures(1); % make the OGL texture name
    glBindTexture(GL.TEXTURE_2D, gltex(ii)); % activate
    glTexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, w, h, 0,...
      GL.RGBA, GL.UNSIGNED_BYTE, rgba(:));
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
catch glEx
  Screen('EndOpenGL', win);
  rethrow(glEx);
end
Screen('EndOpenGL', win);

end

