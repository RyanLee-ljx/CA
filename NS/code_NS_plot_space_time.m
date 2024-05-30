%% 参数设置
clc,clear
close all
% 道路参数
W=1;  % 车道数
r=0.1; %货车比率
length_lane=2000; % 道路元胞数
lane=zeros(W,length_lane); % 创建元胞组成的车道
length_cell = 7.5;   %元胞实际长度
k = 15;    % 道路密度

% 迭代次数
iteraction=2000;  
start_time=1000;  %
start_time_trace = 1000;

% 设置车辆参数
vmax_car=5; %小汽车最大速度
vmax_truck=2; %货车最大速度
length_car=1; % 小汽车车长
length_truck=3; %货车车长
amax_car = 2;  %小汽车最大加速度
amax_truck = 1;  %货车最大加速度
vehicle_number=((length_lane*length_cell)/1000)*k; % 车辆数
car_number=round(vehicle_number*(1-r));  %小汽车数量
truck_number=round(vehicle_number*r);  %货车数量

% 慢启动和随机慢化参数
p_start_car=0.1;
p_slow=0.3;

%可视化设置
gif = 1; % 1打开可视化动画，0取消打开可视化动画，若想要画流速密图，则取消打开动画
if gif
    figure(1)
    Z = zeros(1,length_lane);
    Ch=imagesc(cat(3,lane,Z,Z));  %可视化图像设置
end
%% 仿真过程
    % 记录仿真过程中车辆数据，用于做时空图
    period=iteraction-start_time; % 去掉初始不稳定状态，取最后1000秒的数据
    memor_car=zeros(2,period,vehicle_number); % 创建记录的二维数组，第一维记录车辆坐标，第二维记录车辆速度
    type = zeros(1,vehicle_number);     %记录车辆类型
    totalnum = zeros(1,iteraction-start_time);        %记录车辆总数

    % 在车道随机投放车辆
    [lane,vehicle,vehicle_total,vehicle_num]=create_vehicle(vehicle_number,car_number,truck_number,lane,length_lane,vmax_car,vmax_truck,length_truck,length_car);
 
    % 主函数 车辆运动
    for t=1:iteraction
        % 进入预设时间段时开始记录时空图数据
        if t>start_time
            memor_car(1,t-start_time,:) = vehicle.x1;     %记录车头位置
            memor_car(2,t-start_time,:) = vehicle.v;      %记录速度
            type = vehicle.t;      %记录车种类
            totalnum(t-start_time) = vehicle_num;        % 记录每一时刻车辆总数
        end
        
        % 当前车道前车速度 和 目标车道的前后车距和速度
        [empty_cell]=get_empty(lane,vehicle,length_lane,vehicle_number);
       
        % 运动
        [lane,vehicle]=move_forward(lane,length_lane,vehicle,length_car,length_truck,vehicle_number,vmax_car,vmax_truck,amax_car,amax_truck,empty_cell,p_slow,p_start_car);
        
        %可视化
        if gif
            set(Ch,'CData',lane);
            axis square;
            pause(0.01);
            title(['仿真时间',num2str(t),'秒'],['当前密度：',num2str(k),'辆/km ',num2str(k*(length_lane*length_cell/1000)/2),'辆/千个元胞']);
        end
    end

%% 作图
figure(1)
T=(start_time+1:iteraction); % 创建一个等长度的时间数组
for j=1:vehicle_number
   %时空图与速度联系
   scatter(T,memor_car(1,:,j),5,memor_car(2,:,j),'filled');     %画每一辆车的所有时刻的位置
    hold on;
end
colorbar
colormap(jet); 
colorbar('AxisLocation','in');
xlabel('时间');
ylabel('位置');
axis([start_time iteraction 1 length_lane]);
caxis([0 vmax_car]);
title('时空位置图（含速度）')
hold off;

%时空图
%轨迹图
figure(2)
% 由于之前已记录了车辆i对应的坐标变化 因此做轨迹图循环每辆车再用plot将每个时刻坐标连起来即可
% 需要注意的是周期性边界车辆开出边界也连线 因此要在走到末端时断开连线
for j=1:vehicle_number
       t_out=start_time_trace+1;  % 标记每次驶出边界的时刻
   for t=start_time_trace+1:iteraction
       if (type(1,j)==0 && memor_car(1,t-start_time_trace,j)>length_lane-vmax_car)     % 下一时刻要出界
            plot(t_out:t,memor_car(1,t_out-start_time_trace:t-start_time_trace,j),'-k');
            hold on;
            t_out=t+1; % 标记下一次开始的起始时刻
       elseif (type(1,j)==1 && memor_car(1,t-start_time_trace,j)>length_lane-vmax_truck)
            plot(t_out:t,memor_car(1,t_out-start_time_trace:t-start_time_trace,j),'-r');
            hold on;
            t_out=t+1; % 标记下一次开始的起始时刻
       end
   end
   if (type(1,j)==0)
       plot(t_out:iteraction,memor_car(1,t_out-start_time_trace:iteraction-start_time_trace,j),'-k'); % 若最后一次没达到终点 需再画一次
   else
       plot(t_out:iteraction,memor_car(1,t_out-start_time_trace:iteraction-start_time_trace,j),'-r'); % 若最后一次没达到终点 需再画一次
   end
   hold on;
end
xlabel('时间');
ylabel('位置');
title('轨迹图');
axis([start_time_trace+1 iteraction 1000 length_lane]);









        
        
        
        
        
        
        
        
        
        
        
        
        
