function [Vs]=triSurfSmoothFourier(F,V,numFreq)

%Based on: 
% https://www.ceremade.dauphine.fr/~peyre/numerical-tour/tours/meshproc_4_fourier/


%%
numPoints = size(V,1); %Number of points

% The combinatorial laplacian is a linear operator (thus a NxN matrix where N is the number of vertices). It depends only on the connectivity of the mesh, thus on face only.
% Compute edge list.
E = [F(:,[1 2]); F(:,[2 3]); F(:,[3 1])]; %Edges array
numEdges = size(E,1); %Number of edges

% Compute the adjacency matrix.
W = sparse(E(:,1),E(:,2),ones(numEdges,1),numPoints,numPoints,numEdges);
W = max(W,W');

% Compute the combinatorial Laplacian, stored as a sparse matrix.
D = spdiags(sum(W,1)',0,numPoints,numPoints);
L = D-W;

opts.disp = 0;
[U,S] = eigs(L,numFreq,'SM',opts);
S = diag(S);

% Order the eigenvector by increasing frequencies.
[~,indSort] = sort(S,'ascend');
U = real(U(:,indSort));

% Linear Approximation over the Fourier Domain is obtained by keeping only
% the low frequency coefficient. This corresponds to a low pass filtering,
% since high frequency coefficients are removed.

% Compute the projection of each coordinate vertex(i,:) on the small set of nb frequencies.
vertexSpectrum = V'*U;

% Reconstruct the mesh.
Vs = (vertexSpectrum*U')';

end