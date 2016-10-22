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

% Last Modified by GUIDE v2.5 22-Oct-2016 02:23:17

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
set(handles.uibuttonimage,'selectedobject',handles.horizontal_stripes);
set(handles.uibuttonfilters,'selectedobject',handles.no_filter);
set(handles.uibuttonrotations,'selectedobject',handles.no_rotation);

global im_height;
im_height = 200;
global im_width; 
im_width = 200;
original = sampleImage(im_height,im_width); %original image for reset functionality
setappdata(handles.optionspanel, 'original_image', original); %image data available to the whole option panel
im = sampleImage(im_height,im_width); %sampleImage object to be used through the program
setappdata(handles.optionspanel, 'image', im); %image data available to the whole option panel
filter = cj2Filter(im_height,im_width); %filter in frequency
setappdata(handles.optionspanel, 'filter_f', filter);
im_f = sampleImage(im_height,im_width); %sampleImage object for the filtered image
setappdata(handles.optionspanel, 'image_filtered', im_f); %image data available to the whole option panel
setappdata(handles.optionspanel, 'filter_applied', false)

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

% --- Executes when selected object is changed in uibuttonimage.
function uibuttonimage_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttonimage
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

getAndUpdate(handles);


function getAndUpdate(handles)
data = getData(handles);
updatePlots(handles, data);
function data = getData(handles);
%globals 
global im_height;
global im_width;

%get original image
im = getappdata(handles.optionspanel, 'image');
assignin('base', 'im', im);
imf = getappdata(handles.optionspanel, 'filter_f');
assignin('base', 'im_f', imf);
im_filtered = getappdata(handles.optionspanel, 'image_filtered');
assignin('base', 'im_filtered', im_filtered);

% get frequency data
fx = str2double(get(handles.xfreq, 'String'));
setappdata(handles.uibuttonimage, 'imagexfreq', fx);

fy = str2double(get(handles.yfreq, 'String'));
assignin('base', 'yf', fy); % show variable in workspace for debug
setappdata(handles.uibuttonimage, 'imageyfreq', fy);

%get square and sigma values
sqwidth = str2double(get(handles.sqwidth, 'String'));
setappdata(handles.uibuttonimage, 'squareWidth', sqwidth);

maxSigma = str2double(get(handles.maxsigma, 'String'));
setappdata(handles.uibuttonimage, 'squareWidth', maxSigma);

%get handles to selected pattern
h = get(handles.uibuttonimage,'SelectedObject');
assignin('base', 'h', h);
data.pattern = get(h,'Tag');

% Change image size if nt custom
if ~strcmp(data.pattern,'custom_pic')
    % agree size of original with the new size of the image and save the
       % data when not using custom image
       reset_size = sampleImage(im_height,im_width);
        im = reset_size;
         im_filtered = reset_size; 
         imf =  cj2Filter(im_height,im_width);
        setappdata(handles.optionspanel, 'image', im); %image data available to the whole option panel
        setappdata(handles.optionspanel, 'filter_f', imf); %image data available to the whole option panel
        setappdata(handles.optionspanel, 'image_filtered', im_filtered);
        
end

% PATTERN

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
        im.image  = whiteSquare(im, sqwidth);
        
    case 'gaussian'
        im.image  = gaussianPattern(im, maxSigma);
    case 'custom_pic'
        image = rgb2gray(imread('http://www.doc.gold.ac.uk/~mas02fl/MSC101/ImageProcess/defect03_files/fig_2_3_14.jpg'));
       % agree size of original with the new size of the image and save the
       % data
        [im.height,im.width] = size(image); 
        [imf.height,imf.width] = size(image); 
        [im_filtered.height,im_filtered.width] = size(image);
        im.image = image;
        imf.absolute = image;
        im.image = image;
        
        setappdata(handles.optionspanel, 'filter_f', imf); %image data available to the whole option panel
        setappdata(handles.optionspanel, 'image_filtered', im_filtered);

end

% Update image data after every possible operation
im_fft = simpleFFT(im);
setappdata(handles.optionspanel, 'image', im); %image data available to the whole option panel
setappdata(handles.optionspanel, 'image_fft', im_fft); %image fft data available to the whole gui

orig = getappdata(handles.optionspanel, 'image'); % get the data and save before any applied filters etc...
setappdata(handles.optionspanel, 'original_image', orig);

% ROTATIONS

op = imageOperations(im.image); % used for cropping, masking etc

h = get(handles.uibuttonrotations, 'SelectedObject');% get the required rotation handle
data.rotation = get(h, 'Tag');    % get the tag
switch data.rotation
    case 'rotate_left'
        im.image = op.rotate90cw();
    case 'rotate_right'
        im.image = op.rotate90ccw();
    case 'rotate_180'
        im.image = op.rotate180();
    case 'mirrorLR'
        im.image = op.mirrorlr();
    case 'mirrorUD'
        im.image = op.mirrorud();
    case 'no_rotation'
        % do nothing 
end

% Update image data after every possible operation
im_fft = simpleFFT(im);
setappdata(handles.optionspanel, 'image', im); %image data available to the whole option panel
setappdata(handles.optionspanel, 'image_fft', im_fft); %image fft data available to the whole gui

% SHIFTING + RESAMPLE
h = get(handles.uibuttonother, 'SelectedObject');% get the required rotation handle
data.shift = get(h, 'Tag');    % get the tag

% right shift distance
sh_r  = str2double(get(handles.shift_r, 'String'));
setappdata(handles.uibuttoncrop, 'shift_right', sh_r);
% down shft distance
sh_d = str2double(get(handles.shift_d, 'String'));
setappdata(handles.uibuttoncrop, 'shift_down', sh_d);
% get ratio for resampling
ratio = str2double(get(handles.resampl_ratio, 'String'));
setappdata(handles.uibuttoncrop, 'resample_ratio', ratio);

%Switch for the shift radiobutons
switch data.shift
    case 'shift_right'
        im.image = op.shiftRight(sh_r);
    case 'shift_down'
        im.image = op.shiftDown(sh_d);
    case 'shiftRD'
        im.image = op.shiftRightDown(sh_r, sh_d);
    case 'no_shift'
        % do nothing
    otherwise
        %do nothing
end 

% Update image data after every possible operation
im_fft = simpleFFT(im);
setappdata(handles.optionspanel, 'image', im); %image data available to the whole option panel
setappdata(handles.optionspanel, 'image_fft', im_fft); %image fft data available to the whole gui

if get(handles.resample, 'Value')
    if get(handles.antialias, 'Value')
           im.image = op.resample(ratio, true);
    else
           im.image = op.resample(ratio);         % 2nd param is optional, false by default
    end
end

% Update image data after every possible operation
im_fft = simpleFFT(im);
setappdata(handles.optionspanel, 'image', im); %image data available to the whole option panel
setappdata(handles.optionspanel, 'image_fft', im_fft); %image fft data available to the whole gui

%CROPPING or MASKING

h = get(handles.uibuttoncrop, 'SelectedObject');% get the required rotation handle
data.cropping = get(h, 'Tag');    % get the tag
height  = str2double(get(handles.crop_h, 'String'));
setappdata(handles.uibuttoncrop, 'crop_height', height);

width = str2double(get(handles.crop_h, 'String'));
setappdata(handles.uibuttoncrop, 'crop_width', width);

switch data.cropping
    case 'crop'
        im.image = op.crop(height, width);
    case 'mask'        
        im.image = op.maskout(height, width);
    case 'none'
        im.image = orig.image;        
end 

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

% get selected filter handle
h = get(handles.uibuttonfilters, 'SelectedObject'); % get the required filter handle
data.filter = get(h, 'Tag');    % get the tag

switch data.filter
    case 'high_pass'
        setappdata(handles.optionspanel, 'filter_applied', true);
        % Create filter
        imf.absolute =  highPass(imf, passf);
        
        %Create filtered image
        imf_time = simple_IFFT_scaled(imf);
        im_filtered.image = cj2Transformation.filter(imf.absolute,im.image);
        im_filtered_fft = fft2(im_filtered.image);
        
        setappdata(handles.optionspanel, 'filter_f', imf); %image data available to the whole option panel
        setappdata(handles.optionspanel, 'filter_time', imf_time); %image fft data available to the whole gui
        setappdata(handles.optionspanel, 'image_filtered', im_filtered);
        setappdata(handles.optionspanel, 'image_filtered_fft', im_filtered_fft);
        
    case 'low_pass'
        setappdata(handles.optionspanel, 'filter_applied', true);
        imf.absolute =  lowPass(imf, passf);
        
        %Create filtered image
        imf_time = simple_IFFT_scaled(imf);
        im_filtered.image = cj2Transformation.filter(imf.absolute,im.image);
        im_filtered_fft = fft2(im_filtered.image);
        
        setappdata(handles.optionspanel, 'filter_f', imf); %image data available to the whole option panel
        setappdata(handles.optionspanel, 'filter_time', imf_time); %image fft data available to the whole gui
        setappdata(handles.optionspanel, 'image_filtered', im_filtered);
        setappdata(handles.optionspanel, 'image_filtered_fft', im_filtered_fft);
        
    case 'band_pass'
        if passf < stopf
            setappdata(handles.optionspanel, 'filter_applied', true);
            imf.absolute =  bandPass(imf, passf, stopf);
            
        elseif passf > stopf
            setappdata(handles.optionspanel, 'filter_applied', true);
            imf.absolute =  bandStop(imf, stopf, passf);
        else
            errordlg('Pass and stop frequencies cannot be the same','BP filter error');
        end
        %Create filtered image
        imf_time = simple_IFFT_scaled(imf);
        im_filtered.image = cj2Transformation.filter(imf.absolute,im.image);
        im_filtered_fft = fft2(im_filtered.image);
        
        setappdata(handles.optionspanel, 'filter_f', imf); %image data available to the whole option panel
        setappdata(handles.optionspanel, 'filter_time', imf_time); %image fft data available to the whole gui
        setappdata(handles.optionspanel, 'image_filtered', im_filtered);
        setappdata(handles.optionspanel, 'image_filtered_fft', im_filtered_fft);
    case 'no_filter'
        setappdata(handles.optionspanel, 'filter_applied', false);
        
        
end


% plotting
function updatePlots(handles, data)
%plotting
im = getappdata(handles.optionspanel, 'image');
subplot(2,3,1, 'Parent', handles.plots); % plot the original default pic in time
imshow(uint8(im.image));
title('Original Image');

im_fft = getappdata(handles.optionspanel, 'image_fft');
subplot(2,3,4, 'Parent', handles.plots); % plot original image in freq
imshow(im_fft);
title('Magnitude of FFT Original');

if getappdata(handles.optionspanel, 'filter_applied')
    subplot(2,3,2, 'Parent', handles.plots);
    imf_time = getappdata(handles.optionspanel, 'filter_time'); %image fft data available to the whole gui
    imshow(uint8(imf_time));
    title('Time Domain of FFT filter');
    
    subplot(2,3,5, 'Parent', handles.plots);
    imf =  getappdata(handles.optionspanel, 'filter_f'); %image data available to the whole option panel
    imshow(uint8(255*imf.absolute));
    title('Magnitude of FFT filter');
    
    subplot(2,3,3, 'Parent', handles.plots);
    im_f =  getappdata(handles.optionspanel, 'image_filtered'); %image data available to the whole option panel
    imshow(uint8(255*mat2gray(abs(im_f.image))));
    title('Filtered Image');
    
    subplot(2,3,6, 'Parent', handles.plots);
    im_f_fft =  getappdata(handles.optionspanel, 'image_filtered_fft'); %image data available to the whole option panel
    im_f_fft =  log(abs(im_f_fft) + 1); % log of the magnitude for
    im_f_fft = mat2gray(im_f_fft);    %Scale the values between 0 and 1
    imshow(uint8(255*mat2gray(im_f_fft)));
    title('Magnitude of Transformed FFT');
    
else
    delete(subplot(2,3,2, 'Parent', handles.plots));
    delete(subplot(2,3,5, 'Parent', handles.plots));
    delete(subplot(2,3,3, 'Parent', handles.plots));
    delete(subplot(2,3,6, 'Parent', handles.plots));
    
end



% --- Executes during object creation, after setting all properties.
function horizontal_stripes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to horizontal_stripes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function uibuttonimage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttonimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% --- Executes during object creation, after setting all properties.

function xfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to horizontal_stripes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function stop_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to horizontal_stripes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function pass_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to horizontal_stripes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function maxsigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to horizontal_stripes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function sqwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to horizontal_stripes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function yfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to horizontal_stripes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in rotate_left.
function rotate_left_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotate_left

function yfreq_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotate_left
getAndUpdate(handles);

function sqwidth_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotate_left
getAndUpdate(handles);

function maxsigma_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotate_left
getAndUpdate(handles);




function xfreq_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotate_left
getAndUpdate(handles);



function pass_freq_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotate_left
getAndUpdate(handles);


function stop_freq_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotate_left
getAndUpdate(handles);

function vertical_stripes_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotate_left

function horizontal_stripes_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotate_left

function white_square_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotate_left


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over xfreq.
function xfreq_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to xfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when selected object is changed in uibuttonfilters.
function uibuttonfilters_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttonfilters
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

getAndUpdate(handles)


% --- Executes on key press with focus on xfreq and none of its controls.
function xfreq_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to xfreq (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
getAndUpdate(handles);


% --- Executes on key press with focus on yfreq and none of its controls.
function yfreq_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to yfreq (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
getAndUpdate(handles);


% --- Executes when selected object is changed in uibuttonother.
function uibuttonother_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttonother
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
getAndUpdate(handles);


% --- Executes when selected object is changed in uibuttonrotations.
function uibuttonrotations_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttonrotations
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
getAndUpdate(handles);



function crop_h_Callback(hObject, eventdata, handles)
% hObject    handle to crop_h (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of crop_h as text
%        str2double(get(hObject,'String')) returns contents of crop_h as a double


% --- Executes during object creation, after setting all properties.
function crop_h_CreateFcn(hObject, eventdata, handles)
% hObject    handle to crop_h (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function crop_w_Callback(hObject, eventdata, handles)
% hObject    handle to crop_w (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of crop_w as text
%        str2double(get(hObject,'String')) returns contents of crop_w as a double


% --- Executes during object creation, after setting all properties.
function crop_w_CreateFcn(hObject, eventdata, handles)
% hObject    handle to crop_w (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in mask.
function mask_Callback(hObject, eventdata, handles)
% hObject    handle to mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mask


% --- Executes on button press in resample.
function resample_Callback(hObject, eventdata, handles)
% hObject    handle to resample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of resample



function resampl_ratio_Callback(hObject, eventdata, handles)
% hObject    handle to resampl_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resampl_ratio as text
%        str2double(get(hObject,'String')) returns contents of resampl_ratio as a double


% --- Executes during object creation, after setting all properties.
function resampl_ratio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resampl_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in antialias.
function antialias_Callback(hObject, eventdata, handles)
% hObject    handle to antialias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of antialias



function shift_r_Callback(hObject, eventdata, handles)
% hObject    handle to shift_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shift_r as text
%        str2double(get(hObject,'String')) returns contents of shift_r as a double


% --- Executes during object creation, after setting all properties.
function shift_r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function shift_d_Callback(hObject, eventdata, handles)
% hObject    handle to shift_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shift_d as text
%        str2double(get(hObject,'String')) returns contents of shift_d as a double


% --- Executes during object creation, after setting all properties.
function shift_d_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in shift_right.
function shift_right_Callback(hObject, eventdata, handles)
% hObject    handle to shift_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shift_right


% --- Executes on button press in crop.
function crop_Callback(hObject, eventdata, handles)
% hObject    handle to crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of crop


% --- Executes on key press with focus on crop_h and none of its controls.
function crop_h_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to crop_h (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
getAndUpdate(handles);


% --- Executes on key press with focus on crop_w and none of its controls.
function crop_w_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to crop_w (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
getAndUpdate(handles);


% --- Executes on key press with focus on shift_d and none of its controls.
function shift_d_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to shift_d (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
getAndUpdate(handles);


% --- Executes on key press with focus on resampl_ratio and none of its controls.
function resampl_ratio_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to resampl_ratio (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
getAndUpdate(handles);


% --- Executes on key press with focus on shift_r and none of its controls.
function shift_r_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to shift_r (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
getAndUpdate(handles);


% --- Executes when selected object is changed in uibuttoncrop.
function uibuttoncrop_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttoncrop 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
getAndUpdate(handles);
