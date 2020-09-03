classdef HATS
    %HAT �˴���ʾ�йش����ժҪ
    %   Parameters:
    %                temp_window: temporal window for events �¼�ʱ�䴰��
    %                tau        : exponential decay constant ָ��˥������
    %                R          : neighborhood size �����¼��Ĵ�С
    %                K          : cell size C��Ԫ�Ĵ�С
    %                width      : pixel sensor width ���ش��������
    %                height     : pixel sensor height ���ش������߶�
    
    properties % ����
        temp_window = 0.1;
        tau = 0.5;
        R = 7;
        K = 7;
        index = containers.Map({-1,1},{1,2});%����ӳ��
        width = 35;
        heigth = 35;
        n_polarities = 2;% ���Ը���
    end
    properties % ����
        cell_width;
        cell_height;
        n_cells;
        cell_memory;
        get_cell; % ����ͼ�������ض�Ӧ��C��Ԫ������
        histograms = [];% ƽ��ʱ��ֱ��ͼ
        event_counter = [];% �¼�������
    end
    
    
    methods
        function obj = HATS()
            %HAT ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj.cell_width = floor(obj.width/obj.K);
            obj.cell_height = floor(obj.heigth/obj.K);
            obj.n_cells = obj.cell_width*obj.cell_height;
            obj.cell_memory = cell(obj.n_cells,2);% ����洢��Ԫ
            obj.get_cell = get_pixel_cell_partition_matrix(obj.width, obj.heigth, obj.K);
            obj = obj.reset();
        end
        
        function obj = reset(obj)
            %reset ��ʼ��ֱ��ͼ���¼�������������洢��ԪM_C
            obj.histograms = zeros(obj.n_cells,obj.n_polarities,2*obj.R+1,2*obj.R+1);
            obj.event_counter = zeros(obj.n_cells, obj.n_polarities);
            obj.cell_memory = cell(obj.n_cells, obj.n_polarities);
        end
        
        function obj = process(obj,event)
            %process ����һ���¼�
            %��ȡ�¼���Ӧ�ĵ�Ԫ��
            cell_index = obj.get_cell(event(1,4),event(1,5));% ��Ԫ���Ӧ������
            polarity_index = obj.index(event(1,6));% ����
            
            %���¼���ӵ�����洢��Ԫ
            obj.cell_memory{cell_index,polarity_index}(end+1,:) = event;
            
            % �������ڴ����Ϊ��ʱ�䴰���е��¼�
            obj.cell_memory{cell_index,polarity_index} = filter_memory(obj.cell_memory{cell_index,polarity_index}, event(:,1), obj.temp_window);
            
            % ��ȡ�����ڴ�ʱ����
            time_surface = compute_local_memory_time_surface(event, obj.cell_memory{cell_index,polarity_index}, obj.R, obj.tau);
            % fprintf("%f\n",max(time_surface));
            % Add the time surface to the cell histograms
            % ��ʱ������ӵ���Ԫ��ֱ��ͼ��

            obj.histograms(cell_index, polarity_index,:,:) = obj.histograms(cell_index, polarity_index,:,:) + reshape(time_surface,1,1,2*obj.R+1,2*obj.R+1);
            
            % Increase the event counter for the cell
            % ���ӵ�Ԫ���¼�������
            obj.event_counter(cell_index, polarity_index) =obj.event_counter(cell_index, polarity_index) + 1;
        end
        
        function obj = process_all(obj,events)
            %  process_all ѭ���������е��¼�
            for i = 1:size(events,1)
                obj = obj.process(events(i,:));
            end
            
            % ��һ��  
            obj.histograms = normalise(obj.histograms, obj.event_counter);
        end
    end
end

