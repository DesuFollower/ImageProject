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

% Last Modified by GUIDE v2.5 21-Nov-2016 14:37:23

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
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to basic_gui (see VARARGIN)
    
    % first thing is to add the path to all functions and scripts used
    %in our case all files including this file are in subdirectories of
    %MATLAB directory. For other arrangements this code might not work
    p = path;
    pa = p(1:3);    % pa is the main dir,e.g. 'C:\'
    i = strfind(path,pa);   % take the second appearance
    addpath(genpath(p(1:i(2)-2)));  %add all subfolders to matlab paths
    
    global im_height;
    im_height = 200;
    global im_width; 
    im_width = 200;
    setappdata(handles.optionspanel, 'load', false);
    data = struct('loaded',0);
    set(handles.load,'UserData', data);

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
    data = getData(handles);        assignin('base','data',data);
    updatePlots(handles, data);
function data = getData(handles)
    
    setappdata(handles.optionspanel, 'filter_applied', false)
    setappdata(handles.optionspanel, 'options_applied', false)
    setappdata(handles.featurespanel, 'hough_circle_applied', false)
    setappdata(handles.featurespanel, 'hough_line_applied', false)
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
    userData = get(handles.load, 'UserData');
    assignin('base','value',userData);
    if userData.loaded         %if image is loaded from disk
        im.image = imread(userData.file);
        [im.height,im.width, ~] = size(im.image); % get the new size of the image
        setappdata(handles.optionspanel, 'load', true);% make it new custom image
    else
        data.pattern = get(get(handles.uibuttonimage,'SelectedObject'), 'Tag'); 
        if ~strcmp(data.pattern, 'custom_pic')  %if it's not a custom pic
            set(handles.load, 'Enable', 'off'); %disable the load button
        end
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
                if getappdata(handles.optionspanel, 'load')
                    im.image = imread(userData.file);
                else
%                   im.image = imread('http://www.doc.gold.ac.uk/~mas02fl/MSC101/ImageProcess/defect03_files/fig_2_3_14.jpg');
                    im.image = imread('cd.jpg');
                end
                [im.height,im.width, ~] = size(im.image); % get the new size of the image
                set(handles.load, 'Enable', 'on');  % activate Load image button to load custom image from disk
        end
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
                [imageWithLines, votingSpace, Maximus, preMaximus] = houghLines(im.image);
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
        end
    end
    
    % set the image dimensions in GUI
    set(handles.height1, 'String', im.height);
    set(handles.width1, 'String', im.width);

% plotting
function updatePlots(handles, data)
    %plotting
    orig = getappdata(handles.optionspanel, 'original_image');
    orig_fft = getappdata(handles.optionspanel, 'original_image_fft');
    [~,~,d] = size(orig.image);
    if d == 3
        orig.image = rgb2gray(orig.image);
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
        subplot(1,2,1)
        imshow(orig.image);title('Original image');
        subplot(1,2,2)
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
    else
        subplot(1,2,1); % plot the original default pic in time
        imshow(uint8(orig.image));title('Original Image');
        subplot(1,2,2); % plot original image in freq
        imshow(orig_fft);title('Magnitude of FFT Original');
    end


%----------------------------- CALLBACKS ----------------------------------

%*************************** IMAGES ***************************************

% --- Executes when selected object is changed in uibuttonimage.
function uibuttonimage_SelectionChangedFcn(hObject, eventdata, handles)
    % hObject    handle to the selected object in uibuttonimage
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    userData = get(handles.load, 'UserData');
    userData.loaded = 0;
    set(handles.load, 'UserData', userData);
    getAndUpdate(handles);

function xfreq_Callback(hObject, eventdata, handles)
getAndUpdate(handles);

function yfreq_Callback(hObject, eventdata, handles)
getAndUpdate(handles);

function sqwidth_Callback(hObject, eventdata, handles)
getAndUpdate(handles);

function maxsigma_Callback(hObject, eventdata, handles)
getAndUpdate(handles);

%the following callbacks muct exist although they do nothing
function horizontal_stripes_Callback(hObject, eventdata, handles)
function vertical_stripes_Callback(hObject, eventdata, handles)
function diagonal_stripes_Callback(hObject, eventdata, handles)
function chessboard_Callback(hObject, eventdata, handles)
function white_square_Callback(hObject, eventdata, handles)
function gaussian_Callback(hObject, eventdata, handles)
function custom_pic_Callback(hObject, eventdata, handles)

%******************** ROTATIONS *******************************************

% --- Executes when selected object is changed in uibuttonrotations.
function uibuttonrotations_SelectionChangedFcn(hObject, eventdata, handles)
set(handles.uibuttoncrop,'selectedobject',handles.no_crop);
set(handles.uibuttonshift,'selectedobject',handles.no_shift);
set(handles.uibuttonresample,'selectedobject',handles.no_resampling);
getAndUpdate(handles);

function rotate_right_Callback(hObject, eventdata, handles)
function rotate_left_Callback(hObject, eventdata, handles)
function rotate_180_Callback(hObject, eventdata, handles)
function mirrorLR_Callback(hObject, eventdata, handles)
function mirrorUD_Callback(hObject, eventdata, handles)
function no_rotation_Callback(hObject, eventdata, handles)

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

function crop_Callback(hObject, eventdata, handles)
function mask_Callback(hObject, eventdata, handles)
function no_crop_Callback(hObject, eventdata, handles)

%**************************** FILTERS *************************************

% --- Executes when selected object is changed in uibuttonfilters.
function uibuttonfilters_SelectionChangedFcn(hObject, eventdata, handles)
getAndUpdate(handles)

function pass_freq_Callback(hObject, eventdata, handles)
getAndUpdate(handles);

function stop_freq_Callback(hObject, eventdata, handles)
getAndUpdate(handles);

function low_pass_Callback(hObject, eventdata, handles)
function high_pass_Callback(hObject, eventdata, handles)
function band_pass_Callback(hObject, eventdata, handles)
function no_filter_Callback(hObject, eventdata, handles)

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

function shift_right_Callback(hObject, eventdata, handles)
function shift_down_Callback(hObject, eventdata, handles)
function shiftRD_Callback(hObject, eventdata, handles)
function no_shift_Callback(hObject, eventdata, handles)

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

function resample_Callback(hObject, eventdata, handles)
function no_resampling_Callback(hObject, eventdata, handles)

%********************** Image loading *************************************

function load_Callback(hObject, eventdata, handles)
    [file, dir] = uigetfile();
    if file
        if ~isImage(file)
            errordlg('Please select a valid image file extension', 'Image loading error');
            return;
        end
        data = struct('file',[dir, file],'loaded',1);
        set(handles.load,'UserData', data);
        getAndUpdate(handles);
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
    
function radius1_Callback(hObject, eventdata, handles)  
function radius2_Callback(hObject, eventdata, handles) 
    
%----------------------- CREATE FUNCTIONS ---------------------------------

% !!! must exist otherwise program gives errors !!!
% --- Executes during object creation, after setting all properties.
function uibuttonimage_CreateFcn(hObject, eventdata, handles)
function xfreq_CreateFcn(hObject, eventdata, handles)
function yfreq_CreateFcn(hObject, eventdata, handles)
function sqwidth_CreateFcn(hObject, eventdata, handles)
function maxsigma_CreateFcn(hObject, eventdata, handles)
function horizontal_stripes_CreateFcn(hObject, eventdata, handles)
function pass_freq_CreateFcn(hObject, eventdata, handles)
function stop_freq_CreateFcn(hObject, eventdata, handles)
function crop_h_from_CreateFcn(hObject, eventdata, handles)
function crop_w_from_CreateFcn(hObject, eventdata, handles)
function resampl_ratio_CreateFcn(hObject, eventdata, handles)
function shift_r_CreateFcn(hObject, eventdata, handles)
function shift_d_CreateFcn(hObject, eventdata, handles)
function crop_h_to_CreateFcn(hObject, eventdata, handles)
function crop_w_to_CreateFcn(hObject, eventdata, handles)
function thresh_slider_CreateFcn(hObject, eventdata, handles)
function step_slider_CreateFcn(hObject, eventdata, handles)
function nhxy_slider_CreateFcn(hObject, eventdata, handles)
function nhr_slider_CreateFcn(hObject, eventdata, handles)
function load_CreateFcn(hObject, eventdata, handles)
function radius1_CreateFcn(hObject, eventdata, handles)
function radius2_CreateFcn(hObject, eventdata, handles)

%------------------------ Key loaded functions for edit boxes -------------
function xfreq_KeyPressFcn(hObject, eventdata, handles)
function yfreq_KeyPressFcn(hObject, eventdata, handles)
function sqwidth_KeyPressFcn(hObject, eventdata, handles)
function maxsigma_KeyPressFcn(hObject, eventdata, handles)
function pass_freq_KeyPressFcn(hObject, eventdata, handles)
function stop_freq_KeyPressFcn(hObject, eventdata, handles)
function crop_h_from_KeyPressFcn(hObject, eventdata, handles)
function crop_w_from_KeyPressFcn(hObject, eventdata, handles)
function crop_h_to_KeyPressFcn(hObject, eventdata, handles)
function crop_w_to_KeyPressFcn(hObject, eventdata, handles)
function shift_r_KeyPressFcn(hObject, eventdata, handles)
function shift_d_KeyPressFcn(hObject, eventdata, handles)
function resampl_ratio_KeyPressFcn(hObject, eventdata, handles)


%<<<<<<<<<<<<<<<<<<<<<< Help functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function isimage = isImage(file)
    isimage = false;
    extension = {'jpg','jpeg','png','tif','tiff','gif'};
    [~,~,ext] = fileparts(file);    %ext is for example '.jpg'
    if find(ismember(extension, ext(2:end)))
        isimage = true;
    end