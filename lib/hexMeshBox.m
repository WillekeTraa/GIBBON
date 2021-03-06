function [meshStruct]=hexMeshBox(boxDim,boxEl)

% function [meshStruct]=hexMeshBox(boxDim,boxEl)
% ------------------------------------------------------------------------
%
%
% Kevin Mattheus Moerman
% gibbon.toolbox@gmail.com
% 
% 2014/09/25
%------------------------------------------------------------------------

dX=boxDim(1); 
dY=boxDim(2);
dZ=boxDim(3);
nX=boxEl(1); 
nY=boxEl(2);
nZ=boxEl(3);

%Creating 2D slice
[X2,Y2]=meshgrid(linspace(-dX/2,dX/2,nX+1),linspace(-dY/2,dY/2,nY+1)); %mesh of single slice
[F2,V2,~] = surf2patch(X2,Y2,zeros(size(X2)),zeros(size(X2))); %Convert to patch data (quadrilateral faces)

%Offsetting to create 3D model
z_range=linspace(-dZ/2,dZ/2,nZ+1); %Offset steps
V=repmat(V2,numel(z_range),1); %replicating coordinates
Z_add=ones(size(V2,1),1)*z_range;
Z_add=Z_add(:);
V(:,3)=V(:,3)+Z_add; %Altering z coordinates

%Creating element definitions
q=(((1:(nZ))-1).*size(V2,1));
Q=q(ones(size(F2,1),1),:);
Qc=Q(:);
QQc=Qc(:,ones(1,size(F2,2)));

q=((1:(nZ)).*size(V2,1));
Q=q(ones(size(F2,1),1),:);
Qc=Q(:);
QQc2=Qc(:,ones(1,size(F2,2)));

E=[repmat(F2,[nZ 1])+(QQc) repmat(F2,[nZ 1])+(QQc2); ];

%Convert elements to faces
[F,~]=hex2patch(E,[]);

%Find boundary faces
[indFree]=freeBoundaryPatch(F);
Fb=F(indFree,:);

%Create faceBoundaryMarkers based on normals
[N]=patchNormal(Fb,V); %N.B. Change of convention changes meaning of front, top etc.

faceBoundaryMarker=zeros(size(Fb,1),1);

faceBoundaryMarker(N(:,1)<-0.5)=1; %Left
faceBoundaryMarker(N(:,1)>0.5)=2; %Right
faceBoundaryMarker(N(:,2)<-0.5)=3; %Front
faceBoundaryMarker(N(:,2)>0.5)=4; %Back
faceBoundaryMarker(N(:,3)<-0.5)=5; %Bottom
faceBoundaryMarker(N(:,3)>0.5)=6; %Top

%Collect output
meshStruct.E=E; 
meshStruct.V=V; 
meshStruct.F=F;
meshStruct.indFree=indFree;
meshStruct.Fb=Fb;
meshStruct.faceBoundaryMarker=faceBoundaryMarker;


