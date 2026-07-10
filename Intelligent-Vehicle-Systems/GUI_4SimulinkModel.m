function varargout = GUI_4SimulinkModel(varargin)
% GUI_4SimulinkModel MATLAB code for GUI_4SimulinkModel.fig
%      GUI_4SimulinkModel, by itself, creates a new GUI_4SimulinkModel or raises the existing
%      singleton*.
%
%      H = GUI_4SimulinkModel returns the handle to a new GUI_4SimulinkModel or the handle to
%      the existing singleton*.
%
%      GUI_4SimulinkModel('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_4SimulinkModel.M with the given input arguments.
%
%      GUI_4SimulinkModel('Property','Value',...) creates a new GUI_4SimulinkModel or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI_4SimulinkModel before GUI_4SimulinkModel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_4SimulinkModel_OpeningFcn via varargin.
%
%      *See GUI_4SimulinkModel Options on GUIDE's Tools menu.  Choose "GUI_4SimulinkModel allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_4SimulinkModel

% Last Modified by GUIDE v2.5 19-Jul-2024 14:54:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_4SimulinkModel_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_4SimulinkModel_OutputFcn, ...
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


% --- Executes just before GUI_4SimulinkModel is made visible.
function GUI_4SimulinkModel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_4SimulinkModel (see VARARGIN)

% Choose default command line output for GUI_4SimulinkModel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes GUI_4SimulinkModel wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_4SimulinkModel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%%___________________________________________________________________________________________________

% --- Executes on slider movement.
function AccelSlider_Callback(hObject, eventdata, handles)
% hObject    handle to AccelSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

AccelSliderInput = get(handles.AccelSlider,'Value'); 
set(handles.AccelPdlVal,'string',num2str(AccelSliderInput));
assignin('base','AccelPdlInput',AccelSliderInput);
set_param('FinalProjectModel','SimulationCommand','Update'); 

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function AccelSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AccelSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'Value',0);
AccelSlider_IV = get(hObject,'Value');
assignin('base','AccelPdlInput',AccelSlider_IV);


% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function BrakePdlSlider_Callback(hObject, eventdata, handles)
% hObject    handle to BrakePdlSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BrakeSliderInput = get(handles.BrakePdlSlider,'Value'); 
set(handles.BrkPdlVal,'string',num2str(BrakeSliderInput));
assignin('base','BrkPdlInput',BrakeSliderInput);
set_param('FinalProjectModel','SimulationCommand','Update'); 

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function BrakePdlSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BrakePdlSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


set(hObject,'Value',100);
BrakePdlSlider_IV = get(hObject,'Value');
assignin('base','BrkPdlInput',BrakePdlSlider_IV);


% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function AuthKey_Callback(hObject, eventdata, handles)
% hObject    handle to AuthKey (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%AuthKey_Input = str2double(get(handles.AuthKey,'string')); 

AuthKeyInput =str2num(get(handles.AuthKey,'String')); 
assignin('base','AuthKeyInput',AuthKeyInput);
set_param('FinalProjectModel','SimulationCommand','Update'); 

ObjectDistance = str2num(get(handles.DistFromObjct,'String')); 
ObjectDetectionInput =str2num(get(handles.ObjectDetection,'String'));

%Set Auto Braking Status in GUI
if ObjectDistance < 3 && AuthKeyInput == 9245 && ObjectDetectionInput == 1
    set(handles.AutoBrakeTxt,'string','Auto Brake Active');
    set(handles.AutoBrakeTxt,'Background',[1 0.07 0]);
    
else
    set(handles.AutoBrakeTxt,'string','Auto Brake Inactive');
    set(handles.AutoBrakeTxt,'Background',[0.3922 0.8314 0.0745]);
end

% Hints: get(hObject,'String') returns contents of AuthKey as text
%        str2double(get(hObject,'String')) returns contents of AuthKey as a double


% --- Executes during object creation, after setting all properties.
function AuthKey_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AuthKey (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'Value',0);
set(hObject,'String','0')
AuthKeyIV = get(hObject,'Value');
assignin('base','AuthKeyInput',AuthKeyIV);


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ObjectDetection_Callback(hObject, eventdata, handles)
% hObject    handle to ObjectDetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ObjectDetectionInput =str2num(get(handles.ObjectDetection,'String')); 
assignin('base','ObjectDetectionInput',ObjectDetectionInput);
set_param('FinalProjectModel','SimulationCommand','Update');

ObjectDistance = str2num(get(handles.DistFromObjct,'String')); 
AuthKeyInput =str2num(get(handles.AuthKey,'String')); 

%Set Auto Braking Status in GUI
if ObjectDistance < 3 && AuthKeyInput == 9245 && ObjectDetectionInput == 1
    set(handles.AutoBrakeTxt,'string','Auto Brake Active');
    set(handles.AutoBrakeTxt,'Background',[1 0.07 0]);
    
else
    set(handles.AutoBrakeTxt,'string','Auto Brake Inactive');
    set(handles.AutoBrakeTxt,'Background',[0.3922 0.8314 0.0745]);
end

% Hints: get(hObject,'String') returns contents of ObjectDetection as text
%        str2double(get(hObject,'String')) returns contents of ObjectDetection as a double


% --- Executes during object creation, after setting all properties.
function ObjectDetection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ObjectDetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


set(hObject,'Value',0);
set(hObject,'String','0');
OD_IV = get(hObject,'Value');
assignin('base','ObjectDetectionInput',OD_IV);


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BrakePdlValueDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to BrakePdlValueDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BrakePdlValueDisplay as text
%        str2double(get(hObject,'String')) returns contents of BrakePdlValueDisplay as a double


% --- Executes during object creation, after setting all properties.
function BrakePdlValueDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BrakePdlValueDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AccelPedalValueDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to AccelPedalValueDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayValue = get(handles.AccelSlider,'Value');
set(handles.AccelPedalValueDisplay,'String',num2str(AccelPdlInput)); 

% Hints: get(hObject,'String') returns contents of AccelPedalValueDisplay as text
%        str2double(get(hObject,'String')) returns contents of AccelPedalValueDisplay as a double


% --- Executes during object creation, after setting all properties.
function AccelPedalValueDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AccelPedalValueDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'String',num2str(0)); 

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Open the model and start the simulation: 

% --- Executes on button press in RunSimulation.
function RunSimulation_Callback(hObject, eventdata, handles)
% hObject    handle to RunSimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
open_system("FinalProjectModel");
set_param('FinalProjectModel','SimulationCommand','start')

% --- Executes on button press in StopSimulation.
function StopSimulation_Callback(hObject, eventdata, handles)
% hObject    handle to StopSimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_param('FinalProjectModel','SimulationCommand','stop')



function DistFromObjct_Callback(hObject, eventdata, handles)
% hObject    handle to DistFromObjct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DistFromObjct as text
%        str2double(get(hObject,'String')) returns contents of DistFromObjct as a double
ObjectDistance = str2num(get(handles.DistFromObjct,'String')); 
assignin('base','DistanceFromObject',ObjectDistance);
set_param('FinalProjectModel','SimulationCommand','Update'); 

AuthKeyInput =str2num(get(handles.AuthKey,'String')); 
ObjectDetectionInput =str2num(get(handles.ObjectDetection,'String')); 

%Set Auto Braking Status in GUI
if ObjectDistance < 3 && AuthKeyInput == 9245 && ObjectDetectionInput == 1
    set(handles.AutoBrakeTxt,'string','Auto Brake Active');
    set(handles.AutoBrakeTxt,'Background',[1 0.07 0]);
else
    set(handles.AutoBrakeTxt,'string','Auto Brake Inactive');
    set(handles.AutoBrakeTxt,'Background',[0.3922 0.8314 0.0745]);
end


% --- Executes during object creation, after setting all properties.
function DistFromObjct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DistFromObjct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',100);
set(hObject,'String','100');
assignin('base','DistanceFromObject',100);


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function AccelPdlVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AccelPdlVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',0);


% --- Executes during object creation, after setting all properties.
function BrkPdlVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BrkPdlVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',100);


% --- Executes during object creation, after setting all properties.
function AutoBrakeTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AutoBrakeTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
