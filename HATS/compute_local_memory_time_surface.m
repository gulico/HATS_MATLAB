function [time_surface] = compute_local_memory_time_surface(event_i, filtered_memory, R, tau)
%COMPUTE_LOCAL_MEMORY_TIME_SURFACE ���㱾���ڴ�ʱ����
% The function takes the a filtered memory containing only 
% events in the neighborhood of the event and belonging to the
% temporal window that needs to be considered and outputs a time 
% surface.
% �ú�����ȡһ���ѹ��˵��ڴ棬
% ���ڴ�������¼��������¼���
% ����������Ҫ���ǵ�ʱ�䴰�ڣ������ʱ����档

% filtered_memory������洢��ԪM_C

% initialize blank time surface 
% ��ʼ����ʱ�����
time_surface = zeros(2*R+1, 2*R+1);

% get the timestamp of the triggering event 
% ��ȡ�����¼���ʱ���
t_i = event_i(:,1);

% for every event in the local memory relevant to the event
% (relevean both in spatial and temporal terms), do:
% �������¼���صı����ڴ��е�ÿ���¼�
%����ʱ���϶�����Եģ�����ִ�����²�����
for j  = 1:size(filtered_memory,1)
    event_j = filtered_memory(j,:);
    % compute the time delta 
    % ����ʱ���
    delta_t = t_i - event_j(1,1);
        
    % compute contribution to time surface event_j
    % �ڼ���ʱ�����Ĺ���e^{(ti-t')/tau}
    event_value = exp(-delta_t/tau);
        
    % compute coordinates in the shifted representation 
    % ����ֲ��ռ�����Ե�����
    shifted_y = event_j(1,5) - (event_i(1,5) - R);
    shifted_x = event_j(1,5) - (event_i(1,5) - R);
        
    % sum it to the time surface 
    % ������ʱ��������
    time_surface(shifted_y, shifted_x) = time_surface(shifted_y, shifted_x) + event_value;
        
    % return the computed time surface 
    % ���ؼ�����ʱ�����
end

