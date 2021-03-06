function [subIndMask,patchDataOut]=sparseSphericalMask(rSphere,nSubTri,optPatchOut)


%Creating icosahedron
[Vp,Fp]=platonic_solid(4,rSphere);

%Subtriangulating
if nSubTri>0
    for q=1:1:nSubTri
        [Fp,Vp]=subtri(Fp,Vp,1);
        [thetaP,phiP,radP] = cart2sph(Vp(:,1),Vp(:,2),Vp(:,3));
        [Vp(:,1),Vp(:,2),Vp(:,3)] = sph2cart(thetaP,phiP,rSphere*ones(size(radP)));
    end
end

subIndMask=unique(round(Vp),'rows');

if optPatchOut==1
    size_M=3*(rSphere)*ones(1,3);
    subIndmaskMiddle=round(size_M*0.5);
    subIndMask=subIndMask+ones(size(Vp,1),1)*(subIndmaskMiddle);
    indMask = unique(sub2ind(size_M, subIndMask(:,2), subIndMask(:,1), subIndMask(:,3)));
    [Fs,Vs,~]=ind2patch(indMask,zeros(size_M),'vu');
    Vs=Vs-ones(size(Vs,1),1)*(subIndmaskMiddle);
    
    patchDataOut.FV_cellTesselation={Fp,Vp};
    patchDataOut.FV_cellMask={Fs,Vs};
end


