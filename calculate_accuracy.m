
pred = imread('water_mask.png');

if ndims(pred) == 3
    pred = pred(:,:,1);
end

pred = pred > 0;


gt = imread('sentinel12_s2_75_msk.tif');
gt = gt > 0;

figure;

subplot(1,3,1)
imshow(gt)
title('reference waterbody mask')

subplot(1,3,2)
imshow(pred)
title('Predicted mask')

subplot(1,3,3)
imshow(gt & pred)
title('Overlap')

if ~isequal(size(pred), size(gt))
    pred = imresize(pred, size(gt), 'nearest');
end

TP = sum((pred==1) & (gt==1), 'all');
FP = sum((pred==1) & (gt==0), 'all');
FN = sum((pred==0) & (gt==1), 'all');
TN = sum((pred==0) & (gt==0), 'all');

disp('--- Confusion Matrix ---');
disp(['TP = ', num2str(TP)]);
disp(['FP = ', num2str(FP)]);
disp(['FN = ', num2str(FN)]);
disp(['TN = ', num2str(TN)]);


accuracy  = (TP + TN) / (TP + TN + FP + FN);
precision = TP / (TP + FP);
recall    = TP / (TP + FN);
F1        = 2 * (precision * recall) / (precision + recall);

disp('--- Metrics ---');
disp(['Accuracy  = ', num2str(accuracy)]);
disp(['Precision = ', num2str(precision)]);
disp(['Recall    = ', num2str(recall)]);
disp(['F1 Score  = ', num2str(F1)]);
