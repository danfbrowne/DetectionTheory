clc;
close all;
clear;

%Setting result variables
I = imread('image1.jpeg');

topr = zeros(size(I,1),size(I,2),'double');
topg = zeros(size(I,1),size(I,2),'double');
topb = zeros(size(I,1),size(I,2),'double');

bottomr = zeros(size(I,1),size(I,2),'double');
bottomg = zeros(size(I,1),size(I,2),'double');
bottomb = zeros(size(I,1),size(I,2),'double');

%Process each image
for i = 1:30
    name = strcat("image",int2str(i),".jpeg");
    I = imread(name);

    Ir = double(I(:,:,1));
    Ig = double(I(:,:,2));
    Ib = double(I(:,:,3));

    Yr = wiener2(Ir);
    Yg = wiener2(Ig);
    Yb = wiener2(Ib);

    Wr = Ir - Yr;
    Wg = Ig - Yg;
    Wb = Ib - Yb;

    %Adding values to sum in numerator and denominator for each channel
    topr = topr + Wr .* Ir;
    topg = topg + Wg .* Ig;
    topb = topb + Wb .* Ib;

    bottomr = bottomr + Ir .* Ir;
    bottomg = bottomr + Ig .* Ig;
    bottomb = bottomr + Ib .* Ib;
end

%Calculate channels of K3 using the sums
Kr = topr ./ bottomr;
Kg = topg ./ bottomg;
Kb = topb ./ bottomb;

K3(:,:,1) = Kr;
K3(:,:,2) = Kg;
K3(:,:,3) = Kb;

%Store K3 as 3 csv files
csvwrite('K3red.csv',Kr);
csvwrite('K3blue.csv',Kg);
csvwrite('K3green.csv',Kb);

clearvars -except K3 Kr Kg Kb;