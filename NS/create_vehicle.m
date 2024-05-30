function [lane,vehicle,vehicle_total,vehicle_num]=create_vehicle(vehicle_number,car_number,truck_number,lane,length_lane,vmax_car,vmax_truck,length_truck,length_car)
%% 创造车辆及初始位置速度,t表示车辆种类（0为小汽车，1为货车） x1和x2表示车头车尾h位置 y表示车道
  num_car = 0;    % 记录小汽车数量
  num_truck = 0;    % 记录货车数量
  vehicle = struct('t',zeros(1,vehicle_number),'v',zeros(1,vehicle_number),'x1',zeros(1,vehicle_number),'x2',zeros(1,vehicle_number),'y',zeros(1,vehicle_number));
for i=1:vehicle_number
    % 随机产生货车或小汽车
    if(num_car==car_number)   %小汽车已满
        vehicle.t(i) = 1;   
    elseif num_truck==truck_number    %货车已满
        vehicle.t(i) = 0;
    else
        vehicle.t(i) = randi(1);   
    end
    if(vehicle.t(i)==0 && num_car~=car_number)
        num_car = num_car + 1;   % 计数小汽车
        vehicle.y(i)=1;    % 车道数
        % 先用随机数确定车头位置，再根据车长确定车尾位置
        vehicle.x1(i) = randi(length_lane);  % 随机产生1-length_lane的随机数为车
        vehicle.x2(i) = vehicle.x1(i);  %车头车尾同位置
        % 若在创建的车头至车尾范围内有任意元胞已被之前创立的车辆占用，则需重新产生随机位置头位置
        lane(vehicle.y(i),vehicle.x1(i)) = -1;  % 将产生车辆的胞赋值-1 并赋初速度
        vehicle.v(i)=randi([0 vmax_car]);
    end
    if(vehicle.t(i)==1 && num_truck~=truck_number)          %随机产生货车
        num_truck = num_truck + 1;   % 计数小汽车
        vehicle.y(i)=1;    % 车道数
        % 先用随机数确定车头位置，再根据车长确定车尾位置
        vehicle.x1(i) = randi(length_lane);  
        % 由于是周期性边界，故若车有一部分在道路边界外时，车尾坐标定为1
        vehicle.x2(i)=max(vehicle.x1(i)-length_truck+1,1);
        % 若在创建的车头至车尾范围内有任意元胞已被之前创立的车辆占用，则需重新产生随机位置
        while any(lane(vehicle.y(i),vehicle.x2(i):vehicle.x1(i)))
            vehicle.x1(i) = randi(length_lane);
            vehicle.x2(i)=max(vehicle.x1(i)-length_truck+1,1);
        end
        % 将产生车辆的胞赋值-1 并赋初速度
        lane(vehicle.y(i),vehicle.x2(i):vehicle.x1(i)) = -1;
        vehicle.v(i)=randi([0 vmax_truck]);
    end
    vehicle_total = car_number * length_car + length_truck * truck_number;    %返回相对车辆数，用于计算道路密度
    vehicle_num = car_number + truck_number;    % 返回车辆总数
end
