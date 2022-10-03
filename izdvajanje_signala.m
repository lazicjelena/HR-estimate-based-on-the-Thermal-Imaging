clc;
clear all;
close all;

%% preproccessing of image and signal extraction

name='LukaStancev';
matObj = matfile(strcat(name,'_anfas.mat'));
s=[];
[~,~,data] = xlsread(strcat(name,'_anfas.csv')) ;
t = cell2mat(data(3:49224,1));
fs = 1000;
fps = 60;
t = t/fs;
ecg = cell2mat(data(3:49224,2));
x1=0;
x2=0;
y1=0;
y2=0;
position=[];
max_duzina=12600;

figure(1)
for i=1:12600
    a=matObj.data(:,:,i);  
    % normalizacija
    MIN=min(a(:));
    a=a-MIN;
    MAX=max(a(:));
    a=a/MAX;
    
    if i==1
        % sjecenje llica
        thresh = multithresh(a,2);
        h = hist(a(:),50);
        slika=zeros([256,320]);
        if h(round(thresh(1)*50))>1600 || h(round(thresh(2)*50))>1600
            T = graythresh(a)+0.17;
            slika=im2bw(a,T);
        else
            slika1=im2bw(a,thresh(1)+0.1);
            slika2=im2bw(a,thresh(2)-0.1);
            slika=slika1-slika2;
        end
        slika=medfilt2(slika);
        se = strel('disk',5);
        slika=imopen(slika,se);
        [L,n]=bwlabel(slika);
        for j=1:n
            B=L==j;
            pom=sum(B(:));
            if pom>10000
                slika=B;
            end
        end
        se = strel('sphere',5);
        slika=imclose(slika,se);
        y1=1;
        while(sum(slika(:,y1))==0)
            y1=y1+1;
        end
        y2=320;
        while(sum(slika(:,y2))==0)
            y2=y2-1;
        end
        x1=1;
        while(sum(slika(x1,:))==0)
            x1=x1+1;
        end
        x2=256;
        while(sum(slika(x2,:))==0)
            x2=x2-1;
        end
        a=a(x1:x2,y1:y2);
        original=a;
        ptsOriginal=detectHarrisFeatures(a);
        [featuresOriginal,validPtsOriginal]= extractFeatures(original,ptsOriginal);
    else
        a=a(x1:x2,y1:y2);
        % uparivanje obiljezja
        ptsDistorted=detectHarrisFeatures(a);
        [featuresDistorted, validPtsDistorted] = extractFeatures(a,ptsDistorted);
        indexPairs = matchFeatures(featuresOriginal, featuresDistorted);
        matchedOriginal  = validPtsOriginal(indexPairs(:,1));
        matchedDistorted = validPtsDistorted(indexPairs(:,2));
        
        if featuresOriginal.NumFeatures==featuresDistorted.NumFeatures
            % pronalazak transformacije
            [tform, inlierIdx] = estimateGeometricTransform(...
            matchedDistorted, matchedOriginal, 'similarity');
    
            Tinv  = tform.invert.T;
            ss = Tinv(2,1);
            sc = Tinv(1,1);
            scaleRecovered = sqrt(ss*ss + sc*sc);
            thetaRecovered = atan2(ss,sc)*180/pi;
        
            % recover
            outputView = imref2d(size(original));
            recovered  = imwarp(a,tform,'OutputView',outputView); 
            I = recovered;
        else
            I=a;
        end
    end

 % selection ROI
    if i==1
        S = [1 1 64 64];  
        c=jet;
        imshow(original,'ColorMap',c);
        h = imrect(gca, S);
        addNewPositionCallback(h,@(p) title('Choose ROI'));
        fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'))
        setPositionConstraintFcn(h,fcn)
        position = wait(h); 
    else
        imshow(I,'ColorMap',c);
        rectangle('Position',position,'Edgecolor', 'w','LineWidth',3);
        I2 = imcrop(I,position);
        I2 = MAX*I2+MIN;
        s=[s sum(I2(:))/65/65];
    end
end

s = 0.04*s-273.15;