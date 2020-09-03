function [time_surface] = compute_local_memory_time_surface(event_i, filtered_memory, R, tau)
%COMPUTE_LOCAL_MEMORY_TIME_SURFACE 计算本地内存时间面
% The function takes the a filtered memory containing only 
% events in the neighborhood of the event and belonging to the
% temporal window that needs to be considered and outputs a time 
% surface.
% 该函数获取一个已过滤的内存，
% 该内存仅包含事件附近的事件，
% 并且属于需要考虑的时间窗口，并输出时间表面。

% filtered_memory：共享存储单元M_C

% initialize blank time surface 
% 初始化空时间表面
time_surface = zeros(2*R+1, 2*R+1);

% get the timestamp of the triggering event 
% 获取触发事件的时间戳
t_i = event_i(:,1);

% for every event in the local memory relevant to the event
% (relevean both in spatial and temporal terms), do:
% 对于与事件相关的本地内存中的每个事件
%（在时空上都是相对的），请执行以下操作：
for j  = 1:size(filtered_memory,1)
    event_j = filtered_memory(j,:);
    % compute the time delta 
    % 计算时间差
    delta_t = t_i - event_j(1,1);
        
    % compute contribution to time surface event_j
    % 在计算时间表面的贡献e^{(ti-t')/tau}
    event_value = exp(-delta_t/tau);
        
    % compute coordinates in the shifted representation 
    % 计算局部空间中相对的坐标
    shifted_y = event_j(1,5) - (event_i(1,5) - R);
    shifted_x = event_j(1,5) - (event_i(1,5) - R);
        
    % sum it to the time surface 
    % 将其与时间表面相加
    time_surface(shifted_y, shifted_x) = time_surface(shifted_y, shifted_x) + event_value;
        
    % return the computed time surface 
    % 返回计算后的时间表面
end

