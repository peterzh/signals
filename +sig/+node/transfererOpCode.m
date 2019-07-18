function code = transfererOpCode(transFun, transArg)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

code = 0; % default op code: means just use matlab transfer function

switch transFun
%   case 'sig.transfer.identity'
%     code = 50;
  case {'sig.transfer.mapn' 'sig.transfer.map'}
    if isa(transArg, 'function_handle')
      switch func2str(transArg)
        case 'plus'
          code = 1; % +
        case 'minus'
          code = 2; % -
        case 'times'
          code = 3; % .*
        case 'mtimes'
          code = 4; % *
        case 'rdivide'
          code = 5; % ./
        case 'mrdivide'
          code = 6; % /
        case 'gt'
          code = 10; % >
        case 'ge'
          code = 11; % >=
        case 'lt'
          code = 12; % <
        case 'le'
          code = 13; % <=
        case 'eq'
          code = 14; % ==
        case 'numel'
          code = 30;
      end
    end
  case 'sig.transfer.flattenStruct'
    code = 40;
end

end

