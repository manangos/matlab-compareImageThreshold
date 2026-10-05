%% Φόρτωση εικόνας
I = imread('normal40_var_refl.png');   

if size(I,3) == 3
    Igray = rgb2gray(I);
else
    Igray = I;
end
% threshold και δυαδική εικόνα
I2 = adapthisteq(Igray);
bw = imbinarize(I2, 'adaptive', 'Sensitivity',0.32);
% θόρυβος
bw = bwareaopen(bw, 80);
bw = imclose(bw, strel('disk',3));
bw = imfill(bw, 'holes');

%% watershed/ μετατροπη αποστασης
D = -bwdist(~bw);
h = 5;
mask_em = imextendedmin(D, h);
D2 = imimposemin(D, mask_em);
L_watershed = watershed(D2);
bw_final_separated = bw;
bw_final_separated(L_watershed == 0) = 0;
% συνδεδεμένες περιοχές
[L_final, num_separated] = bwlabel(bw_final_separated);


%% χαρακτηριστικά

stats = regionprops(L_final, Igray, ...
    'Area', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength');

ratios = zeros(length(stats),1);

for k = 1:length(stats)
    ratios(k) = stats(k).MajorAxisLength / stats(k).MinorAxisLength;
end

%% αποτελέσματα
figure; 
subplot(1,2,1);
imshow(Igray); title('Αρχική εικόνα');

subplot (1,2,2);
RGB_separated = label2rgb(L_final, 'jet', [0 0 0.4]);
imshow(RGB_separated);
title(['τμηματοποίηση(watershed', num2str(num_separated), 'πυρήνες)']);

%% προβολή αποτελεσμάτων
stats_separated = regionprops(L_final, Igray, ...
    'Area', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength');
stats_table_separated = struct2table(stats_separated)
stats_table_separated.Ratio = stats_table_separated.MajorAxisLength ./ stats_table_separated.MinorAxisLength
