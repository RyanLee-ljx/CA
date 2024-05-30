function [empty_cell]=get_empty(lane,vehicle,length_lane,vehicle_number)
%% 算出车辆i与前车的间距 用数组gap储存车辆i对应的前车间距
empty_cell=zeros(1,vehicle_number);
for i=1:vehicle_number
   % 用于标记周期性边界车道的首车
    leadvehicle=1;
   % 判断车辆i前方到边界是否存在车辆 若是 算出与前车间距 并标记非首车 0
    for front = ( vehicle.x1(i) + 1 ):length_lane
        if lane(vehicle.y(i),front)~=0
            leadvehicle=0;
            break
        end
    end
 % 如果不是首车的类型 求从车辆i位置到车道开始处第一辆车的间距 
    if leadvehicle==0   
        empty_cell(i)=front-vehicle.x1(i)-1;
    else
 % 若是首车 则末端边界到前车的距离
        for front_lead=1:vehicle.x2(i)
            if lane(vehicle.y(i),front_lead)~=0     %找到距离边界最近的车
                break
            end
        end
            empty_cell(i)=length_lane-(vehicle.x1(i)-front_lead)-1;
    end  
end
end