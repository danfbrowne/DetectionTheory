clc;
close all;
clear;

X1 = imread('len512.jpg');
X2 = imread('len256.bmp');
imagex = size(X1,1);
results = zeros(4,9);
Sigma = [1,2,5,10];

for sig = 1:4 %loop for each sigma value
    correct = zeros(1,9);
    for i = 1:1000 %i is also used for a key
        %progress statements
        if mod(i,10)==0
            fprintf("Iteration: 512, %d, %d\n",sig,i);
        end
        Bit = i > 500;
        Y = SSEmb(X1, Bit, Sigma(sig), i); %embed bit
        Attacked = [Y;Y;Y;Y;Y;Y;Y;Y;Y]; %set an array that holds all attacks for this key

        %store all attacked images
        imwrite(Y,'watermarked.jpg','jpg','quality',90);
        Attacked(ind(1,imagex):ind(2,imagex)-1,:) = imread('watermarked.jpg');
        imwrite(Y,'watermarked.jpg','jpg','quality',60);
        Attacked(ind(2,imagex):ind(3,imagex)-1,:) = imread('watermarked.jpg');
        imwrite(Y,'watermarked.jpg','jpg','quality',5);
        Attacked(ind(3,imagex):ind(4,imagex)-1,:) = imread('watermarked.jpg');
        Attacked(ind(4,imagex):ind(5,imagex)-1,:) = imadjust(Y);
        Attacked(ind(5,imagex):ind(6,imagex)-1,:) = imadjust(Y,[],[],0.1);
        Attacked(ind(6,imagex):ind(7,imagex)-1,:) = imadjust(Y,[],[],5);
        Attacked(ind(7,imagex):ind(8,imagex)-1,:) = wiener2(Y);
        Attacked(ind(8,imagex):ind(9,imagex)-1,:) = medfilt2(Y,[3 3]);
        Attacked(ind(9,imagex):ind(10,imagex)-1,:) = imresize(imresize(Y,1/2),2);

        %accumulate number of correctly extracted bits
        for j = 1:9
            EBit = SSExt(Attacked(ind(j,imagex):ind(j+1,imagex)-1,:), Sigma(sig), i);
            if EBit == Bit
                correct(1,j) = correct(1,j) + 1;
            end 
        end
    end
    results(sig,:) = correct; %store results
end

csvwrite('512results.csv',results); %save results

imagex = size(X2,1);
results = zeros(4,9);
Sigma = [1,2,5,10];
for sig = 1:4 %loop for each sigma value
    correct = zeros(1,9);
    for i = 1:1000 %i is also used for a key
        %progress statements
        if mod(i,10)==0
            fprintf("Iteration: 256, %d, %d\n",sig,i);
        end
        Bit = i > 500;
        Y = SSEmb(X2, Bit, Sigma(sig), i); %embed bit
        Attacked = [Y;Y;Y;Y;Y;Y;Y;Y;Y]; %set an array that holds all attacks for this key

        %store all attacked images
        imwrite(Y,'watermarked.jpg','jpg','quality',90);
        Attacked(ind(1,imagex):ind(2,imagex)-1,:) = imread('watermarked.jpg');
        imwrite(Y,'watermarked.jpg','jpg','quality',60);
        Attacked(ind(2,imagex):ind(3,imagex)-1,:) = imread('watermarked.jpg');
        imwrite(Y,'watermarked.jpg','jpg','quality',5);
        Attacked(ind(3,imagex):ind(4,imagex)-1,:) = imread('watermarked.jpg');
        Attacked(ind(4,imagex):ind(5,imagex)-1,:) = imadjust(Y);
        Attacked(ind(5,imagex):ind(6,imagex)-1,:) = imadjust(Y,[],[],0.1);
        Attacked(ind(6,imagex):ind(7,imagex)-1,:) = imadjust(Y,[],[],5);
        Attacked(ind(7,imagex):ind(8,imagex)-1,:) = wiener2(Y);
        Attacked(ind(8,imagex):ind(9,imagex)-1,:) = medfilt2(Y,[3 3]);
        Attacked(ind(9,imagex):ind(10,imagex)-1,:) = imresize(imresize(Y,1/2),2);

        %accumulate number of correctly extracted bits
        for j = 1:9
            EBit = SSExt(Attacked(ind(j,imagex):ind(j+1,imagex)-1,:), Sigma(sig), i);
            if EBit == Bit
                correct(1,j) = correct(1,j) + 1;
            end 
        end
    end
    results(sig,:) = correct; %store results
end

csvwrite('256results.csv',results);



errorm = zeros(5);

cor=zeros(1000,1); %run each set of variables 1000 times
Sigma = [.5,5,1,5,10];
%graph titles
names = ["lena256, sig=.5, JPEG 5%","lena256, sig=5, Gamma Correction=10","lena256, sig=1, Median Filtering 10x10","lena512, sig=5, JPEG 60%","lena512, sig=10, Histogram Equalization"];
     
for row = 1:5
    for n = 1:size(cor,1)
        Bit = n>size(cor,1)/2;
        %one case per attack
        switch row
            case 1
                Y = SSEmb(X1, Bit, Sigma(row), n);
                imwrite(Y,'watermarked.jpg','jpg','quality',5);
                Y1 = imread('watermarked.jpg');
            case 2
                Y = SSEmb(X1, Bit, Sigma(row), n);
                Y1 = imadjust(Y,[],[],10);
            case 3
                Y = SSEmb(X1, Bit, Sigma(row), n);
                Y1 = medfilt2(Y,[10 10]);
            case 4
                Y = SSEmb(X2, Bit, Sigma(row), n);
                imwrite(Y,'watermarked.jpg','jpg','quality',60);
                Y1 = imread('watermarked.jpg');
            otherwise
                Y = SSEmb(X2, Bit, Sigma(row), n);
                Y1 = imadjust(Y);
        end
                
        
        EBit = SSExt(Y1, Sigma(row), n);
        cor(n) = Correlate(Y1,Sigma(row),n); %Calculates correlation for each iteration
    end

    ShowHist(cor,names(row)); %Plots histogram for all correlation values
    [phat0,phat1,sig0,sig1,perror] = ErrorCalc(cor); %calculates all necessary values per row
    errorm(row,:) = [phat0,phat1,sig0,sig1,perror]; %stores results
end

csvwrite('errorprob.csv',errorm); %saves results

%plot a histogram with a given set of correlation values
function ShowHist(cor,t)
    [a1,b1] = hist(cor(1:size(cor,1)/2));
    [a2,b2] = hist(cor(size(cor,1)/2+1:size(cor,1)));
    
    figure
    h1 = bar(b1,a1,'hist');
    hold on;
    h2 = bar(b2,a2,'hist');
    set(h1,'facecolor','blue','FaceAlpha',0.3);
    set(h2,'facecolor','red','FaceAlpha',0.3);
    title(t);
    hold off;
end

%calculates the correlation
function cor = Correlate(Y,Sigma,Key)
    Y = double(Y);
    C = wiener2(Y);
    rng(Key);
    w = normrnd(0,Sigma,size(Y));
    difmatrix = (Y - C);

    for i = 1:size(Y,1)
        for j = 1:size(Y,2)
            difmatrix(i,j)=difmatrix(i,j) * w(i,j);
        end
    end

    cor = sum(difmatrix,"all") / double(size(Y,1)*size(Y,2));
end

%calculates all necessary values for a given list of correllations
function [phat0,phat1,sig0,sig1,perror] = ErrorCalc(cor)
    p0 = cor(1:size(cor,1)/2);
    p1 = cor(size(cor,1)/2+1:size(cor,1)); 
    phat0 = mean(p0);
    phat1 = mean(p1);
    
    p0diff=zeros(size(cor,1)/2,1);
    p1diff=zeros(size(cor,1)/2,1);
    for i = 1:size(cor,1)/2
       p0diff(i) = (p0(i)-phat0)^2;
       p1diff(i) = (p1(i)-phat1)^2;
    end
    
    sig0 = sqrt(mean(p0diff));
    sig1 = sqrt(mean(p1diff));
    
    perror = (Q((-1*phat0)/sig0)+Q(phat1/sig1))/2;
end

%the Q function
function [out] = Q(x)
    out = (1-erf(x/sqrt(2)))/2;
end

%calculates starting/ending index for the stored attacked images
function index = ind(num,imagex)
    index = 1 + (num-1)*imagex;
end