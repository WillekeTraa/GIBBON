function [ortho_mask_IND,ortho_mask_I,ortho_mask_J,ortho_mask_K]=oblique_mask(V_ort_vec,IND_mask,mask_height,siz,v,opt)

[I_mask,J_mask,K_mask] = ind2sub(siz,IND_mask);

%Factor for number of points across mask
f=1+(2.*abs(sqrt((V_ort_vec(:,1)-V_ort_vec(:,2)).^2+(V_ort_vec(:,2)-V_ort_vec(:,3)).^2+(V_ort_vec(:,1)-V_ort_vec(:,3)).^2)-sqrt(2))./sqrt(2));
f=max(f(:));

%Defining orthogonal neighbourhoods
if size(V_ort_vec,1)~=numel(IND_mask)
    V_ort_vec=ones(numel(IND_mask),1)*V_ort_vec;    
end
V_ort_vec=V_ort_vec.*mask_height; %Lengthen orthogonal vector by mask_height
V_ort_vec_X=V_ort_vec(:,1); V_ort_vec_Y=V_ort_vec(:,2); V_ort_vec_Z=V_ort_vec(:,3);

%Creating mask points in cartesian coordinates
n_ort=ceil(f.*((2.*mask_height)./min(v))); %Number of points from -vector to +vector
n_ort=n_ort+iseven(n_ort); %Ensure its uneven so middle element will be self
ortho_mask_X=linspacen(-V_ort_vec_X,V_ort_vec_X,n_ort);
ortho_mask_Y=linspacen(-V_ort_vec_Y,V_ort_vec_Y,n_ort);
ortho_mask_Z=linspacen(-V_ort_vec_Z,V_ort_vec_Z,n_ort);

%Creating mask points in image coordinates
ortho_mask_I=round(ortho_mask_Y./v(1))+I_mask*ones(1,size(ortho_mask_Y,2));
ortho_mask_J=round(ortho_mask_X./v(2))+J_mask*ones(1,size(ortho_mask_Y,2));
ortho_mask_K=round(ortho_mask_Z./v(3))+K_mask*ones(1,size(ortho_mask_Y,2));

%Removing out of bound indices
L_not_valid= (ortho_mask_I<1 | ortho_mask_I>siz(1)) | ...
             (ortho_mask_J<1 | ortho_mask_J>siz(2)) |...
             (ortho_mask_K<1 | ortho_mask_K>siz(3));
ortho_mask_IND=NaN(size(L_not_valid));
ortho_mask_ind = sub2ind(siz,ortho_mask_I(~L_not_valid),ortho_mask_J(~L_not_valid),ortho_mask_K(~L_not_valid));
ortho_mask_IND(~L_not_valid)=ortho_mask_ind;

%Removing doubles
[ortho_mask_IND_sort,J_sort] = sort(ortho_mask_IND,2); %Sorting to prepare for diff
[j_sort,J_sort_inv] = sort(J_sort,2); clear j_sort; %Determine inverse of sorting
I_sort=(1:size(ortho_mask_IND,1))'*ones(1,size(ortho_mask_IND,2));
IND_sort_inv=sub2ind(size(ortho_mask_IND),I_sort,J_sort_inv); %Inverse indices
L_double=[ones(size(ortho_mask_IND_sort,1),1) diff(ortho_mask_IND_sort,1,2)]==0; %Find doubles
ortho_mask_IND_sort(L_double)=NaN; %Set doubles to NaN
ortho_mask_IND=ortho_mask_IND_sort(IND_sort_inv); %Fixing order

%Ensuring only centre element is self
L_self=(ortho_mask_IND-(IND_mask*ones(1,size(ortho_mask_IND,2))))==0;
ortho_mask_IND(L_self)=NaN;
ortho_mask_IND(:,round(size(ortho_mask_IND,2)./2))=IND_mask;

if opt==1
    %Removing non-mask elements
    L_mask=ismembc(ortho_mask_IND,sort(IND_mask));
    ortho_mask_IND(~L_mask)=NaN;
    ortho_mask_I(~L_mask)=NaN;
    ortho_mask_J(~L_mask)=NaN;
    ortho_mask_K(~L_mask)=NaN;
end

end
