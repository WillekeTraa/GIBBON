function [F,V,regionIndSub]=hemiSphereRegionMesh(hemiSphereStruct)

% function [F,V,regionIndSub]=hemiSphereRegionMesh(hemiSphereStruct)
% ------------------------------------------------------------------------
% This function generates an approximately geodesic triangulated mesh on a
% hemisphere whereby the mesh is grouped into triangular regions.
%
% The following inputs are required:
% hemiSphereStruct.sphereRadius -> The sphere radius
% hemiSphereStruct.nRefineRegions -> Number of refinement steps for regions
% hemiSphereStruct.nRefineMesh -> Number of refinement steps for mesh
%
% The mesh starts of as a cropped icosahedron with 12 triangular faces.
% Each refinement step introduces 4 new triangular faces per original
% triangular face.
%
% The outputs are:
% F -> the triangular faces
% V -> the vertex coordinates
% regionIndSub -> the region index numbers
%
% 
%
% %% EXAMPLE
% clear all; close all; clc;
% 
% %% PLOT SETTINGS
% fig_color='w'; fig_colordef='white';
% fontSize=25;
% faceAlpha=0.75;
% lineWidth=1;
% markerSize=5;
% 
% %% SETTINGS
% 
% %Sub-triangulation refinement introduces 4 triangles for each triangle per iteration  
% hemiSphereStruct.sphereRadius=1; %Sphere radius
% hemiSphereStruct.nRefineRegions=2; %Number of refinement steps for regions
% hemiSphereStruct.nRefineMesh=2; %Number of refinement steps for mesh
% 
% [F,V,regionIndSub]=hemiSphereRegionMesh(hemiSphereStruct);
% cmap=hsv(max(regionIndSub(:)));
% cmap=cmap(randperm(size(cmap,1)),:); %scramble colours
% 
% % Plotting results
% hf=figuremax(fig_color,fig_colordef);
% hold on; view(3); 
% title('Half dome showing regions with subtriangulated mesh','FontSize',fontSize);
% xlabel('X','FontSize',fontSize); ylabel('Y','FontSize',fontSize); zlabel('Z','FontSize',fontSize);
% 
% hp=patch('Faces',F,'Vertices',V);
% set(hp,'FaceColor','flat','EdgeColor','k','CData',regionIndSub,'FaceAlpha',faceAlpha,'LineWidth',lineWidth,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','none','MarkerSize',markerSize);
% 
% colormap(cmap); colorbar; 
% set(gca,'FontSize',fontSize);
% axis tight;  axis equal;  grid on;
% set(gca,'FontSize',fontSize);
%
%
% Kevin Mattheus Moerman
% kevinmoerman@hotmail.com
% 08/04/2013
%------------------------------------------------------------------------

%% SETTINGS

%Sub-triangulation refinement introduces 4 triangles for each triangle per iteration  
sphereRadius=hemiSphereStruct.sphereRadius; %Sphere radius
nRefineRegions=hemiSphereStruct.nRefineRegions; %Number of refinement steps for regions
nRefineMesh=hemiSphereStruct.nRefineMesh; %Number of refinement steps for mesh

% Could change these to input variables but for now hardcoded
cropLevel=0; %Crop level for sphere, N.B. not all levels/density combinations result in properly cropped meshes
lambdaSmooth=0.25; %
nSmoothIterations=5; %Number of smoothening iteration
smoothType=2; %2 means edges are fixed, 1 means the edges stay at the same z-level

%% GET GEODESIC TRIANGULATION OF THE SPHERE TO DEFINE REGIONS

[F,V,~]=geoSphere(nRefineRegions,sphereRadius); 

% %Get alternative initial solid e.g. octahedron
% [V,F]=platonic_solid(3,sphereRadius); 
% 
% % Sub-triangulate the icosahedron for geodesic sphere triangulation
% for q=1:nRefineRegions %iteratively refine triangulation and push back radii to be r
%     [F,V]=subtri(F,V,1); %Sub-triangulate
%     [T,P,R] = cart2sph(V(:,1),V(:,2),V(:,3)); %Convert to spherical coordinates
%     [V(:,1),V(:,2),V(:,3)] = sph2cart(T,P,nRefineRegions.*ones(size(R)));  %Push back radii
% end

%%

TR_sphere =triangulation(F,V); %Triangulation representation
IND_edges=edges(TR_sphere); %Edge indices
edgeLengths=sum((V(IND_edges(:,1),:)-V(IND_edges(:,2),:)).^2,2);
minEdgeLength=min(edgeLengths(:));

%% CREATE CROPPED DOME

%Find all valid faces
Z=V(:,3); %Z coordinates of region mesh

%Deriving "numerical precission offset". Some points may not exactly at the
%cropLevel due to numerical precission differences. Therefore an offset is
%used. It is currently hard coded to be 1/1000th of the smallest edge
%length.
numPrecOffset=minEdgeLength/1e3; %Numerical precission offset 
logicValidTriangle=(mean(Z(F),2)>=(cropLevel-numPrecOffset)); %Logic for faces at or above cropLevel
F=F(logicValidTriangle,:);%Getting valid faces
indUni=unique(F(:)); %Vertex indices for the valid faces

%Get valid vertices
logicVertUsed=false(size(V,1),1);
logicVertUsed(indUni)=1;
indV=cumsum(double(logicVertUsed));
indV(~logicVertUsed)=nan;
V=V(indUni,:);
F=indV(F);

%Snapping points boundary points
V(V(:,3)<cropLevel,3)=cropLevel;

%% FIXING EDGE TRIANGLES BASED ON SMOOTHENING

%Laplacian smoothening regions

Vi=V; %Store original coordinates
TR =triangulation(F,V);
edgeDome = freeBoundary(TR);
indEdges=unique(edgeDome(:));

for q=1:nSmoothIterations;
    
    [V]=trisurfsmooth(F,V,1,[],lambdaSmooth,1); %A single Laplacian smooth iteration
    
    %Push back radii
    [T,P,R] = cart2sph(V(:,1),V(:,2),V(:,3));
    [V(:,1),V(:,2),V(:,3)] = sph2cart(T,P,sphereRadius*ones(size(R)));
    
    %Push back edges
    switch smoothType
        case 1
            V(indEdges,3)=cropLevel; %Keep Z coordinate fixed only
        case 2
            V(indEdges,:)=Vi(indEdges,:); %Keep edge points fixed
    end
end

%Create mesh region indices
regionInd=(1:size(F,1))'; %Random region indices

%% Sub-triangulate regions to get mesh
%Each sub-triangulation refinement iteration sub-devides each triangle into
%4 triangles. 

if nRefineMesh>0
    for q=1:nRefineMesh
        [F,V]=subtri(F,V,1);
        % Push back radii
        [T,P,R] = cart2sph(V(:,1),V(:,2),V(:,3));
        [V(:,1),V(:,2),V(:,3)] = sph2cart(T,P,sphereRadius*ones(size(R)));        
    end
end

%Getting region numbers
regionIndSub=regionInd(:,ones(1,4^nRefineMesh));
regionIndSub=regionIndSub;
regionIndSub=regionIndSub(:);

%% Smoothening mesh

Vi=V;
TR = triangulation(F,V);
edgeDome = freeBoundary(TR);
indEdges=unique(edgeDome(:));

for q=1:nSmoothIterations;
    
    [V]=trisurfsmooth(F,V,1,[],lambdaSmooth,1); %A single Laplacian smooth iteration
    
    %Push back radii
    [T,P,R] = cart2sph(V(:,1),V(:,2),V(:,3));
    [V(:,1),V(:,2),V(:,3)] = sph2cart(T,P,sphereRadius*ones(size(R)));
    
    %Push back edges
    switch smoothType
        case 1
            V(indEdges,3)=cropLevel; %Keep Z coordinate fixed only
        case 2
            V(indEdges,:)=Vi(indEdges,:); %Keep edge points fixed
    end
end

end