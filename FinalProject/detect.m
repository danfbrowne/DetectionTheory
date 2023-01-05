%Daniel Browne
%EECE 566
%Determines which images match the given fingerprint using the PCE

clc;
clear;
close all;

%load grayscale fingerprint
K = csvread('PRNUgray.csv');

%initialize variables
imagefiles = dir('.\All_34_images\*.jpg');
numfiles = length(imagefiles);
PCE = zeros(1,numfiles);
imagenames = strings(1,numfiles);

%Process the images one at a time
for n = 1:numfiles
    fprintf("Processing image %d\n",n);
    location = strcat('.\All_34_images\', imagefiles(n).name);
    imagenames(n) = imagefiles(n).name;
    Ik = double(imread(location));
    
    %Find noise residual using Wiener filter
    Ir = Ik(:,:,1);
    Ig = Ik(:,:,2);
    Ib = Ik(:,:,3);
    
    Yr = wiener2(Ir);
    Yg = wiener2(Ig);
    Yb = wiener2(Ib);
    
    Wk(:,:,1) = Ir - Yr;
    Wk(:,:,2) = Ig - Yg;
    Wk(:,:,3) = Ib - Yb;
    
    %generate grayscale residual
    residual = 0.3.*Wk(:,:,1) + 0.6.*Wk(:,:,2) + 0.1.*Wk(:,:,3);
    
    W = zeros(size(K,1),size(K,2));
    
    xdiff = size(W,1)-size(Wk,1);
    ydiff = size(W,2)-size(Wk,2);
    
    %pad array with 0s to have the same size as K
    W = padarray(residual,[xdiff ydiff],'post');
    
    %find max value of NCC
    NCC = crosscorr2(W,K);
    maxval = max(NCC(:));
    [xmax,ymax] = find(NCC==maxval);
    
    %Calculate PCE
    sum = 0.0;
    nwidth = 5.0;
    dist = nwidth/2;
    for i = 1:size(NCC,1)
        for j = 1:size(NCC,2)
            if abs(xmax-i) > dist && abs(ymax-i) > dist
                sum = sum + NCC(i,j)^2;
            end
        end
    end
    
    PCE(n) = (maxval^2)/(1/(size(NCC,1)*size(NCC,2)-nwidth^2)*sum);
    
    %display mesh of positive detections
    if PCE(n) > 60
        figure
        mesh(NCC);
        title(strcat("NCC for ", imagenames(n)));
    end
end

%display bar graph
figure
x = categorical(imagenames);
bar(x,PCE);
xtickangle(90);
set(gca,'YScale','log');
    