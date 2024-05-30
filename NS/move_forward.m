function [lane,vehicle]=move_forward(lane,length_lane,vehicle,length_car,length_truck,vehicle_number,vmax_car,vmax_truck,amax_car,amax_truck,empty_cell,p_slow,p_start_car)
for i=1:vehicle_number            
    %% 更新前工作 将移动前车辆占有的元胞变为空元胞
    lane(vehicle.y(i),vehicle.x2(i):vehicle.x1(i))=0;
    switch vehicle.t(i)
        %% 小汽车情况
        case 0      % 对于小汽车情况
            % 随机慢化和慢启动
            if vehicle.v(i)==0 % 慢启动
                if rand(1)<=p_start_car
                    vehicle.v(i)=0;
                else
                    vehicle.v(i) = min(vehicle.v(i)+amax_car,empty_cell(i));
                end
            else % 车辆不是处于静止中启动的情况 则加速
                vehicle.v(i) = min(vehicle.v(i)+amax_car,vmax_car);
            end
            % 判断安全车距
            vehicle.v(i)=min(empty_cell(i),vehicle.v(i));
            % 以一定的概率慢化
            if rand(1)<=p_slow
                vehicle.v(i)=max(0,vehicle.v(i)-1);
            end
            % 位置更新 把车辆移动后位置元胞赋值
            vehicle.x1(i)=fix(mod(vehicle.x1(i)+vehicle.v(i)-1,length_lane)+1);
            vehicle.x2(i)=max(vehicle.x1(i)-length_car+1,1);
            lane(vehicle.y(i),vehicle.x1(i))= 1;
       %%  货车情况
        case 1     % 对于货车情况
            if vehicle.v(i)==0 % 慢启动
                if rand(1)<=p_start_car
                    vehicle.v(i)=0;
                else
                    vehicle.v(i) = min(vehicle.v(i)+amax_truck,empty_cell(i));
                end
            else % 车辆不是处于静止中启动的情况 则加速
                vehicle.v(i) = min(vehicle.v(i)+amax_truck,vmax_truck);
            end
            % 判断安全车距
            vehicle.v(i)=min(empty_cell(i),vehicle.v(i));
            % 以一定的概率慢化
            if rand(1)<=p_slow
                vehicle.v(i)=max(0,vehicle.v(i)-1);
            end
            % 位置更新 把车辆移动后位置元胞赋值
            vehicle.x1(i)=fix(mod(vehicle.x1(i)+vehicle.v(i)-1,length_lane)+1);
            vehicle.x2(i)=max(vehicle.x1(i)-length_truck+1,1);
            lane(vehicle.y(i),vehicle.x2(i):vehicle.x1(i))= 1;
    end
end
end

