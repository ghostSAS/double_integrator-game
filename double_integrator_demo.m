
% ====================================================================== %
% double-integrator control demo

% how to:

% use slider to provide input

% if you hit the boundary, you lose
% close the window and try running the script again

% uncomment line 27 to get a random target state (this is more challenging)

% try changing the rate (line 20) to make the control harder

% author: Yunshen Huang, kyle gray
% ese441, spring 2022
% ====================================================================== %
    
clear, clc, close all

% ------------------ intial config ------------------
playing = 1;

rate = 0.1; % this is how fast "time" progresses
epsilon = .02; % detemines how large area of the target


y0 = [1,0]; % initial condition
yt = [0,0]; % target state
%yt = -0.75 * lim + 1.5 * lim * rand(1,2); % random target state

% ------------------ plot vector filed -----------------------
scrsz = get(0,'ScreenSize');
fig = figure('Units', 'normalized', 'position',[.05, .1, .9, .8]);
ax1 = axes('Position',[0.07 0.2 0.5 0.65]);
lim = 2; % boundaries of the plot
drawVF(ax1, lim);

setappdata(fig, 'playing', playing);
setappdata(fig, 'lim', lim);
setappdata(fig, 'y0', y0);
setappdata(fig, 'yt', yt);

% ------------------ create control panel ------------------
panel = uipanel(fig,'Position',[0.6 0.2 0.33 0.65]);
ppos = get(panel, 'position');

resetBtn = uicontrol(panel, 'style', 'pushbutton', 'Units', 'normalized',...
    'Position',[.425, .05, .15, .05], 'string','Restart',...
    'callback', @(resetBtn, event) resetBtnFun(resetBtn, fig),...
    'Enable','off', 'FontSize',12) ;
setappdata(fig, 'resetBtn',resetBtn)

InputSlider = uicontrol(panel, 'style','slider', 'Units', 'normalized',...
    'position',[0.9, 0.2, 0.02, 0.3], 'min',-1,'max',1);
setappdata(fig, 'InputSlider',InputSlider)

InSliderBox = uicontrol(panel, 'style', 'text', 'string', 'Input on Y axis',...
    'Units', 'normalized','Position',[.3, .52, .4, .05], 'FontSize',15);

statusBox = uicontrol(fig, 'style', 'text', 'string', 'Start',...
    'Units', 'normalized','Position',[.45, .9, .1, .04], 'FontSize',20);

TimerBox = uicontrol(panel, 'style', 'text', 'string', 'Time: ',...
    'Units', 'normalized','Position',[.4, .9, .2, .04], 'FontSize',15);

modelSelText = uicontrol(panel, 'style', 'text', 'string', 'Mode selection',...
    'Units', 'normalized','Position',[.1 .64, .15, .05], 'FontSize',12);

modeSelBox = uicontrol(panel, 'style', 'popupmenu',...
    'String', {'Easy', 'Normal', 'Hard', 'Hell'},...
    'Units', 'normalized','Position',[.1 .6, .23, .05],...
    'Value', 2, 'FontSize',12,...
    'callback', @(modeSelBox, event) modeSelFun(modeSelBox, fig),...
    'Enable','off') ;
setappdata(fig, 'modeSelBox', modeSelBox);
setappdata(fig,'rate',0.06)

randPtBtn = uicontrol(panel, 'style', 'pushbutton', 'Units', 'normalized',...
    'Position',[.5 .6, .42, .05], 'string','Randomize initial point and restart',...
    'callback', @(randPtBtn, event) randBtnFun(randPtBtn, fig),...
    'Enable','off', 'FontSize',10) ;
setappdata(fig,'randPtBtn',randPtBtn)

ax2 = axes(panel, 'Position',[0.1 0.2 0.72 0.30]);

dis_winSize = 500; 

% -------------- plot real time input ------------------

while 1
    while getappdata(fig,'playing')
        set(statusBox, 'string', 'Start');
        inputs = 0;
        count = 1;
        y0 = getappdata(fig, 'y0');
        
        % ------------------ start plotting ------------------
        p = plot(ax1, y0(1),y0(2),'o','MarkerFaceColor','red');
        t = plot(ax1, y0(1),y0(2),'k-');
        plot(ax1, yt(1),yt(2),'go','MarkerSize',8)
        inP = plot(ax2, inputs);
        drawnow

        rate = getappdata(fig, 'rate');

        outBound = 0;
        getTarget = 0;        

        while ~outBound && ~getTarget
            input = get(InputSlider,'value');
            inputs(count) = input;
            p.XData = p.XData + rate * p.YData;
            p.YData = p.YData + rate * input;
            t.XData = [t.XData p.XData];
            t.YData = [t.YData p.YData];
            
            if count <= dis_winSize
                inP.XData = 1:count;
                inP.YData = inputs;
                ax2.XLim = [1, dis_winSize];
            else
                inP.XData = count-dis_winSize: count-1;
                inP.YData = inputs(count-dis_winSize: count-1);
                ax2.XLim = [count-dis_winSize, count-1];
            end
            ax2.YLim = [-1 1];
            
            drawnow
            
            % Display something
            InSliderBox.String = sprintf('Input on Y axis, Energy: %.2f', norm(inputs)^2);
            TimerBox.String = sprintf('Time: %.1f', count/50);
            
            % determine if end the game
            outBound = abs(p.XData) >= lim || abs(p.YData) >= lim;
            
            getTarget = norm([p.XData, p.YData] - yt) <= epsilon;
            
            count = count + 1;

            if ~ishandle(fig)
                break
            elseif outBound 
                set(statusBox, 'string', 'You lose');
                set(modeSelBox,'Enable','on')
                break
            elseif getTarget
                set(statusBox, 'string', 'You Win');
                set(modeSelBox,'Enable','on')
                break
            else 
                continue
            end
            
        end
        
        setappdata(fig, 'playing', 0);
        set(InputSlider,'value', 0);
        set(InputSlider,'Enable', 'off')
        set(resetBtn,'Enable','on');
        set(randPtBtn,'Enable','on');
        break
    end
    pause(1)
    
end

% Create the function for the ButtonPushedFcn callback
function resetBtnFun(btn, fig)
    set(getappdata(fig, 'InputSlider'),'Enable', 'on')
    set(getappdata(fig, 'InputSlider'),'value', 0);
    pause(.2)
    
    drawPt(fig);
    
    
    set(btn,'Enable','off')
    set(getappdata(fig,'modeSelBox'), 'Enable', 'off')
    set(getappdata(fig,'randPtBtn') ,'Enable', 'off')

    pause(2)
    setappdata(fig, 'playing', 1);
    
end


function drawVF(ax1, lim)
    n = 20;
    [x1,x2] = meshgrid(linspace(-lim,lim,n));

    quiver(ax1, x1,x2, x2,zeros(n,n))
    hold on
    axis tight
end


function drawPt(fig)
    yt = getappdata(fig, 'yt');
    y0 = getappdata(fig, 'y0');
    
    ax = findall(fig, 'type', 'axes');
    cla(ax(1))
    cla(ax(2))
    drawVF(ax(1), 2)

    plot(ax(1), y0(1),y0(2),'o','MarkerFaceColor','red');
    plot(ax(1), yt(1),yt(2),'go','MarkerSize',8)
    set(getappdata(fig,'resetBtn') ,'Enable', 'off')
end


function modeSelFun(btn, fig)
    switch char(btn.String(btn.Value))
        case 'Easy'
            setappdata(fig,'rate',0.05)
        case 'Normal'
            setappdata(fig,'rate',0.08)
        case 'Hard'
            setappdata(fig,'rate',0.16)
        case 'Hell'
            setappdata(fig,'rate',0.30)
    end
end


function randBtnFun(btn, fig)
    
    set(getappdata(fig, 'InputSlider'),'Enable', 'on')
    set(getappdata(fig, 'InputSlider'),'value', 0);
    pause(.2)
    
    lim = getappdata(fig, 'lim');
    y0 = (rand(1,2)-.5)*lim;
    setappdata(fig, 'y0', y0);
    
    drawPt(fig)
  
    set(btn,'Enable','off')
    pause(2)
    setappdata(fig, 'playing', 1);
    
end



