function [output_memory] = filter_memory(memory,event_ts, temp_window)
%FILTER_MEMORY 
% finds all events between [event.ts-temp_window, event.ts)
% ����[event.ts-temp_window��event.ts��֮��������¼�
limit_ts = event_ts - temp_window;
% Due to the way it is built we only have to find the first extreme
% �������Ĺ�����ʽ������ֻ��Ҫ�ҵ���һ������
% Find it using binary search 
% ʹ�ö��ֲ����ҵ���
found = false;
left = 1;
right = size(memory,1);
while left<=right && ~found
    pos = 1;
    midpoint = floor((left + right)/2);
    if memory(midpoint,1) == limit_ts
        pos = midpoint;
        found = true;
    else
        if limit_ts < memory(midpoint,1)
            right = midpoint-1;
        else
            left = midpoint+1;
        end
    end
end
output_memory = memory(pos:end,:);
end

