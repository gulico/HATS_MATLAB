classdef HATS
    %HAT 此处显示有关此类的摘要
    %   Parameters:
    %                temp_window: temporal window for events 事件时间窗口
    %                tau        : exponential decay constant 指数衰减常熟
    %                R          : neighborhood size 相邻事件的大小
    %                K          : cell size C单元的大小
    %                width      : pixel sensor width 像素传感器宽度
    %                height     : pixel sensor height 像素传感器高度
    
    properties % 常量
        temp_window = 0.1;
        tau = 0.5;
        R = 7;
        K = 7;
        index = containers.Map({-1,1},{1,2});%极性映射
        width = 35;
        heigth = 35;
        n_polarities = 2;% 极性个数
    end
    properties % 变量
        cell_width;
        cell_height;
        n_cells;
        cell_memory;
        get_cell; % 计算图像上像素对应的C单元的索引
        histograms = [];% 平均时间直方图
        event_counter = [];% 事件计数器
    end
    
    
    methods
        function obj = HATS()
            %HAT 构造此类的实例
            %   此处显示详细说明
            obj.cell_width = floor(obj.width/obj.K);
            obj.cell_height = floor(obj.heigth/obj.K);
            obj.n_cells = obj.cell_width*obj.cell_height;
            obj.cell_memory = cell(obj.n_cells,2);% 共享存储单元
            obj.get_cell = get_pixel_cell_partition_matrix(obj.width, obj.heigth, obj.K);
            obj = obj.reset();
        end
        
        function obj = reset(obj)
            %reset 初始化直方图、事件计数器、共享存储单元M_C
            obj.histograms = zeros(obj.n_cells,obj.n_polarities,2*obj.R+1,2*obj.R+1);
            obj.event_counter = zeros(obj.n_cells, obj.n_polarities);
            obj.cell_memory = cell(obj.n_cells, obj.n_polarities);
        end
        
        function obj = process(obj,event)
            %process 处理一个事件
            %获取事件对应的单元格
            cell_index = obj.get_cell(event(1,4),event(1,5));% 单元格对应的索引
            polarity_index = obj.index(event(1,6));% 极性
            
            %将事件添加到共享存储单元
            obj.cell_memory{cell_index,polarity_index}(end+1,:) = event;
            
            % 将本地内存过滤为仅时间窗口中的事件
            obj.cell_memory{cell_index,polarity_index} = filter_memory(obj.cell_memory{cell_index,polarity_index}, event(:,1), obj.temp_window);
            
            % 获取本地内存时间面
            time_surface = compute_local_memory_time_surface(event, obj.cell_memory{cell_index,polarity_index}, obj.R, obj.tau);
            % fprintf("%f\n",max(time_surface));
            % Add the time surface to the cell histograms
            % 将时间面添加到单元格直方图中

            obj.histograms(cell_index, polarity_index,:,:) = obj.histograms(cell_index, polarity_index,:,:) + reshape(time_surface,1,1,2*obj.R+1,2*obj.R+1);
            
            % Increase the event counter for the cell
            % 增加单元的事件计数器
            obj.event_counter(cell_index, polarity_index) =obj.event_counter(cell_index, polarity_index) + 1;
        end
        
        function obj = process_all(obj,events)
            %  process_all 循环处理所有的事件
            for i = 1:size(events,1)
                obj = obj.process(events(i,:));
            end
            
            % 归一化  
            obj.histograms = normalise(obj.histograms, obj.event_counter);
        end
    end
end

