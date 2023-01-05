clc;
close all;
clear;

%Import K3 values
K3(:,:,1) = double(csvread('K3red.csv'));
K3(:,:,2) = double(csvread('K3green.csv'));
K3(:,:,3) = double(csvread('K3blue.csv'));

%Create Km for a second fingerprint
Km(:,:,1) = K3(:,end:-1:1,1);
Km(:,:,2) = K3(:,end:-1:1,2);
Km(:,:,3) = K3(:,end:-1:1,3);

results = zeros(2,10);

%Loop through each image and calculate the correlations
for i = 1:10
    name = strcat("testimage",int2str(i),".jpeg");
    I = imread(name);
    
    Ir = double(I(:,:,1));
    Ig = double(I(:,:,2));
    Ib = double(I(:,:,3));

    Yr = wiener2(Ir);
    Yg = wiener2(Ig);
    Yb = wiener2(Ib);

    W(:,:,1) = Ir - Yr;
    W(:,:,2) = Ig - Yg;
    W(:,:,3) = Ib - Yb;
    
    p = (corr2(W(:,:,1),K3(:,:,1)))/3 + (corr2(W(:,:,2),K3(:,:,2)))/3 + (corr2(W(:,:,3),K3(:,:,3)))/3;
    pm = (corr2(W(:,:,1),Km(:,:,1)))/3 + (corr2(W(:,:,2),Km(:,:,2)))/3 + (corr2(W(:,:,3),Km(:,:,3)))/3;
    
    results(1,i) = p;
    results(2,i) = pm;
end

%Save results as a csv
csvwrite('verify.csv',results);