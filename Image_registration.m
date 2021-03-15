clc
clear all
close all


[file,path] = uigetfile('*.*');
f1 = fullfile(path,file);
if prod(double(file) == 0) && prod(double(path) == 0)
    return
end
a = imread(f1);   % image that will be transformed

in = input('Do you want to enhance? (Press 1 for yes 2 for No): ');

if in == 1
  a = main_pipeline(a);
endif


[file,path] = uigetfile('*.*');
f1 = fullfile(path,file);
if prod(double(file) == 0) && prod(double(path) == 0)
    return
end
a1 = imread(f1);    % reference/base image

b = size(a);


% select points in the reference image and corresponsing points in the image to be transformed

n = 8;
Fig = figure('Position', get(0, 'Screensize'));
%annotation('textbox',[.445 .5 .4 .5],'String',['Select ',num2str(n),' points in both the images'],'FitBoxToText','on')
annotation("textbox", [0.45 0.9 .4 .5], "string", ...
             {"Select ",num2str(n)," points in both the images"}, "fontsize", 24, ...
             "horizontalalignment", "center", "fitboxtotext", "on");
subplot(1,2,1)
image(a);
axis image
colormap gray
title('Click a point in this image')
a=double(a);
subplot(1,2,2)
image(a1);
axis image
colormap gray
title('Then click the corresponding point in this reference image')

%initializing necessary variables for taking input

x = zeros(1,n);
y = zeros(1,n);
x1 = zeros(1,n);
y1 = zeros(1,n);

for i= 1:n
  [x0,y0] = ginput(1);    %taking point on the image to be transformed
  hold on
  scatter(x0,y0,'filled')
  x(i) = x0;
  y(i) = y0;
  [x10,y10] = ginput(1);    %taking corresponding point on the reference image
  hold on
  scatter(x10,y10,'filled')
  x1(i) = x10;
  y1(i) = y10;
end

x = x-b(2)/2;
y = y-b(1)/2;

close(Fig)

%initializing variables for the tranformation matrix

i=0;
B = zeros(1,2*n);
for i1 = 1:2:2*n
    i=i+1;
    B(i1) = x1(i);
    B(i1+1) = y1(i);     
end

i=0;
A1 = zeros(2*n,1);
A2 = zeros(2*n,1);
A3 = zeros(2*n,1);
A4 = zeros(2*n,1);
A5 = zeros(2*n,1);
A6 = zeros(2*n,1);
A7 = zeros(2*n,1);
A8 = zeros(2*n,1);

for i1 = 1:2:2*n
    i=i+1;
    A1(i1) = x(i);
    A2(i1) = y(i);
    A3(i1) = 1;
    A7(i1) = -x1(i)*x(i);
    A8(i1) = -y(i)*x1(i);
    A4(i1+1) = x(i);
    A5(i1+1) = y(i);
    A6(i1+1) = 1;
    A7(i1+1) = -x(i)*y1(i);
    A8(i1+1) = -y(i)*y1(i);
end


% homography transformation matrix
Aa = [A1 A2 A3 A4 A5 A6 A7 A8];
h = (Aa'*Aa)\Aa'*B';
A = [h(1) h(2) h(3); h(4) h(5) h(6); h(7) h(8) 1];
        
color = 0;

% checking whether the image is color or grayscale
b = size(a);
if size(b,2)==3
  color = 1;
end

% bringing the origin to the center by transformation matrix
trans = [1,0,-b(2)/2;0,1,-b(1)/2;0,0,1];

disp('The transform matrix is ')
disp(A*trans);

%building the output of the transformed image

outx = zeros(b(1),b(2));
outy = zeros(b(1),b(2));

for i = 1:b(1)
    for j = 1:b(2)
        new  = A*trans*[j;i;1];
        outx(i,j) = round(new(1)/new(3));
        outy(i,j) = round(new(2)/new(3));
    end
end

% forming the transformed image
minoutx = min(min(outx));
minouty = min(min(outy));

maxoutx = max(max(outx));
maxouty = max(max(outy));

f = -1*ones(maxouty+abs(minouty)+1,maxoutx+abs(minoutx)+1);

for i = 1:b(1)
    for j = 1:b(2)
        p = outy(i,j)+abs(minouty)+1;
        q = outx(i,j)+abs(minoutx)+1;
        f(outy(i,j)+abs(minouty)+1,outx(i,j)+abs(minoutx)+1,1) = a(i,j,1);
        if color == 1
            f(outy(i,j)+abs(minouty)+1,outx(i,j)+abs(minoutx)+1,2) = a(i,j,2);
            f(outy(i,j)+abs(minouty)+1,outx(i,j)+abs(minoutx)+1,3) = a(i,j,3);
        end    
    end
end

%filling in the gaps by using nedian filter by doing interpolation

b1 = size(f);
for i = 2:b1(1)-2
    for j = 2:b1(2)-2
        if f(i,j)==-1
       f(i,j) = median([f(i-1,j-1),f(i-1,j),f(i-1,j+1),f(i,j-1),f(i,j),f(i,j+1),f(i+1,j-1),f(i+1,j),f(i+1,j+1)]);
       if color == 1
       f(i,j,2) = median([f(i-1,j-1,2),f(i-1,j,2),f(i-1,j+1,2),f(i,j-1,2),f(i,j,2),f(i,j+1,2),f(i+1,j-1,2),f(i+1,j,2),f(i+1,j+1,2)]);
       f(i,j,3) = median([f(i-1,j-1,3),f(i-1,j,3),f(i-1,j+1,3),f(i,j-1,3),f(i,j,3),f(i,j+1,3),f(i+1,j-1,3),f(i+1,j,3),f(i+1,j+1,3)]);
       end
        end
    end
end


%displaying the images

figure();
subplot(1,3,1)
imshow(a1); title('Base image')
subplot(1,3,2)
imshow(a); title('Image to be transformed')
subplot(1,3,3)
imshow(f); title('Original Image Registered')

% saving the image
in2 = input('Do you want to save the image ? (Press 1 for yes 2 for No) : ');
if in2 == 1
    [file,path] = uiputfile('*.*');
    f2 = fullfile(path,file);
    imwrite(f,f2);
end
