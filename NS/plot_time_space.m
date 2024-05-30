function plot_time_space(iteraction,start_time,start_time_trace,vehicle_number,type,memor_car,length_lane,vmax_car,vmax_truck)
% plot_time_space: 画出时空位置图
% 输入参数: iteraction - 迭代次数
%           start_time_trace - 开始追踪的时间
%           vehicle_number - 车辆数量
%           type - 车辆的类型（0为小汽车，1为货车）
%           memor_car - 车辆的位置和速度的矩阵
%           length_lane - 车道长度
%           vmax_car - 小汽车的最大速度
%           vmax_truck - 货车的最大速度
% 时空位置图 



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
        if (type(1,j)==0)
            plot(t_out:iteraction,memor_car(1,t_out-start_time_trace:iteraction-start_time_trace,j),'-k'); % 若最后一次没达到终点 需再画一次
            hold on;
        else
            plot(t_out:iteraction,memor_car(1,t_out-start_time_trace:iteraction-start_time_trace,j),'-r'); % 若最后一次没达到终点 需再画一次
            hold on;
        end
    end
end
hold on;
xlabel('时间');
ylabel('位置');
title('时空位置图(k=50)');
legend('小汽车','货车');
axis([start_time+1 iteraction 1000 length_lane]);
hold off;

