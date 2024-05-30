% 本代码模拟异质流NS元胞自动机模型
...注：1. 一长度单位 = 7.5m
...    2. 车辆正常行驶视为匀速，加减速按车辆加速度进行，在一时步内完成
...    
  % 参数说明：  
... 1.环岛长度：15000m,即2000长度单位，单车道，不考虑宽度，车辆不可超车
... 2.车辆尺寸：(车辆长度+与前车距离)   货车长22.5m（3长度单位），小汽车长7.5m（1长度单位）
... 3.车辆性能：
...  （1）速度：货车最大速度15m/s(2长度单位/s)，小汽车最大速度30m/s(4长度单位/s)
...  （2）加速度：货车最大加速度(绝对值)7.5m/s^2（1长度单位/s^2）,小汽车最大加速度15m/s^2（2长度单位/s^2）
... 4.每千米车辆数：0-120辆/km
... 5.货车比率 = 0.1
... 6.随机慢化概率 = 0.3
... 7.慢启动概率 = 0.1

  % 函数说明
... 1.本函数为主函数，包含：参数设置、仿真过程、计算、图像四部分
... 2.子函数create_vehicle:用于初始化车辆 
... 3.子函数get_empty:用于获取所有位置车辆与前车距离
... 4.子函数move_forward:用于执行NS模型四个步骤，即加速、根据安全距离减速、随即漫化速度、更新位置
...   此外还添加了车辆启动时的随机慢化过程

  %本代码主要参考：https://zhuanlan.zhihu.com/p/195715484，进行改写

clc,clear
%% 参数设置

% 道路参数
W=1;  % 车道数
r=0.1; %货车比率
length_lane=2000; % 道路元胞数
lane=zeros(W,length_lane); % 创建元胞组成的车道
length_cell = 7.5;   %元胞实际长度
kmax = 120; % 每千米的车辆数

% 迭代次数
iteraction=2000;  
start_time=1000;  % 开始时间
start_time_trace = 1000;   % 开始记录时间

% 设置车辆参数
vmax_car=5; %小汽车最大速度
vmax_truck=2; %货车最大速度
length_car=1; % 小汽车车长
length_truck=3; %货车车长
amax_car = 2;  %小汽车最大加速度
amax_truck = 1;  %货车最大加速度

% 慢启动和随机慢化参数
p_start_car=0.1;
p_slow=0.7;

%可视化设置
gif = 1; % 1打开可视化动画，0取消打开可视化动画，若想要画流速密图，则取消打开动画
if gif
    figure(1);
    Z = zeros(1,length_lane);
    Ch=imagesc(cat(3,lane,Z,Z));  %可视化图像设置
end

% 记录仿真过程中车辆数据，用于做时空图
period=iteraction-start_time; % 去掉初始不稳定状态，取最后1000秒的数据
qkv_data = zeros(3,period,length(1:1:kmax));     %记录行驶过程q，k，v
%% 仿真过程
for k = 1:1:kmax
    lane=zeros(W,length_lane); % 清空
    vehicle_number=((length_lane*length_cell)/1000)*k; % 车辆数  n = k * l
    car_number=round(vehicle_number*(1-r));  %小汽车数量
    truck_number=round(vehicle_number*r);  %货车数量
    
    % 记录仿真过程中车辆数据，用于做时空图
    memor_car=zeros(2,period,vehicle_number); % 创建记录的三维数组，前两维第一行记录车辆坐标，第二行记录车辆速度，每一列为时刻，三维为车辆数。即记录每一个车每一时刻的位置与速度
    type = zeros(1,vehicle_number);     %记录车辆类型
    relative_total = zeros(1,iteraction-start_time);      %记录相对车辆数
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
            relative_total(t-start_time) = vehicle_total;   %记录相对车辆数
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
            pause(0.0001);
            title(['仿真时间',num2str(t),'秒'],['当前密度：',num2str(k),'辆/km ',num2str(k*(length_lane*length_cell/1000)/2),'辆/千个元胞']);
        end
    end
    
    if t>start_time
        % 计算
        S = sum(memor_car(2,:,:), 3);    % 计算单位时间内，每一个时刻，所有车辆行驶距离
        vs_lane = ((S.*length_cell)./(totalnum))*3.6;    % 记录每一时刻区间平均车速 km/h
        kw_lane = (relative_total./length_lane)*1000;   %各时刻车道空间占有(不用于计算) 
        q_lane = vs_lane.*k;     %流率q=k*v
        
        % 记录k密度下，q,kw（空间占有）,v计算结果
        qkv_data(1,:,k) = q_lane;
        qkv_data(2,:,k) = kw_lane;    
        qkv_data(3,:,k) = vs_lane;
    end
    
end  
% 计算
qmean = zeros(1,length(1:1:kmax));
kwmean = zeros(1,length(1:1:kmax));    
vmean = zeros(1,length(1:1:kmax));

for k = 1:1:kmax
    qmean(1,k) = mean(qkv_data(1,:,k));
    kwmean(1,k) = mean(qkv_data(2,:,k));
    vmean(1,k) = mean(qkv_data(3,:,k));
end
k=1:1:kmax;
[max_q,indexq] = max(qmean);
disp(['极大流率 q：', num2str(max_q),' 最佳密度k：', num2str(k(indexq))]);
disp(['畅行速度 v：', num2str(vmean(1)),' 临界速度：', num2str(vmean(indexq))]);

% 流速密图
figure(2) 
subplot(2,2,1);
scatter(1:1:kmax,qmean,4,'filled');
title('流率-密度图')
xlabel('密度/(辆/km)');
ylabel('流率/(辆/h)');


subplot(2,2,2)
fplot(@(t) sin(t),[-3.8,3.8],'b:');    % 随便写一个，后面替换为空
title('Subplot 2: Sin(x)');

subplot(2,2,3);
scatter(1:1:kmax,vmean,4,'filled');
title('速度-密度图')
xlabel('密度/(辆/km)');
ylabel('速度/(km/h)');

subplot(2,2,4);
scatter(qmean,vmean,4,'filled');
title('速度-流率图')
xlabel('流率/(辆/h)');
ylabel('速度/(km/h)');

subplot(2,2,2,'replace');   %替换右上角图像为空
sgtitle ( '流量-速度-密度图');









