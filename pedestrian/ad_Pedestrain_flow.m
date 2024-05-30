% 平台基本信息：
%  平台16*30，左三个入口，大小分别为1*1,1*4,1*1，右四个出口，均为为1*1，中间设有障碍，行人不得通过障碍，行人每秒走一格，每个行人占一格。
%  行人随机从各个入口进入。
%  更新规则：取各出口最大作为元胞潜力N。
%  规定仿真时间为960s
%% 初始化参数
clc,clear
format short;
n=16;            %平台宽度
h=30;           %平台长度
star_x = ones(1,6);  % 入口横坐标
star_y = [4,7:10,13];  % 入口纵坐标
hurdle_x = repelem(14:16,2);   % 障碍
hurdle_x = cat(2,hurdle_x,[20 20]);
hurdle_y = repmat(8:9,1,3);
hurdle_y = cat(2,hurdle_y,[5 12]);
final_x = ones(1,4)*h;   % 出口
final_y = [3,6,11,14];
x=n+2;            % 边界矩阵宽
y=h+2;            % 边界矩阵长
platform=ones(n,h);   %初始化平台
obstacle_map=ones(n+4,h+4);   %设置非障碍矩阵
obstacle_map(1:2,:)=0;
obstacle_map(end-1:end,:)=0;
obstacle_map(:,1:2)=0;
obstacle_map(:,end-1:end);
border=ones(x,y);      %边界矩阵
border(1,:)=0;  
border(end,:)=0;
border(:,1)=0;
border(:,end)=0;
Sm=ones(n+4,h+4);   % 图 
Sm(1:2,:)=0;
Sm(end-1:end,:)=0;
Sm(:,1:2)=0;
Sm(:,end-1:end);
for i = 1:size(hurdle_y,2)
    Sm(hurdle_y(i)+2,hurdle_x(i)+2)=0; %设置障碍
    obstacle_map(hurdle_y(i)+2,hurdle_x(i)+2)=0; %设置障碍
end
step=1;                %初始迭代次数
po=1:1:9;     %位置矩阵
pp = zeros(1,9);
neigh = [-1,-1;0,-1;1,-1;-1,0;0,0;1,0;-1,1;0,1;1,1];
L=zeros(n,h,size(final_y,2));          % 不含边界距离矩阵
N=zeros(n+2,h+2,size(final_y,2));      % 元胞潜力
N_choose=zeros(n+2,h+2);      % 最终选择
P=zeros(n+2,h+2);          %预留内存
prob=zeros(1,9);        %概率矩阵、预留内存
go=0;     % 出发人数
arrive=0; % 到达终点人数
total=960;  % 迭代时间
time_people_star = zeros(n,h,total); % 记录时刻平台信息

%% 可视化设置
colormap([0 0 0;1 1 1])
Z=ones(n,h);
figure(1);
Ch=imagesc(cat(3,platform,Z,Z));  %可视化图像设置
hold on;
for p = 1:size(star_y,2)
    fill([star_x(p)-0.5, star_x(p)-0.5, star_x(p)+0.5, star_x(p)+0.5],[star_y(p)-0.5,star_y(p)+0.5,star_y(p)+0.5,star_y(p)-0.5],'b');  % 入口
end
for p = 1:size(final_y,2)
    fill([final_x(p)-0.5, final_x(p)-0.5, final_x(p)+0.5, final_x(p)+0.5],[final_y(p)-0.5,final_y(p)+0.5,final_y(p)+0.5,final_y(p)-0.5],'g');   % 出口
end
for p = 1:size(hurdle_y,2)
    fill([hurdle_x(p)-0.5, hurdle_x(p)-0.5, hurdle_x(p)+0.5, hurdle_x(p)+0.5],[hurdle_y(p)-0.5,hurdle_y(p)+0.5,hurdle_y(p)+0.5,hurdle_y(p)-0.5],'r');  % 障碍
end
axis square  %显示边框
set(gca,'ytick',-0.5:1:n);
set(gca,'xtick',-0.5:1:h);
set(gca,'xticklabel',[]);
set(gca,'yticklabel',[]);
grid on;
ax = gca; % 获取当前坐标轴对象
ax.LineWidth = 2; % 设置网格线的粗细为2
axis square;

%% 距离矩阵L及含边界距离矩阵Dis_1 与 Dis_2
Dis = zeros(n+2,h+2,size(final_y,2));
Dis = Dis + inf;
% 分别计算边界内每个原胞到出口的距离
for f=1:size(final_y,2)
    for i=1:n
        for j=1:h
            L(i,j,f)=sqrt((i-final_y(f))^2+(j-final_x(f))^2);    %不含边界的距离矩阵Lij
        end
    end
end
Dis(2:n+1,2:h+1,:)=L;
for i = 1:size(hurdle_y,2)
    Dis(hurdle_y(i)+1,hurdle_x(i)+1,:)=inf; %障碍视为距离无穷
end

%% 周围非障碍数矩阵O
O=obstacle_map(1:x,2:y+1)+obstacle_map(3:x+2,2:y+1)+obstacle_map(2:x+1,1:y)+obstacle_map(2:x+1,3:y+2)+obstacle_map(1:x,1:y)+obstacle_map(3:x+2,1:y)+obstacle_map(1:x,3:y+2)+obstacle_map(3:x+2,3:y+2);

%% 仿真
%% 行人流设置
while(step)
    % 进
    if step<=round(total*0.85)
        r = randi([0,1],size(star_y));
        go = go + sum(r);
        for i = 1:size(star_y,2)
            platform(star_y(i),star_x(i)) = r(i);
        end
    end
    % 记录此时刻情况   
    time_people_star(:,:,step) = (platform==0);
    % 出
    for i = 1:size(final_y,2)
        if platform(final_y(i),final_x(i))==0
            arrive = arrive + 1;
            platform(final_y(i),final_x(i))=1;
        end
    end
    set(Ch,'CData',platform);
    disp('出站人数：');
    disp(arrive);

    %% 周围空元胞数矩阵D
    border(2:n+1,2:h+1)=platform;     % 更新border矩阵
    Sm(2:x+1,2:y+1)=border;
    D=Sm(1:x,2:y+1)+Sm(3:x+2,2:y+1)+Sm(2:x+1,1:y)+Sm(2:x+1,3:y+2)+Sm(1:x,1:y)+Sm(3:x+2,1:y)+Sm(1:x,3:y+2)+Sm(3:x+2,3:y+2);
    
    %% 原胞潜力N
    % 计算原胞潜力N
    for f = 1:size(final_y,2)
        for i=1:x
            for j=1:y
                N(i,j,f)=border(i,j)*exp(-5*Dis(i,j,f)+D(i,j)+O(i,j));
            end
        end
    end
    for i = 1:size(final_y,2)
        N(final_y(i)+1,final_x(i)+1)=1e10;    % 设置出口原胞潜力为1e10，可视为无穷大
    end
    N_1 = max(N(:,:,1),N(:,:,2));     %最大作为原胞潜力N
    N_2 = max(N(:,:,3),N(:,:,4));
    N_choose = max(N_1,N_2);
    
    %% 位置更新
    % 说明：计算时以未更新的border矩阵状态进行计算，更新后在platform矩阵中存储新更新的状态，从而实现同步更新。
    for j=h+1:-1:2
        for i=2:n+1
            if(border(i,j)==0)    %如果位置（即原胞）有人，计算所有邻居原胞的原胞潜力N
                % 计算位置1到9各原胞潜力大小，并进行归一化处理
                for xy = po
                    pp(1,xy) = N_choose(i+neigh(xy,2),j+neigh(xy,1));
                end
                prob = pp/sum(pp);
                if sum([pp(2),pp(3),pp(6),pp(8),pp(9)]~=0)  % 上下前三个方向不全都有人
                    S=randsrc(1,1,[po;prob]);  %依原胞潜力N，选择下一位置，即进行位置更新
                else
                    S = 5;
                end
                k = i + neigh(S,2);
                t = j + neigh(S,1);
                if platform(k-1,t-1)==0   % 选择新位置已占，则选回原位置
                    S = 5;
                    k = i + neigh(S,2);
                    t = j + neigh(S,1);
                end
                platform(i-1,j-1)=1;      % 位置更新，原来原胞更新为空状态
                platform(k-1,t-1)=0;      % 位置更新，新选择原胞更新为占有状态
            end
        end
    end
    
    %% 仿真结束条件
    if(step==total)
        disp('仿真结束');
        break;
    end
    step=step+1;
    disp('迭代次数：')
    disp(step);
    pause(0.1);
    title(['仿真时间',num2str(step),'秒'],['人流量',num2str(go/step),'人/s']);
    
end
%% 热力图
hold off
figure(2)
total_people = sum(time_people_star,3);
heatmap(total_people,'GridVisible','off');
colormap jet; 
