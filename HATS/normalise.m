function [result] = normalise(histograms, event_counter)
%NORMALISE 
% A characteristic of event-based sensors is that the amount
% of events generated by a moving object is proportional to its
% contrast: higher contrast objects generate more events than
% low contrast objects. To make the cell descriptor more invariant 
% to contrast, we therefore normalize h by the number of events |C| 
% contained in the spatio-temporal window used to compute it. 
% �����¼��Ĵ��������������ڣ��ƶ�����������¼���������Աȶȳ����ȣ�
% �ԱȶȽϸߵ�����ȶԱȶȽϵ͵�����������¼����ࡣ 
% Ϊ��ʹ��Ԫ�������ԶԱȶȸ��Ӳ��䣬
% ��ˣ����Ǹ����¼���| C |��h���й�һ���� 
% ���������ڼ���ʱ�յĴ����С�

result  = zeros(size(histograms));
        
% normalise ��һ��
    for i  = 1: size(histograms,1)
        for p  = 1:size(histograms,2)
            result(i,p,:,:) = histograms(i,p,:,:)./(event_counter(i,p)+0.1);
        end
    end
end
