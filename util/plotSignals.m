function plotSignals(figHand, signalRegistry)

% get the current time and current values immediately
thisTime = GetSecs();
sigNames = fieldnames(signalRegistry);
sigNames(strcmp('expStart',sigNames)) = []; %hide 'expStart' signal from LivePlot
sigNames(strcmp('expStop',sigNames)) = []; %hide 'expStop' signal from LivePlot

nSig = length(sigNames);
sigLogs = logs(signalRegistry,get(figHand, 'UserData')); % the figure user data was the initialization time, so logs will be zeroed to that

% now set display parameters
dispWindowTime = 10; %seconds

% get the existing axis and lines
spAx = get(figHand, 'Children');
if isempty(spAx)
    % store initialization time for later
    set(figHand, 'UserData', GetSecs());
    spAx = zeros(1,nSig);
    for nn = 1:nSig
        spAx(nn) = subplot(nSig,1,nn);
    end
elseif length(spAx)~= nSig
    fprintf(1, 'too many subplots\n')
    return
end


% for each signal, update the lines showing its value with the new current
% value
bslTime = get(figHand, 'UserData');
thisTime = thisTime-bslTime;

try
    for nn = 1:nSig
        
        t = sigLogs.([sigNames{nn} 'Times']);
        v = sigLogs.([sigNames{nn} 'Values']);
        inclT = t>(thisTime-dispWindowTime);
        
        if ~isempty(t) && ~any(inclT)
            inclT(end) = true; % include the last point in the plotting if the previous last one is off the graph now
        end
        
        if ~isempty(v)
            
            t = t(inclT);
            v = v(inclT);
            
            if ~isempty(v)
                t(end+1) = thisTime+1; % add one more point off the right edge of the plot so the current value extends
                v(end+1) = v(end);
                hold(spAx(nn), 'on');
                
                plot(spAx(nn), t(1:end-1), v(1:end-1), '-ro');
                hold(spAx(nn), 'on');
                % AP 170310: commented this out: don't see the point
                %stairs(spAx(nn), t, v, 'Color', 'blue');
                
                
                vRange = max(v)-min(v);
                if vRange>0
                    ylim(spAx(nn), [min(v)-0.1*vRange max(v)+0.1*vRange]);
                end
                
                xlim(spAx(nn), [thisTime-dispWindowTime thisTime]);
                ylabel(spAx(nn),sigNames{nn});
            end
        end
    end
catch ex
    warning(ex.getReport());
end
end
