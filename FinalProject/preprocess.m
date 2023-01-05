%Daniel Browne
%EECE 566
%Generates a grayscale fingerprint after preprocessing the original fingerprint

clc;
clear;
close all;

%Load in K
Raw = load('K.mat');
K = Raw.K;

Kr = K(:,:,1);
Kg = K(:,:,2);
Kb = K(:,:,3);

%process each column
for j = 1:size(Kr,2)
    mr = mean(Kr(:,j));
    mg = mean(Kg(:,j));
    mb = mean(Kb(:,j));
    
    for i = 1:size(Kr,1)
        Kr(i,j) = Kr(i,j) - mr;
        Kg(i,j) = Kg(i,j) - mg;
        Kb(i,j) = Kb(i,j) - mb;
    end
end

%process each row
for i = 1:size(Kr,1)
    mr = mean(Kr(i,:));
    mg = mean(Kg(i,:));
    mb = mean(Kb(i,:));
    
    for j = 1:size(Kr,2)
        Kr(i,j) = Kr(i,j) - mr;
        Kg(i,j) = Kg(i,j) - mg;
        Kb(i,j) = Kb(i,j) - mb;
    end
end

success = 1;
%Check that each column has a mean of 0
for i = 1:size(Kr,2)
    if mean(Kr(:,i)) > 10^(-15) || mean(Kg(:,i)) > 10^(-15) || mean(Kb(:,i)) > 10^(-15)
        success = 0;
    end
end

%Check that each row has a mean of 0
for i = 1:size(Kr,1)
    if mean(Kr(i,:)) > 10^(-15) || mean(Kg(i,:)) > 10^(-15) || mean(Kb(i,:)) > 10^(-15)
        success = 0;
    end
end

%Print result of mean check
if success
    fprintf("Check passed\n");
else
    fprintf("Check failed\n");
end

%generate the PRNU difference for analysis    
difference(:,:,1) = K(:,:,1) - Kr;
difference(:,:,2) = K(:,:,2) - Kg;
difference(:,:,3) = K(:,:,3) - Kb;

figure
imshow(mat2gray(difference));
figure
imshow(mat2gray(difference(1:256,1:256)))

%save a grayscale version of the fingerprint
grayfp = 0.3.*Kr + 0.6.*Kg + 0.1.*Kb;
csvwrite("PRNUgray.csv",grayfp);
    