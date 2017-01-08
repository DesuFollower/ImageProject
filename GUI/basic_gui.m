function varargout = basic_gui(varargin)
% BASIC_GUI MATLAB code for basic_gui.fig
%      BASIC_GUI, by itself, creates a new BASIC_GUI or raises the existing
%      singleton*.
%
%      H = BASIC_GUI returns the handle to a new BASIC_GUI or the handle to
%      the existing singleton*.
%
%      BASIC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASIC_GUI.M with the given input arguments.
%
%      BASIC_GUI('Property','Value',...) creates a new BASIC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before basic_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to basic_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help basic_gui

% Last Modified by GUIDE v2.5 19-Dec-2016 13:03:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @basic_gui_OpeningFcn, ...
    'gui_OutputFcn',  @basic_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before basic_gui is made visible.
function basic_gui_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    
    % first thing is to add the path to all functions and scripts used
    % in our case all files including this file are in subdirectories of
    % MATLAB directory. For other arrangements this code might not work
    
    p = pwd;            % path to current folder '...\ImageProject\GUI'
    p = p(1:end-4);     % remove the '\GUI' at the end. Renaming this folder might make the code not work
    addpath(genpath(p));% add ImageProject folder and all its subfolders to matlab paths
    
    global im_height;
    im_height = 200;
    global im_width; 
    im_width = 200;
    data = struct('imfile','cd.jpg');
    set(handles.load,'UserData', data); %set image in the UserData field of 'Load image' button
    
    data = struct('template', 'HAW90.png');
    set(handles.template,'UserData', data);%set template image in the UserData field of 'Template' panel
    axes('Parent', handles.template); % show the template image in the template field
    imshow(imread('HAW90.png'));
    
    data = struct('template_wm', 'wm200x200.png');
    set(handles.template_wm,'UserData', data);
    axes('Parent', handles.template_wm); % show the template image in the template field
    imshow(imread('wm200x200.png'));
    
    % Choose default command line output for basic_gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes basic_gui wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    getAndUpdate(handles);

% --- Outputs from this function are returned to the command line.
function varargout = basic_gui_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;

function getAndUpdate(handles)
    data = getData(handles);   
    updatePlots(handles, data);
    
function data = getData(handles)
    
    setappdata(handles.optionspanel, 'filter_applied', false)
    setappdata(handles.optionspanel, 'options_applied', false)
    setappdata(handles.featurespanel, 'hough_circle_applied', false)
    setappdata(handles.featurespanel, 'hough_line_applied', false)
    setappdata(handles.featurespanel, 'hough_general_applied', false)
    setappdata(handles.wm, 'wm_applied', false)
    set(handles.noc,'Visible','off');
    set(handles.num_of_circles,'String', '');
    %globals 
    global im_height;
    global im_width;

    im = sampleImage(im_height,im_width);           %sampleImage object to be used through the program
    setappdata(handles.optionspanel, 'image', im);  %image data available to the whole option panel
    im.height = im_height;
    im.width = im_width;
    assignin('base', 'im', im);

    % PATTERN
    %get handles to selected pattern
    data.pattern = get(get(handles.uibuttonimage,'SelectedObject'), 'Tag'); 
    fx = str2double(get(handles.xfreq, 'String'));
    fy = str2double(get(handles.yfreq, 'String'));
    switch data.pattern % Get Tag of selected object.
        case 'horizontal_stripes'
            im.image = horizontalStripes(im, fy);
        case 'vertical_stripes'
            im.image  = verticalStripes(im, fx);
        case 'diagonal_stripes'
            im.image = diagonalStripes(im, fx, fy);
        case 'chessboard'
            im.image  = chessboard(im, fx, fy);
        case 'white_square'
            sqwidth = str2double(get(handles.sqwidth, 'String'));
            im.image  = whiteSquare(im, sqwidth);
        case 'gaussian'
            maxSigma = str2double(get(handles.maxsigma, 'String'));
            im.image  = gaussianPattern(im, maxSigma);
        case 'custom_pic'
            userData = get(handles.load, 'UserData'); % get the user data stored in Load image button
            im.image = imread(userData.imfile);       % get the custom image
            [im.height,im.width, ~] = size(im.image); % get the new size of the image
    end

    % get the data and save before any applied filters etc...
    orig = im;                  
    setappdata(handles.optionspanel, 'original_image', orig);
    orig_fft = simpleFFT(orig);
    setappdata(handles.optionspanel, 'original_image_fft', orig_fft);
    orig_h = im.height;
    orig_w = im.width;
    filter_h = orig_h;
    filter_w = orig_w;

    op = imageOperations(orig.image); % instance of class for image operations 
    
    % ROTATIONS

    data.rotation = get(get(handles.uibuttonrotations, 'SelectedObject'), 'Tag');    % get the tag of the required rotation handle
    if ~strcmp(data.rotation, 'no_rotation')  
        setappdata(handles.optionspanel, 'options_applied', true);
    end
    switch data.rotation
        case 'rotate_left'
            im.image = op.rotate90ccw();
            filter_h = orig_w;             % swap height and width after rotation
            filter_w = orig_h;
        case 'rotate_right'
            im.image = op.rotate90cw();
            filter_h = orig_w;
            filter_w = orig_h;
        case 'rotate_180'
            im.image = op.rotate180();
        case 'mirrorLR'
            im.image = op.mirrorlr();
        case 'mirrorUD'
            im.image = op.mirrorud();
        case 'no_rotation'
    end

    % Update image data after every possible operation
    im_fft = simpleFFT(im);
    setappdata(handles.optionspanel, 'image', im); %image data available to the whole option panel
    setappdata(handles.optionspanel, 'image_fft', im_fft); %image fft data available to the whole gui

    
    %CROPPING or MASKING

    data.cropping = get(get(handles.uibuttoncrop, 'SelectedObject'), 'Tag');    
    
    height_from  = str2double(get(handles.crop_h_from, 'String'));
    height_to  = str2double(get(handles.crop_h_to, 'String'));
    height = height_from:height_to;

    width_from = str2double(get(handles.crop_w_from, 'String'));
    width_to = str2double(get(handles.crop_w_to, 'String'));
    width = width_from:width_to;
    if ~strcmp(data.cropping, 'no_crop')  
        setappdata(handles.optionspanel, 'options_applied', true);
    end
    switch data.cropping
        case 'crop'
            im.image = op.crop(height, width);
        case 'mask'        
            im.image = op.maskout(height, width);
        case 'no_crop'      
    end 

    im_fft = simpleFFT(im);
    setappdata(handles.optionspanel, 'image', im); %image data available to the whole option panel
    setappdata(handles.optionspanel, 'image_fft', im_fft); %image fft data available to the whole gui

    %SHIFTING
    
    % right shift distance
    sh_r  = str2double(get(handles.shift_r, 'String'));
    
    % down shft distance
    sh_d = str2double(get(handles.shift_d, 'String'));
    
    data.shift = get(get(handles.uibuttonshift, 'SelectedObject'), 'Tag'); 

    if ~strcmp(data.shift, 'no_shift')  
        setappdata(handles.optionspanel, 'options_applied', true);
    end
    switch data.shift
        case 'shift_right'
            im.image = op.shiftRight(sh_r);
        case 'shift_down'
            im.image = op.shiftDown(sh_d);
        case 'shiftRD'
            im.image = op.shiftRightDown(sh_r, sh_d);
        case 'no_shift'
    end 

    % Update image data after every possible operation
    im_fft = simpleFFT(im);
    setappdata(handles.optionspanel, 'image', im); %image data available to the whole option panel
    setappdata(handles.optionspanel, 'image_fft', im_fft); %image fft data available to the whole gui

    % RESAMPLE 
    
    data.resample = get(get(handles.uibuttonresample, 'SelectedObject'), 'Tag');
    
    % get ratio for resampling
    ratio = str2double(get(handles.resampl_ratio, 'String'));
    if ~strcmp(data.resample, 'no_resampling')  
        setappdata(handles.optionspanel, 'options_applied', true);
    end
    switch data.resample
        case 'resample'
            if get(handles.antialias, 'Value')
               im.image = op.resample(ratio, true);
            else
               im.image = op.resample(ratio);         % 2nd param is optional, false by default
            end
            [new_h, new_w] = size(im.image);
            im.height = new_h;
            im.width = new_w;
            filter_h = new_h;
            filter_w = new_w;
        case 'no_resampling'
            set(handles.antialias, 'Value', 0)
    end

    % Update image data after every possible operation
    im_fft = simpleFFT(im);
    setappdata(handles.optionspanel, 'image', im); %image data available to the whole option panel
    setappdata(handles.optionspanel, 'image_fft', im_fft); %image fft data available to the whole gui


    %FILTERING
    %filtered image data
    % get sellected frequencies
    passf = str2double(get(handles.pass_freq, 'String'));
    setappdata(handles.uibuttonimage, 'passfreq', passf);

    stopf = str2double(get(handles.stop_freq , 'String'));
    setappdata(handles.uibuttonimage, 'stopfreq', stopf );
    
    imf=cj2Filter(filter_h, filter_w);
    assignin('base', 'imf', imf);
    % get selected filter handle
    data.filter = get(get(handles.uibuttonfilters, 'SelectedObject'), 'Tag');

    switch data.filter
        case 'high_pass'
            set(handles.stop_freq, 'Enable', 'off');
            setappdata(handles.optionspanel, 'filter_applied', true);
            % Create filter
            imf.absolute =  imf.highPass(passf);
            
            %Create filtered image
            imf_time = imf.simple_IFFT_scaled();
            im_filtered = cj2Transformation.filter(imf.absolute,im.image);
            im_filtered_fft = fft2(im_filtered);

            setappdata(handles.optionspanel, 'filter_f', imf); %image data available to the whole option panel
            setappdata(handles.optionspanel, 'filter_time', imf_time); %image fft data available to the whole gui
            setappdata(handles.optionspanel, 'image_filtered', im_filtered);
            setappdata(handles.optionspanel, 'image_filtered_fft', im_filtered_fft);

        case 'low_pass'
            set(handles.stop_freq, 'Enable', 'off');
            setappdata(handles.optionspanel, 'filter_applied', true);
            imf.absolute =  imf.lowPass(passf);

            %Create filtered image
            imf_time = simple_IFFT_scaled(imf);
            im_filtered = cj2Transformation.filter(imf.absolute,im.image);
            im_filtered_fft = fft2(im_filtered);

            setappdata(handles.optionspanel, 'filter_f', imf); %image data available to the whole option panel
            setappdata(handles.optionspanel, 'filter_time', imf_time); %image fft data available to the whole gui
            setappdata(handles.optionspanel, 'image_filtered', im_filtered);
            setappdata(handles.optionspanel, 'image_filtered_fft', im_filtered_fft);

        case 'band_pass'
            set(handles.stop_freq, 'Enable', 'on');
            if passf < stopf
                setappdata(handles.optionspanel, 'filter_applied', true);
                imf.absolute =  imf.bandPass(passf, stopf);

            elseif passf > stopf
                setappdata(handles.optionspanel, 'filter_applied', true);
                imf.absolute =  imf.bandStop(stopf, passf);
            else
                errordlg('Pass and stop frequencies cannot be the same','BP filter error');
            end
            %Create filtered image
            imf_time = simple_IFFT_scaled(imf);
            im_filtered = cj2Transformation.filter(imf.absolute,im.image);
            im_filtered_fft = fft2(im_filtered);

            setappdata(handles.optionspanel, 'filter_f', imf); %image data available to the whole option panel
            setappdata(handles.optionspanel, 'filter_time', imf_time); %image fft data available to the whole gui
            setappdata(handles.optionspanel, 'image_filtered', im_filtered);
            setappdata(handles.optionspanel, 'image_filtered_fft', im_filtered_fft);
        case 'no_filter'
            set(handles.stop_freq, 'Enable', 'off');
            setappdata(handles.optionspanel, 'filter_applied', false);
    end
    
    % Hough transform
        
    if get(handles.hough_button, 'Value');
        data.hough = get(get(handles.uibuttonhough, 'SelectedObject'), 'Tag');
        switch data.hough
            case 'line' 
                threshold = str2double(get(handles.thresh_lines, 'String')); 
                max_lines = str2double(get(handles.max_lines, 'String'));
                [imageWithLines, votingSpace, Maximus, preMaximus] = houghLines(im.image, threshold, max_lines);
                setappdata(handles.featurespanel, 'imageWithLines', imageWithLines)
                setappdata(handles.featurespanel, 'votingSpace', votingSpace)
                setappdata(handles.featurespanel, 'Maximus', Maximus)
                setappdata(handles.featurespanel, 'preMaximus', preMaximus)
                setappdata(handles.featurespanel, 'hough_line_applied', true)
            case 'circle'
                rad1 = str2double(get(handles.radius1,'String'));
                rad2 = str2double(get(handles.radius2,'String'));
                rrange = [min(rad1,rad2), max(rad1,rad2)];
                threshold = str2double(get(handles.thresh,'String'));
                steps = str2double(get(handles.step,'String'));                 
                nhoodxy = str2double(get(handles.nhxy,'String'));
                nhoodr = str2double(get(handles.nhr,'String'));
                [centers, radii, numOfCircles] = houghCircles(im.image, rrange, threshold, steps, nhoodxy, nhoodr);
                set(handles.noc,'Visible','on');
                set(handles.num_of_circles,'String',numOfCircles);
                setappdata(handles.featurespanel, 'centers', centers)
                setappdata(handles.featurespanel, 'radii', radii)
                setappdata(handles.featurespanel, 'hough_circle_applied', true)
            case 'general'
                userData = get(handles.template, 'UserData');
                templateImage = imread(userData.template);
                generalizedImage = houghGeneralized(im.image, templateImage);
                setappdata(handles.featurespanel, 'hough_general_applied', true)
                setappdata(handles.featurespanel, 'generalizedImage', generalizedImage);
                setappdata(handles.featurespanel, 'templateImage', templateImage);
        end
    end
    
    % Watermarking
    
    if get(handles.wm_button, 'Value');
        q = str2double(get(handles.q_wm_value, 'String')); 
        levels = str2double(get(handles.levels_wm_value, 'String')); 
        sigma = str2double(get(handles.sigma_wm_value, 'String')); 
        toFilter = get(handles.filter_wm, 'Value');
        toRotate = get(handles.rotate_wm, 'Value');
        degrees = str2double(get(handles.rotate_deg_wm, 'String'));
        userData = get(handles.template_wm, 'UserData');
        templateImage = imread(userData.template_wm);
        [waterMarkedImageClean, waterMarkedImage, recoveredWatermark] = waveletWatermarking(im.image, templateImage, q, levels, sigma, toFilter, toRotate, degrees);
        setappdata(handles.wm, 'waterMarkedImageClean', waterMarkedImageClean)
        setappdata(handles.wm, 'waterMarkedImage', waterMarkedImage)
        setappdata(handles.wm, 'recoveredWatermark', recoveredWatermark)
        setappdata(handles.wm, 'templateImage_wm', templateImage)
        setappdata(handles.wm, 'wm_applied', true)
    end
    
    % set the image dimensions in GUI
    set(handles.height1, 'String', im.height);
    set(handles.width1, 'String', im.width);

% plotting
function updatePlots(handles, data)
    %plotting
    orig = getappdata(handles.optionspanel, 'original_image');
    orig_fft = getappdata(handles.optionspanel, 'original_image_fft');
    [h,w,d] = size(orig.image);
    if d == 3
        orig.image = rgb2gray(orig.image);
    end    
    if h >= w       % r and c are used in subplot function where 2 images are shown
       r = 1;       % determines if the images will be displayed next to each other
       c = 2;       % or one over the other, depending on their size,
    else            % this increases visual quality
       r = 2;
       c = 1;
    end
    axes('Parent', handles.plots);      %activate plot area
    if getappdata(handles.optionspanel, 'filter_applied')
        subplot(3,2,1); % plot the original default pic in time
        imshow(uint8(orig.image));title('Original Image');
%         title(['\fontsize{16}{Spatial domain}' char(10) char(10) '\fontsize{11}{Original Image}']);
        orig_fft = getappdata(handles.optionspanel, 'original_image_fft');
        subplot(3,2,2); % plot original image in freq
        imshow(orig_fft);title('Magnitude of FFT Original');
%         title(['\fontsize{16}{Frequency domain}' char(10) char(10) '\fontsize{11}{Magnitude of FFT Original}']);
        subplot(3,2,3);
        imf_time = getappdata(handles.optionspanel, 'filter_time');
        imshow(uint8(imf_time));title('Time Domain of FFT filter');
        subplot(3,2,4);
        imf = getappdata(handles.optionspanel, 'filter_f');
        imshow(uint8(255*imf.absolute)); title('Magnitude of FFT filter');
        subplot(3,2,5);
        im_f = getappdata(handles.optionspanel, 'image_filtered');
        imshow(uint8(abs(im_f)));title('Filtered Image');
        subplot(3,2,6);
        im_f_fft = getappdata(handles.optionspanel, 'image_filtered_fft'); 
        im_f_fft = log(abs(im_f_fft) + 1); % log of the magnitude for
        im_f_fft = mat2gray(im_f_fft);    %Scale the values between 0 and 1
        imshow(uint8(255*mat2gray(im_f_fft)));title('Magnitude of Transformed FFT');
        assignin('base', 'uint8_abs_filtered', uint8(abs(im_f)));
    elseif getappdata(handles.optionspanel, 'options_applied')
        subplot(2,2,1); % plot the original default pic in time
        imshow(uint8(orig.image)); title('Original Image');
        orig_fft = getappdata(handles.optionspanel, 'original_image_fft');
        subplot(2,2,2); % plot original image in freq
        imshow(orig_fft); title('Magnitude of FFT Original');
        subplot(2,2,3)
        im = getappdata(handles.optionspanel, 'image');
        imshow(im.image);title('Modified Image');       
        subplot(2,2,4)
        im_fft = getappdata(handles.optionspanel, 'image_fft');
        imshow(uint8(255*mat2gray(abs(im_fft))));title('Magnitude of FFT Modified');
    elseif getappdata(handles.featurespanel, 'hough_circle_applied')
        subplot(r,c,1)
        imshow(orig.image);title('Original image');
        subplot(r,c,2)
        imshow(edge(orig.image,'canny'));title('Transformed image');
        centers = getappdata(handles.featurespanel, 'centers');
        radii = getappdata(handles.featurespanel, 'radii');
        viscircles(centers, radii,'EdgeColor','b');
    elseif getappdata(handles.featurespanel, 'hough_line_applied')
        subplot(3,2,1)
        imshow(orig.image);title('Original image');
        imageWithLines = getappdata(handles.featurespanel, 'imageWithLines');
        subplot(3,2,2)
        imshow(uint8(imageWithLines));title('Detected lines');
        votingSpace = getappdata(handles.featurespanel, 'votingSpace');
        subplot(3,2,3)
        imshow(uint8(votingSpace));title('Voting space');
        Maximus = getappdata(handles.featurespanel, 'Maximus');
        subplot(3,2,4)
        imshow(Maximus);title('Detected lines coordinates');
        subplot(3,2,5)
        surf(votingSpace);title('Voting space');
        preMaximus = getappdata(handles.featurespanel, 'preMaximus');
        subplot(3,2,6)
        surf(preMaximus);title('Filtered voting space');
    elseif getappdata(handles.featurespanel, 'hough_general_applied')
        subplot(r,c,1)
        imshow(uint8(orig.image));title('Original Image');
        generalizedImage = getappdata(handles.featurespanel, 'generalizedImage');
        subplot(r,c,2)
        imshow(generalizedImage);title('Output image');
    elseif getappdata(handles.wm, 'wm_applied')
        subplot(2,3,1); imshow(uint8(orig.image)); title('Host image');
        template = getappdata(handles.wm, 'templateImage_wm');
        subplot(2,3,2); imshow(uint8(template)); title('Watermark');
        wm_clean = getappdata(handles.wm, 'waterMarkedImageClean');
        subplot(2,3,3); imshow(uint8(wm_clean)); title('Watermarked image');
        wm_recovered = getappdata(handles.wm, 'recoveredWatermark');
        isFiltered = get(handles.filter_wm, 'Value');
        isRotated = get(handles.rotate_wm, 'Value');
        subplot(2,3,4); 
        if isFiltered
            wm_filtered = getappdata(handles.wm, 'waterMarkedImage');
            imshow(uint8(wm_filtered)); title('Filtered Watermarked image');
        elseif isRotated
            wm_rotated = getappdata(handles.wm, 'waterMarkedImage');
            imshow(uint8(wm_rotated)); title('Rotated Watermarked image');
        else
            delete(subplot(2,3,4));
        end
        subplot(2,3,5); imshow(uint8(wm_recovered)); title('Recovered Watermark ');
        
    else
        subplot(r,c,1); % plot the original default pic in time
        imshow(uint8(orig.image));title('Original Image');
        subplot(r,c,2); % plot original image in freq
        imshow(orig_fft);title('Magnitude of FFT Original');
    end


%----------------------------- CALLBACKS ----------------------------------

%*************************** IMAGES ***************************************

% --- Executes when selected object is changed in uibuttonimage.
function uibuttonimage_SelectionChangedFcn(hObject, eventdata, handles)
    getAndUpdate(handles);

function xfreq_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);

function yfreq_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);

function sqwidth_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);

function maxsigma_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);


%******************** ROTATIONS *******************************************

% --- Executes when selected object is changed in uibuttonrotations.
function uibuttonrotations_SelectionChangedFcn(hObject, eventdata, handles)
    set(handles.uibuttoncrop,'selectedobject',handles.no_crop);
    set(handles.uibuttonshift,'selectedobject',handles.no_shift);
    set(handles.uibuttonresample,'selectedobject',handles.no_resampling);
    getAndUpdate(handles);


%***************** CROP & MASK ********************************************

% --- Executes when selected object is changed in uibuttoncrop.
function uibuttoncrop_SelectionChangedFcn(hObject, eventdata, handles)
    set(handles.uibuttonrotations,'selectedobject',handles.no_rotation);
    set(handles.uibuttonshift,'selectedobject',handles.no_shift);
    set(handles.uibuttonresample,'selectedobject',handles.no_resampling);
    getAndUpdate(handles);

function crop_h_from_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);

function crop_w_from_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);

function crop_h_to_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);

function crop_w_to_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);


%**************************** FILTERS *************************************

% --- Executes when selected object is changed in uibuttonfilters.
function uibuttonfilters_SelectionChangedFcn(hObject, eventdata, handles)
    getAndUpdate(handles)

function pass_freq_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);

function stop_freq_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);

%*********************** SHIFTING *****************************************

% --- Executes when selected object is changed in uibuttonshift.
function uibuttonshift_SelectionChangedFcn(hObject, eventdata, handles)
    set(handles.uibuttonrotations,'selectedobject',handles.no_rotation);
    set(handles.uibuttoncrop,'selectedobject',handles.no_crop);
    set(handles.uibuttonresample,'selectedobject',handles.no_resampling);
    getAndUpdate(handles);

function shift_r_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);

function shift_d_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);


%*********************** RESAMPLING ***************************************

% --- Executes when selected object is changed in uibuttonresample.
function uibuttonresample_SelectionChangedFcn(hObject, eventdata, handles)
    set(handles.uibuttonrotations,'selectedobject',handles.no_rotation);
    set(handles.uibuttoncrop,'selectedobject',handles.no_crop);
    set(handles.uibuttonshift,'selectedobject',handles.no_shift);
    getAndUpdate(handles);

function resampl_ratio_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);

% --- Executes on button press in antialias.
function antialias_Callback(hObject, eventdata, handles)
    getAndUpdate(handles);


%********************** Image loading *************************************

function load_Callback(hObject, eventdata, handles)
    set(handles.uibuttonimage,'selectedobject',handles.custom_pic);
    [file, dir] = uigetfile();
    if file                 % othw false
        if ~isImage(file)   % function is in the last section of the script
            errordlg('Please select a valid image file extension', 'Image loading error');
            return;
        end
        data = struct('imfile',[dir, file]); %store image dir + filename
        set(handles.load,'UserData', data);
        getAndUpdate(handles);
    end
 
function load_template_Callback(hObject, eventdata, handles)
    set(handles.uibuttonhough,'selectedobject',handles.general);
    [file, dir] = uigetfile();
    if file                 % othw false
        if ~isImage(file)   % function is in the last section of the script
            errordlg('Please select a valid image file extension', 'Image loading error');
            return;
        end
        data = struct('template',[dir, file]); %store image dir + filename
        set(handles.template,'UserData', data);
        old = findobj(handles.template, 'Type','image');
        delete(old)     % delete the old template before showing the new one
        axes('Parent', handles.template); % show the template image in the template field
        imshow(imread([dir, file]));
    end
    
function load_template_wm_Callback(hObject, eventdata, handles)
    [file, dir] = uigetfile();
    if file                 % othw false
        if ~isImage(file)   % function is in the last section of the script
            errordlg('Please select a valid image file extension', 'Image loading error');
            return;
        end
        data = struct('template_wm',[dir, file]); %store image dir + filename
        set(handles.template_wm,'UserData', data);
        old = findobj(handles.template_wm, 'Type','image');
        delete(old)     % delete the old template before showing the new one
        axes('Parent', handles.template_wm);
        imshow(imread([dir, file]));
    end
    
%********************** Hough - Circle ************************************

% --- Executes on button press in hough_button.
function hough_button_Callback(hObject, eventdata, handles)
    set(handles.uibuttonrotations,'selectedobject',handles.no_rotation);
    set(handles.uibuttoncrop,'selectedobject',handles.no_crop);
    set(handles.uibuttonshift,'selectedobject',handles.no_shift);
    set(handles.uibuttonresample,'selectedobject',handles.no_resampling);
    set(handles.uibuttonfilters,'selectedobject',handles.no_filter);
    getAndUpdate(handles);

function lines_thresh_slider_Callback(hObject, eventdata, handles)    
    val = get(hObject, 'Value');
    val = round((val*100))*0.01;
    set(handles.thresh_lines, 'String', val);
    
% --- Executes on slider movement.
function thresh_slider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    val = get(hObject, 'Value');
    val = round((val*100))*0.01;
    set(handles.thresh, 'String', val);
    
function step_slider_Callback(hObject, eventdata, handles)
    val = round(get(hObject, 'Value'));
    set(handles.step, 'String', val);
    set(handles.nhr_slider, 'Max', val);
    if val < get(handles.nhr_slider, 'Value');
       set(handles.nhr_slider, 'Value', val);
       set(handles.nhr, 'String', val);
    end

function nhxy_slider_Callback(hObject, eventdata, handles)
    set(handles.nhxy, 'String', round(get(hObject, 'Value')));

function nhr_slider_Callback(hObject, eventdata, handles)
    set(handles.nhr, 'String', round(get(hObject, 'Value')));
    

%********************* Watermarking ***************************************
function wm_button_Callback(hObject, eventdata, handles)
    set(handles.uibuttonrotations,'selectedobject',handles.no_rotation);
    set(handles.uibuttoncrop,'selectedobject',handles.no_crop);
    set(handles.uibuttonshift,'selectedobject',handles.no_shift);
    set(handles.uibuttonresample,'selectedobject',handles.no_resampling);
    set(handles.uibuttonfilters,'selectedobject',handles.no_filter);
    getAndUpdate(handles);
    
function q_wm_Callback(hObject, eventdata, handles)
    val = get(hObject, 'Value');
    val = round((val*100))*0.01;
    set(handles.q_wm_value, 'String', val);  
  
function levels_wm_Callback(hObject, eventdata, handles)
    val = get(hObject, 'Value');
    val = round(val);
    set(handles.levels_wm_value, 'String', val);

function sigma_wm_Callback(hObject, eventdata, handles)
    val = get(hObject, 'Value');
    val = round((val*10))*0.1;
    set(handles.sigma_wm_value, 'String', val);
    
function filter_wm_Callback(hObject, eventdata, handles)  
    set(handles.rotate_wm, 'Value', false);
function rotate_wm_Callback(hObject, eventdata, handles) 
    set(handles.filter_wm, 'Value', false);    
  

%<<<<<<<<<<<<<<<<<<<<<< Help functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function isimage = isImage(file)
    isimage = false;
    extension = {'jpg','jpeg','png','tif','tiff','gif'};
    [~,~,ext] = fileparts(file);    %ext is for example '.jpg'
    if find(ismember(extension, ext(2:end)))
        isimage = true;
    end
