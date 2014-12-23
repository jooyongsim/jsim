
function imgv = img2vector(img)

[m,n] = size(img);
imgv = reshape(img,m*n,1);
imgv(isnan(imgv))=[];
imgv(imgv==0)=[];

end