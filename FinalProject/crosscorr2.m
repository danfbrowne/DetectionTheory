function ret = crosscorr2(array1, array2)
% function ret = crosscor2(array1, array2)
% Computes 2D crosscorrelation of 2D arrays
% Function returns DOUBLE type 2D array ret!
array1 = double(array1);
array2 = double(array2);

if ~(size(array1,1)==size(array2,1) && size(array1,2)==size(array2,2))
    fprintf('  The array dimensions do not match.\n')
    ret = 0;
else
    array1 = array1 - mean(array1(:));
    array2 = array2 - mean(array2(:));

    %%%%%%%%%%%%%%% End of filtering
    tilted_array2 = fliplr(array2);
    tilted_array2 = flipud(tilted_array2);
    TA = fft2(tilted_array2);
    FA = fft2(array1);
    AC = FA .* TA;
    normalizer = sqrt(sum(array1(:).^2)*sum(array2(:).^2));

    if normalizer==0,
        ret = 0;
    else
        ret = real(ifft2(AC))/normalizer;
    end
end
