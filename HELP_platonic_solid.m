%% platonic_solid
% Below is a demonstration of the features of the |platonic_solid| function

%%
clear; close all; clc;

%%
% Plot settings
fig_color='w'; fig_colordef='white';
fontSize=15;
faceColor='b';
faceAlpha=0.75;
edgeColor='k';
edgeWidth=2;
markerSize=5;

%%

hf=figuremax(fig_color,fig_colordef); % Open figure for plotting
pColor=jet(5);
for q=1:1:5
    %Defining the faces (F) and vertices (V) of a platonic solid
    [V,F]=platonic_solid(q,1); %q indicates solid type, r is the radius
    
    subplot(2,3,q); hold on;
    xlabel('X','FontSize',fontSize); ylabel('Y','FontSize',fontSize); zlabel('Z','FontSize',fontSize);
    hp=patch('Faces',F,'Vertices',V);
    set(hp,'FaceColor',pColor(q,:),'FaceAlpha',faceAlpha,'lineWidth',edgeWidth,'edgeColor',edgeColor);
    
    %Plotting face normals
    [hn]=patchNormPlot(F,V,1);
    
    set(gca,'FontSize',fontSize);
    view(3); axis tight;  axis equal;  axis vis3d; axis off;
    camlight('headlight'); lighting flat;
end

%%
%
% <<gibbVerySmall.gif>>
%
% _*GIBBON*_
% <www.gibboncode.org>
%
% _Kevin Mattheus Moerman_, <gibbon.toolbox@gmail.com>