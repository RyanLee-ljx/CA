function plot_qkv(kmax,qmean,vmean)
% plot_qkv: 画出流量-速度-密度图
% 输入参数: kmax - 密度的最大值
%           qmean - 平均流量
%           vmean - 平均速度
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