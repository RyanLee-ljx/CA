function plot_time_spacev(iteraction,start_time,vehicle_number,memor_car,length_lane,vmax_car)
% plot_time_spacev: 画出时空位置图（含速度）
% 输入参数: iteraction - 迭代次数
%           start_time - 开始时间
%           vehicle_number - 车辆数量
%           memor_car - 车辆的位置和速度的矩阵
%           length_lane - 车道长度
%           vmax_car - 车辆的最大速度
figure(3)
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

