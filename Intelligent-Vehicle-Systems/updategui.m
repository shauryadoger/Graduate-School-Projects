function varargout = updategui(varargin)

%create a run time object that can return the value of the gain block's
%output (Vehicle Speed) and then put the value in a string.
rto = get_param('FinalProjectModel/Gain','RuntimeObject');
str = num2str(rto.OutputPort(1).Data);

%get a handle to the GUI's 'current state' window
statestxt = findobj('Tag','curState');

%update the gui
set(statestxt,'string',str);

% %create a run time object that can return the value of the Logic  block's
% %output (Auto Braking Status) and then put the value in a string.
% rto = get_param('FinalProjectModel/AutoBraking/Logical Operator','RuntimeObject');
% str = rto.OutputPort(1).Data;
% 
% %get a handle to the GUI's 'current state' window
% statestxt = findobj('Tag','AutoBrake');
% 
% %update the gui
% if str == 1
%     set(statestxt,'string','Auto Brake Active');
% else
%     set(statestxt,'string','Auto Brake Inactive');
% end
% 
