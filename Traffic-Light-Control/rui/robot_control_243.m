function robot_control_243()
 % one robot, input leaderPos, point to point navigation
clear all; close all; clc; obj=instrfind;delete(obj);
%define the path of each vehicle

%path(1,1,:)=[0.6434 -2.8369];path(1,2,:)=[0.2612 -2.8369];path(1,3,:)=[-1.5522 -2.8369];path(1,4,:)=[0 0];%define path1. [0 0] is stopping mark 
%path(2,1,:)=[0.2612 -3.1738];path(2,2,:)=[0.2612 -2.8369];path(2,3,:)=[0.2846 -1.6583];path(2,4,:)=[0 0];%define path2. [0 0] is stopping mark
%serial number of traffic light in each intersection
path(1,1,:)=[3.9323 1.7858];path(1,2,:)=[4.3045 1.7963];path(1,3,:)=[4.7639 1.7977];path(1,4,:)=[ 6.3623 1.8156 ];
path(1,5,:)=[ 6.3904  2.0997];path(1,6,:)=[5.0351 2.0907];path(1,7,:)=[ 4.7639 2.0907 ];path(1,8,:)=[ 4.3045 2.0907];path(1,9,:)=[ 2.6364 2.1406 ];path(1,10,:)=[ 2.6511 1.8269 ];%define path1.

path(2,1,:)=[3.9323 1.7858];path(2,2,:)=[4.3045 1.7963];path(2,3,:)=[4.2166 0.8930];path(2,4,:)=[2.5886 0.8971];path(2,5,:)=[2.6511 1.8269];

path(3,1,:)=[4.2794  2.3141];path(3,2,:)=[4.2794 2.0907];path(3,3,:)=[4.2794 1.7963];path(3,4,:)=[ 4.2166 0.8930];
path(3,5,:)=[4.7639 0.8930 ];path(3,6,:)=[ 4.7639 1.4666 ];path(3,7,:)=[ 4.7639 1.7963 ];path(3,8,:)=[ 4.7639 2.0907];
path(3,9,:)=[ 4.7639  3.1 ];path(3,10,:)=[ 4.2794 3.1 ];%define path2.

%path(4,1,:)=[4.2194 1.2816];path(4,2,:)=[4.2425; 0.3342];path(4,3,:)=[1.4625; 0.2625];path(4,4,:)=[ 1.4485 1.2179];
pathmax=zeros(3,1);%pathmax is the largest avenue number of robots
pathmax(1)=10;
pathmax(2)=5;
pathmax(3)=10;
%serial number of traffic light in each intersection
light(1,1)=1;light(1,2)=2;light(1,3)=3;light(1,4)=4;light(1,5)=5;light(1,6)=6;light(1,7)=7;light(1,8)=8;light(1,9)=9;light(1,10)=10;
light(2,1)=11;light(2,2)=12;light(2,3)=13;light(2,4)=14;light(2,5)=15;
light(3,1)=16;light(3,2)=17;light(3,3)=18;light(3,4)=19;light(3,5)=20;light(3,6)=21;light(3,7)=22;light(3,8)=23;light(3,9)=24;light(3,10)=25;
%light(4,1)=26;light(4,2)=27;light(4,3)=28;light(4,4)=29;light(4,5)=30;
%initial traffic light color
%light_color=[0,1,1,1];
num_pololu =5;%number of cars in system
N=zeros(num_pololu,1);%mark the serial number of next traffic light in path for every car.
current=zeros(num_pololu,1);% record the serial number of the current traffic light
TT=zeros(num_pololu,1);
pathnum=zeros(num_pololu,1);
pathnum(1)=1;
pathnum(2)=2;
pathnum(3)=3;

pathnum(4)=1;
pathnum(5)=3;
% pathnum(6)=2;
% % camera set optitrack setup
addpath ('Eric');
period_camera_update = 0.1;
% Select Inputs frame = 'Optitrack';
frame = 'XY Plane';
% Optitrack Initialization
opti = optitrackSetup(3000);
%% formation param set

% timer setting
for i = 1 : num_pololu
    t(i) = timer;
    t(i).BusyMode = 'drop';
    t(i).TimerFcn ={@moveforward,num2str(i)};
    N(i)=1;%initial N and current
    current(i)=1;
end
timerBusy = zeros(num_pololu,1);

reachTarget = zeros(num_pololu,1);
%leaderPos = [1,1];  % initial leader pos

%% Connect serial PC terminal
comNum = 'COM9'; BaudRate = 115200;
serialPC = connect_to_serialPC(comNum,BaudRate);
for i=1:num_pololu
    ii=num2str(i);
    fprintf(serialPC, '%c%c\n',strcat(ii,'l'),'sync');
    %fprintf(serialPC, '%c%c\n',strcat(ii,'l'),'sync');
    %fprintf(serialPC, '%c%c\n',strcat(ii,'l'),'sync');

end
kkk=1;%time to control traffic light
img=imread('24_1.jpg');
        light_color=[0 0 0 0 0 0 0 0 0 0 ... 
                     0 0 0 0 0 ... 
                     1 0 0 0 0 1 0 0 0 0];
        %save('light_color','light_color');
        figure(1);
        clf(1);
while(1)
    
    if kkk==80
        img=imread('24_1.jpg');
        light_color=[0 0 0 0 0 0 0 0 0 0 ... 
                     0 0 0 0 0 ... 
                     1 0 0 0 0 1 0 0 0 0];
        %save('light_color','light_color');
        figure(1);
        clf(1);
    elseif (kkk==160)
        img=imread('24_2.jpg');
         light_color=[1 0 0 0 0 1 0 0 0 0 ... 
                      1 0 0 0 0 ... 
                      0 0 0 0 0 0 0 0 0 0];
         %save('light_color','light_color');
         figure(1);
        clf(1);
        kkk=0;
    end
    kkk=kkk+1;

image(img);
%figure('units','normlized','position',[.1 .1 .4 .4])
axis off;
    
    
   pause(0.2);
%    if fopen('light_color.mat')>0
%     mydata=load('light_color');
%     light_color=mydata.light_color;
%     fclose('all');
%    end
  % light_color=[0 0 0 0];
   [xc,yc,thetac]=read_pos(opti,frame);
   xc = - xc;
   yc = - yc;
   
   %************************************************************************************
   %carID=i; pathnum is path number
   for number_car=1:1:num_pololu
   CARID=num2str(number_car);
   %leaderPos=path(pathnum,N(str2double(CARID)));  
   if N(str2double(CARID))>pathmax(pathnum(str2double(CARID)))
            N(str2double(CARID))=1;
   end
  if(path(pathnum(str2double(CARID)),N(str2double(CARID)),1)~=0&&path(pathnum(str2double(CARID)),N(str2double(CARID)),2)~=0)
    
    
    % command calculation()
    current_pos = [xc(str2double(CARID)), yc(str2double(CARID))];
    current_dir = thetac(str2double(CARID));
  
    [heading_angle,dist] = cal_command(current_pos,current_dir,[path(pathnum(str2double(CARID)),N(str2double(CARID)),1),path(pathnum(str2double(CARID)),N(str2double(CARID)),2)]);  
   
    % execute command()
    %check position, unit: m , degree
    %light_color(light(num,N))
    if(detect_collision()==1)
        if TT(str2double(CARID))==1
            %timerBusy(str2double(CARID))=0;
            TT(str2double(CARID))=0;
            fprintf(serialPC, '%c%c\n',strcat(CARID,'f'),'sync');
            fprintf(serialPC, '%c%c\n',strcat(CARID,'f'),'sync');
            %fprintf(serialPC, '%c%c\n',strcat(CARID,'f'),'sync');
            fprintf(serialPC, '%c%c\n',strcat(CARID,'f'),'sync');
        end
    if dist > 0.05 && reachTarget(str2double(CARID)) == 0
        if N(str2double(CARID))<=pathmax(pathnum(str2double(CARID)))
            current(str2double(CARID))=N(str2double(CARID));
        else
            current(str2double(CARID))=1;
        end
        if abs(heading_angle) > 5  % degree
            if  timerBusy(str2double(CARID)) == 0         % check timer
                turnPololu(CARID,serialPC,heading_angle);
            end
        end
        
    else
        
            
        if(light_color(light(pathnum(str2double(CARID)),current((str2double(CARID)))))==1)   %red light
        fprintf(serialPC, '%c%c\n',strcat(CARID,'s'),'sync');
        fprintf(serialPC, '%c%c\n',strcat(CARID,'s'),'sync');
        fprintf(serialPC, '%c%c\n',strcat(CARID,'s'),'sync');
        fprintf(serialPC, '%c%c\n',strcat(CARID,'s'),'sync');
        reachTarget(str2double(CARID)) = 1;
        N(str2double(CARID))=current(str2double(CARID))+1;
        elseif light_color(light(pathnum(str2double(CARID)),current(str2double(CARID))))==0   %green light
            reachTarget(str2double(CARID))=0;
            N(str2double(CARID))=current(str2double(CARID))+1;
            fprintf(serialPC, '%c%c\n',strcat(CARID,'f'),'sync');
            fprintf(serialPC, '%c%c\n',strcat(CARID,'f'),'sync');
            fprintf(serialPC, '%c%c\n',strcat(CARID,'f'),'sync');
            fprintf(serialPC, '%c%c\n',strcat(CARID,'f'),'sync');
        end 
    end
    elseif detect_collision()==0
        TT(str2double(CARID))=1;
       % timerBusy(str2double(CARID)) = 1;
        fprintf(serialPC, '%c%c\n',strcat(CARID,'s'),'sync');
        fprintf(serialPC, '%c%c\n',strcat(CARID,'s'),'sync');
        fprintf(serialPC, '%c%c\n',strcat(CARID,'s'),'sync');
        fprintf(serialPC, '%c%c\n',strcat(CARID,'s'),'sync');
        
    end
  else
        fprintf(serialPC, '%c%c\n',strcat(CARID,'s'),'sync');
        fprintf(serialPC, '%c%c\n',strcat(CARID,'s'),'sync');
        fprintf(serialPC, '%c%c\n',strcat(CARID,'s'),'sync');
        fprintf(serialPC, '%c%c\n',strcat(CARID,'s'),'sync');
  end
% *************************************************************************************************
 
   end

end



function turnPololu(carID,serialPC,angle)
    turn_time = 2.1/360*abs(angle);
    id = str2double(carID);
    t(id).StartDelay= turn_time;
    timerBusy(id) = 1;
    start(t(id));
      
    if(angle >0) % turn left
       fprintf(serialPC, '%c%c\n',strcat(carID,'l'),'sync');
       fprintf(serialPC, '%c%c\n',strcat(carID,'l'),'sync');
    else
       fprintf(serialPC, '%c%c\n',strcat(carID,'r'),'sync');
       fprintf(serialPC, '%c%c\n',strcat(carID,'r'),'sync');
    end
        
end

function moveforward(obj,event,handles)
        
    fprintf(serialPC, '%c%c\n',strcat(handles,'f'),'sync');
    fprintf(serialPC, '%c%c\n',strcat(handles,'f'),'sync');
        
    id = str2double(handles);
    timerBusy(id) = 0;  
end
%**********************************************************************
%if result=1, there is no car before;else if result=0, car should stop to avoid collision.
%the serial number of current traffic light in path for every car.
% function result=detect_collision()
% result=1; 
%  for j=1:1:num_pololu
%     if(str2double(CARID)~=j)
%         if(norm([xc(str2double(CARID)), yc(str2double(CARID))]-[xc(j), yc(j)])<0.28)
%             if(pathnum(str2double(CARID))==pathnum(j))
%                 if(current(str2double(CARID))==current(j))
%                      y2=path(pathnum(str2double(CARID)),current(str2double(CARID)),2)-yc(str2double(CARID));
%                      y1=path(pathnum(str2double(CARID)),current(str2double(CARID)),2)-yc(j);
%                      x2=path(pathnum(str2double(CARID)),current(str2double(CARID)),1)-xc(str2double(CARID));
%                      x1=path(pathnum(str2double(CARID)),current(str2double(CARID)),1)-xc(j);
%             if(norm([0,0]-[x2,y2])>norm([0,0]-[x1,y1]))
%               result=0;
%                 break;
%            
%             end
%                 elseif((current(j)-current(str2double(CARID)))==1)
%                     result=0;
%                     break;
%                 end
%             end
%          
%             
%         end
%     end
%  end
% end

function result=detect_collision()
result=1; 
 for j=1:1:num_pololu
    if(str2double(CARID)~=j)
        if(norm([xc(str2double(CARID)), yc(str2double(CARID))]-[xc(j), yc(j)])<0.3)
            if(path(pathnum(str2double(CARID)),current(str2double(CARID)),1)==path(pathnum(j),current(j),1))&&(path(pathnum(str2double(CARID)),current(str2double(CARID)),2)==path(pathnum(j),current(j),2))
               
                     y2=path(pathnum(str2double(CARID)),current(str2double(CARID)),2)-yc(str2double(CARID));
                     y1=path(pathnum(str2double(CARID)),current(str2double(CARID)),2)-yc(j);
                     x2=path(pathnum(str2double(CARID)),current(str2double(CARID)),1)-xc(str2double(CARID));
                     x1=path(pathnum(str2double(CARID)),current(str2double(CARID)),1)-xc(j);
                     if(norm([0,0]-[x2,y2])>norm([0,0]-[x1,y1]))
                         result=0;
                         break;
           
                     end
             elseif (path(pathnum(str2double(CARID)),current(str2double(CARID)),1)==path(pathnum(j),loop_minus(j),1))&&(path(pathnum(str2double(CARID)),current(str2double(CARID)),2)==path(pathnum(j),loop_minus(j),2))
                %if (norm([xc(str2double(CARID)), yc(str2double(CARID))]-[xc(j), yc(j)])<0.2)
                    result=0;
                    break;
               % end
             end
         
            
        end
    end
 end
end

function output_args=loop_minus(input_args)
    if current(input_args)==1
        output_args=pathmax(pathnum(input_args));
    else
        output_args=current(input_args)-1;
    end
end

end