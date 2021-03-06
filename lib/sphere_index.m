function [I J K]=sphere_index(r,Ic,Jc,Kc)

% function [I J K]=sphere_index(r)
% ------------------------------------------------------------------------
% This function generates the indices 'I',  'J' and 'K' of voxel centers
% found within a sphere of radius 'r' (in voxels). The indices are not
% 'real' indices but are 'centered around zero'. They can be used to
% generate the indices of voxels found inside a sphere around point 'n' by
% adding In,Jn,Kn to I,J and K.
%
%
% Kevin Mattheus Moerman
% kevinmoerman@hotmail.com
% 07/08/2008
% ------------------------------------------------------------------------

if nargin == 1
    Ic=0; Jc=0; Kc=0;
end

%Set-up mesh calculate radius
[X,Y,Z] = meshgrid((-round(r+1)):1:(round(r+1)));
X=X+Jc; Y=Y+Ic; Z=Z+Kc;
radius = hypot(hypot(X,Y),Z);
[I,J,K]=ind2sub(size(X),find(radius<=r)); 
IJK_middle=round(size(X)/2);
I=I-IJK_middle(1);
J=J-IJK_middle(2);
K=K-IJK_middle(3);