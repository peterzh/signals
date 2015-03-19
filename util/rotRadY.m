function R = rotRadY(rad)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

R = [
  cos(rad) 0 sin(rad) 0
  0 1 0 0
  -sin(rad) 0 cos(rad) 0
  0 0 0 1
  ];

end

