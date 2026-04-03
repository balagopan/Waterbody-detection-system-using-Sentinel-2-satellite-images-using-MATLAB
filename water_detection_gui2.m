function water_detection_gui
clc; close all;

fig = figure('Name','Water Body Detection (Sentinel-2)',...
             'NumberTitle','off',...
             'Position',[300 150 1000 600]);

% Create plots

axblue  = axes('Position',[0.05 0.78 0.15 0.15]); title('Blue (B02)'); axis off
axgreen = axes('Position',[0.22 0.78 0.15 0.15]); title('Green (B03)'); axis off
axNIR   = axes('Position',[0.39 0.78 0.15 0.15]); title('NIR (B08)'); axis off
axSWIR1 = axes('Position',[0.56 0.78 0.15 0.15]); title('SWIR-1 (B11)'); axis off
axSWIR2 = axes('Position',[0.73 0.78 0.15 0.15]); title('SWIR-2 (B12)'); axis off

% Buttons

uicontrol('Style','pushbutton','String','Load Blue (B02)',...
    'Position',[40 500 150 35],'Callback',@loadBlue);

uicontrol('Style','pushbutton','String','Load Green (B03)',...
    'Position',[210 500 150 35],'Callback',@loadGreen);

uicontrol('Style','pushbutton','String','Load NIR (B08)',...
    'Position',[380 500 150 35],'Callback',@loadNIR);

uicontrol('Style','pushbutton','String','Load SWIR-1 (B11)',...
    'Position',[550 500 150 35],'Callback',@loadSWIR1);

uicontrol('Style','pushbutton','String','Load SWIR-2 (B12)',...
    'Position',[720 500 150 35],'Callback',@loadSWIR2);

uicontrol('Style','pushbutton','String','Select AOI',...
    'FontSize',11,'Position',[350 450 200 40],...
    'Callback',@selectAOI);

uicontrol('Style','pushbutton','String','Run Detection',...
    'FontSize',12,'Position',[350 395 200 45],...
    'Callback',@runDetection);

% Storage variables

blue  = [];
green = [];
nir   = [];
swir1 = [];
swir2 = [];

% Load band callbacks

function loadBlue(~,~)
    blue = double(imread(selectFile('Select BLUE band (B02)')));
    axes(axblue); imshow(blue,[]); title('Blue (B02)');
end

function loadGreen(~,~)
    green = double(imread(selectFile('Select GREEN band (B03)')));
    axes(axgreen); imshow(green,[]); title('Green (B03)');
end

function loadNIR(~,~)
    nir = double(imread(selectFile('Select NIR band (B08)')));
    axes(axNIR); imshow(nir,[]); title('NIR (B08)');
end

function loadSWIR1(~,~)
    swir1 = double(imread(selectFile('Select SWIR-1 band (B11)')));
    if ~isempty(green)
        swir1 = imresize(swir1, size(green), 'bilinear');
    end
    axes(axSWIR1); imshow(swir1,[]); title('SWIR-1 (Resampled)');
end

function loadSWIR2(~,~)
    swir2 = double(imread(selectFile('Select SWIR-2 band (B12)')));
    if ~isempty(green)
        swir2 = imresize(swir2, size(green), 'bilinear');
    end
    axes(axSWIR2); imshow(swir2,[]); title('SWIR-2 (Resampled)');
end

% AOI selection

function selectAOI(~,~)

    if isempty(blue) || isempty(green) || isempty(nir) || isempty(swir1) || isempty(swir2)
        errordlg('Load all five bands before selecting AOI!');
        return;
    end

    figure; imshow(green,[]);
    title('Draw rectangular AOI and double-click');

    rect = getrect;

    blue  = imcrop(blue, rect);
    green = imcrop(green, rect);
    nir   = imcrop(nir, rect);
    swir1 = imcrop(swir1, rect);
    swir2 = imcrop(swir2, rect);

    close;

    axes(axblue);  imshow(blue,[]);  title('Blue (Clipped)');
    axes(axgreen); imshow(green,[]); title('Green (Clipped)');
    axes(axNIR);   imshow(nir,[]);   title('NIR (Clipped)');
    axes(axSWIR1); imshow(swir1,[]); title('SWIR-1 (Clipped)');
    axes(axSWIR2); imshow(swir2,[]); title('SWIR-2 (Clipped)');
end

% Run detection

function runDetection(~,~)

    if isempty(green)
        errordlg('Load bands and select AOI first!');
        return;
    end

    Waterbody_detection2(blue, green, nir, swir1, swir2);
end

% File selector helper

function file = selectFile(prompt)
    [f,p] = uigetfile({'*.jp2;*.tif'}, prompt);
    if isequal(f,0)
        error('File selection cancelled');
    end
    file = fullfile(p,f);
end

end
