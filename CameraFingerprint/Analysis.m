clc;
close all;
clear;

%Import K3 values
Kr = csvread('K3red.csv');
Kg = csvread('K3green.csv');
Kb = csvread('K3blue.csv');

%Turn each matrix into a vector
Kr_v = Kr(:);
Kg_v = Kg(:);
Kb_v = Kb(:);

meanr = mean(Kr_v);
meang = mean(Kg_v);
meanb = mean(Kb_v);

prdiff = zeros(size(Kr_v,1),1);
pgdiff = zeros(size(Kg_v,1),1);
pbdiff = zeros(size(Kb_v,1),1);

%loop through and calculate variance
for i = 1:size(Kr_v)
   prdiff(i) = (Kr_v(i)-meanr)^2;
   pgdiff(i) = (Kg_v(i)-meang)^2;
   pbdiff(i) = (Kb_v(i)-meanb)^2;
end

varr = sqrt(mean(prdiff));
varg = sqrt(mean(pgdiff));
varb = sqrt(mean(pbdiff));

%Store data as a csv
histdata = [meanr,meang,meanb;
            varr, varg, varb];

csvwrite('histdata.csv',histdata);

%display histogram for each channel
figure
histogram(Kr_v,'FaceColor','r','EdgeColor','r');
title('PRNU distribution of Red Channel');
figure
histogram(Kg_v,'FaceColor','g','EdgeColor','g');
title('PRNU distribution of Green Channel');
figure
histogram(Kb_v,'FaceColor','b','EdgeColor','b');
title('PRNU distribution of Blue Channel');

PRNUred = mat2gray(Kr);
PRNUgreen = mat2gray(Kg);
PRNUblue = mat2gray(Kb);

PRNUfinal = cat(3, PRNUred,PRNUblue,PRNUgreen);

%Save and display fingerprint
imwrite(PRNUfinal,'fingerprint.jpeg');

figure
imshow(PRNUfinal);