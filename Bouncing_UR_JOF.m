function BouncingUR
%%%%%%%%%%%%%%%%%%
% Johann Ortiz-Franco 
% CSC 160: Bouncing UR 
%
%%%%%%%%%%%%%%%%%%

close all;
xsideu = [0,0;0,0;1,1;1,1;.75,.75;.75,.75;.25,.25;.25,.25;0,0];
ysideu = [1,1;0,0;0,0;1,1;1,1;.25,.25;.25,.25;1,1;1,1];
za = [0,1;0,1;0,1;0,1;0,1;0,1;0,1;0,1;0,1];
xfu = [0,.25;0,.25;0,1;0,1;.75,1;.75,1];
yfu = [1,1;0,0;0,0;.25,.25;0,0;1,1];
zfu = [0,0;0,0;0,0;0,0;0,0;0,0];
xu = [xsideu;xfu;flipud(xfu)];
yu = [ysideu;yfu;flipud(yfu)];
zu = [za;zfu;zfu+1];
xbridge = [.25,.25;.25,.25;1.25,1.25;1.25,1.25;1.25,1.25];
ybridge = [1,1;1,1;0,0;0,0;1,1];
zbridge = [1,1;0,0;0,0;0,0;0,0];
xor = [0,0;0,0;.25,.25;.25,.25;.75,.75;1,1;.4,.4;1,1;1,1;0,0];
yor = [1,1;0,0;0,0;.5,.5;0,0;0,0;.5,.5;.5,.5;1,1;1,1];
zor = [0,1;0,1;0,1;0,1;0,1;0,1;0,1;0,1;0,1;0,1];
xfr = [0,.25;0,.25;.25,.25;.25,.4;.75,1;.25,.4;.25,.25;.25,.25;1,1;1,1;1,.755;1,.755;1,1;1,1;0,0];
yfr = [1,1;0,0;.5,.5;.5,.5;0,0;.5,.5;.6,.6;.5,.6;.5,.6;.6,.6;.6,.6;1,1;1,1;1,.755;1,.755];
zfr = [0,0;0,0;0,0;0,0;0,0;0,0;0,0;0,0;0,0;0,0;0,0;0,0;0,0;0,0;0,0];
xir = [0,.25;.25,.25;.25,.25;.755,.755;.755,.755;.25,.25];
yir = [.755,.755;.755,.755;.6,.6;.6,.6;.755,.755;.755,.755];
zir = [1,1;0,1;0,1;0,1;0,1;0,1];
xr = [xor;xfr;flipud(xfr);xir];
yr = [yor;yfr;flipud(yfr);yir];
zr = [zor;zfr;zfr+1;zir];
x = [xu; xbridge; xr + 1.25];
y = [yu; ybridge; yr];
z = [zu; zbridge; zr];
bottomZ = min(z(:));
radius = abs(bottomZ);

%Background plot 
axis vis3d
axis off
daspect([1.6, 1, 1.875]);
hold on;
markerColor = [0.5, 0.5, 0.5];
lineColor = [0.7, 0.7, 0.7];
figWidth = 800
figHeight = 600;
screenSize = get(0, 'ScreenSize');
X0 = (screenSize(3)-figWidth)/2;
Y0 = (screenSize(4)-figHeight)/2;
set(gcf, 'Position', [X0,Y0, figWidth, figHeight]);
camtarget([0, 0, 0]);
set(gcf,'Renderer','zbuffer');
set(gcf,'DoubleBuffer','on');
set(gcf, 'color', 'b');
startAZ = 30;
satrtEL = 20;
view(startAZ, satrtEL);

% draw points
for iLoop = 1:size(x, 1)
    plot3(x(iLoop, :), y(iLoop,:), z(iLoop, :), 'Marker', '.', 'MarkerEdgeColor', markerColor, 'LineStyle', 'none');
    pause(0.2);
end

% draw wire frames
for iLoop = 1:size(x, 1)
    plot3(x(iLoop, :), y(iLoop,:), z(iLoop, :), 'color', lineColor, 'LineStyle', '--');
    pause(0.2);   
end

for iLoop = 1:size(x, 2)
    plot3(x(:, iLoop), y(:, iLoop), z(:, iLoop), 'color', lineColor, 'LineStyle', '--');
    pause(0.2);  
end

% rotate wire frame
for i=1:36
	camorbit(10,0,'data');
	pause(0.1);   
end
% clean the curent axes
delete(get(gca, 'Children'));

camlight left;
newLineColor = [0.7, 0.4, 0.4];

% re-draw the whole UR with surf function
h = surf(x,y,z, 'EdgeColor', newLineColor, 'FaceColor', 'b');
for i=1:36
	camorbit(10,0,'data');
	pause(0.1);
end

mediumColor = [0.8, 0.3, 0.3];
set(h, 'EdgeColor', mediumColor,'FaceLighting','gouraud');
for i=1:36    
	camorbit(10,0,'data');
	drawnow;
end

set(h, 'EdgeColor', 'none');
drawnow;

% define the Z-path for UR re-shape
deltaZ = linspace(-.3, 0, 5);
deltaZ = [fliplr(deltaZ), deltaZ];
deltaZ = repmat(deltaZ, 1, 3);
zlim('manual');
for iLoop = 1:length(deltaZ)    
    % draw the UR
    curDeltaZ = deltaZ(mod(iLoop,length(deltaZ))+1);
    ratio = (radius+curDeltaZ)*radius;
    newZ = z*ratio + curDeltaZ;
    
    if exist('h', 'var')&& ishandle(h), delete(h);end;
    h = surf(x,y, newZ, 'EdgeColor', 'none', 'FaceColor', 'b','FaceLighting','gouraud');
    camorbit(-1, 0, 'data');
    drawnow;
end

% draw the bouncing UR
deltaZ = generateSimulatedBouncingPath;
zlim([-1, 3]);
for iLoop = 1:length(deltaZ)
    
    if exist('h', 'var')&& ishandle(h), delete(h);end;
    
    curDeltaZ = deltaZ(iLoop);
    if curDeltaZ < 0
        % when deltaZ is under the zero bar, it's hitting the ground
        ratio = (radius+curDeltaZ)*radius;
        newZ = z*ratio + curDeltaZ;
    else
        % when deltaZ is bigger than zero, it's a free object
        newZ = z + curDeltaZ;
    end  

    h = surf(x, y, newZ, 'EdgeColor', 'none', 'FaceColor', 'b','FaceLighting','gouraud');
    
    % zoom in and out for more vivid effect
    if iLoop <= length(deltaZ)/2
        camzoom(0.99);
    else
        camzoom(1.005);
    end
    
    camorbit(390/length(deltaZ), 0, 'data');
    drawnow;
end
