function water_body_detection_working_v2(green, nir, swir1, swir2, blue)

figure('Name','Water Detection Results (NDWI + NDBI + AWEI)',...
       'Position',[200 100 1000 600]);

ax1 = axes('Position',[0.05 0.55 0.25 0.35]);
ax2 = axes('Position',[0.37 0.55 0.25 0.35]);
ax3 = axes('Position',[0.69 0.55 0.25 0.35]);

ax4 = axes('Position',[0.05 0.10 0.25 0.35]);
ax5 = axes('Position',[0.37 0.10 0.25 0.35]);
ax6 = axes('Position',[0.69 0.10 0.25 0.35]);

eps = 1e-10;

% Indices

NDWI   = (green - nir) ./ (green + nir + eps);
NDBI   = (swir1 - nir) ./ (swir1 + nir + eps);

% AWEI variants
AWEInsh = 4*(green - swir1) - (0.25*nir + 2.75*swir2);
AWEIsh  = blue + 2.5*green - 1.5*(nir + swir1) - 0.25*swir2;

% Median filtering

NDWI   = medfilt2(NDWI,[3 3]);
NDBI   = medfilt2(NDBI,[3 3]);
AWEInsh = medfilt2(AWEInsh,[3 3]);
AWEIsh  = medfilt2(AWEIsh,[3 3]);

% Step 1: NDWI-based water (high recall)

ndwiWater = NDWI > 0;

% Step 2: Remove built-up land using NDBI

builtUp = NDBI > 0;
ndwiNoBuiltUp = ndwiWater & ~builtUp;

% Step 3: Shadow detection using AWEI difference

shadow = (AWEInsh > 0) & (AWEIsh <= 0);

% Final water mask

finalWater = ndwiNoBuiltUp & ~shadow;

binaryWater = finalWater > 0;

% Morphological cleaning

binaryWater = imopen(binaryWater, strel('disk',2));
binaryWater = bwareaopen(binaryWater, 300);

% Segmentation

labeled = bwlabel(binaryWater,8);

% Water body statistics

numWaterBodies  = max(labeled(:));
waterPixelCount = sum(binaryWater(:));

disp(['Number of water bodies detected: ', num2str(numWaterBodies)]);
disp(['Total water-covered pixels: ', num2str(waterPixelCount)]);

% Display

axes(ax1); imshow(NDWI,[]); title('NDWI');
axes(ax2); imshow(NDBI,[]); title('NDBI (Built-up)');
axes(ax3); imshow(shadow); title('Shadow Mask');

axes(ax4); imshow(finalWater); title('Final Water Mask');
axes(ax5); imshow(binaryWater); title('Binary + Cleaned');

imwrite(binaryWater, 'water_mask.png');

axes(ax6);
imshow(label2rgb(labeled,'jet','k','shuffle'));
title('Segmented Water Bodies');

annotation('textbox',[0.72 0.03 0.26 0.06],...
    'String',{['Water Bodies: ', num2str(numWaterBodies)],...
              ['Water Area (pixels): ', num2str(waterPixelCount)]},...
    'FontSize',12,...
    'FontWeight','bold',...
    'Color','w',...
    'EdgeColor','none',...
    'BackgroundColor','none');

end
