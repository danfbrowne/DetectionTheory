function Bit = SSExt(Y,Sigma,Key)
    %Y (watermarked and attacked/processed uint8 image)
    %Sigma (standard deviation of watermark signal)
    %Key (watermark key used to initialize the PRNG(randn)
    %Bit (extracted bit)

    Y = double(Y);
    C = wiener2(Y);

    rng(Key);
    w = normrnd(0,Sigma,size(Y)); %array of random values

    difmatrix = (Y - C);

    %calculates (yi-ci)*wi for each pixel
    for i = 1:size(Y,1)
        for j = 1:size(Y,2)
            difmatrix(i,j)=difmatrix(i,j) * w(i,j);
        end
    end

    %calculate average of all values
    approx = mean(difmatrix,"all");

    if approx > 0
        Bit = 1;
    else
        Bit = 0;
    end
end

