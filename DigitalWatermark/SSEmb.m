function Y = SSEmb(X,Bit,Sigma,Key)
%X (greyscale image)
%Bit (bit to be embedded)
%Sigma (standard deviation of watermark signal)
%Key (watermark key used to initialize the PRNG(randn)
%Y (watermarked uint8 image)

sizeX = size(X);

rng(Key);
w = normrnd(0,Sigma,sizeX); %array of random values

mult = double(-1 + 2 * Bit); %decides whether w is added or subtracted

Y = double(X) + (mult * w);
Y = uint8(Y); %convert double into uint8

end

