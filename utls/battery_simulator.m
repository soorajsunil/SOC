classdef battery_simulator
    properties
        intial_soc    
        capacity            
        scaling_factor
        coulombic_efficiency
    end

    properties(Hidden) 
        ik
        tk
        Nsamples
    end

    properties(Dependent)
        soc
        scaled_soc 
    end

    methods
        function obj = battery_simulator(ik, tk, varargin)
            % default values
            intial_soc     = 0.5; 
            capacity       = 3600; % cell capacity
            scaling_factor = 0.175;

            p        = inputParser;
            validate = @(x) isnumeric(x) && isscalar(x);
            addOptional(p,'intial_soc', intial_soc, validate);
            addOptional(p,'capacity', capacity, validate);
            addOptional(p,'scaling_factor',scaling_factor, validate);
            parse(p,varargin{:});

            obj.intial_soc =p.Results.intial_soc;
            obj.capacity =p.Results.capacity;
            obj.scaling_factor =p.Results.scaling_factor;
            obj.ik = ik; 
            obj.tk = tk;
            obj.Nsamples = size(tk,2); 
        end

        function coulombic_efficiency = get.coulombic_efficiency(obj)
            coulombic_efficiency = ones(size(obj.ik)); 
            coulombic_efficiency(obj.ik>0) = 0.95; 
        end 

        function soc = get.soc(obj)
            soc = zeros(1, obj.Nsamples);
            soc(:,1) = obj.intial_soc;
            for k = 2:obj.Nsamples
                dt = obj.tk(:,k)-obj.tk(:,k-1);
                soc(:,k) = obj.coulomb_count(soc(:,k-1), obj.ik(:,k-1), ...
                    dt, obj.capacity, obj.coulombic_efficiency(:,k-1)); 
            end
            soc(soc>1) = 1; 
            soc(soc<0) = 0; 
        end

        function scaled_soc = get.scaled_soc(obj)
            scaled_soc = obj.soc_scaling(obj.soc, obj.scaling_factor, 'forward');
        end

        function  plot_soc(obj)
            figure(name='SOC')
            plot(obj.tk,obj.soc, LineWidth=2)
            box on; grid on; 
            xlabel('Time (s)')
            ylabel('SOC')
        end

        function  plot_scaled_soc(obj)
            figure(name='scaled SOC')
            plot(obj.tk,obj.scaled_soc, LineWidth=2)
            box on; grid on
            xlabel('Time (s)')
            ylabel('scaled SOC')
        end 

    end

    methods(Static)
        function [scaled_soc] = soc_scaling(soc, epsilon, scaling_mode)
            % SOC scaling to avoid numerical instabilities while open
            % circuit voltage characterization
            %
            % [1]. Ahmed, Mostafa Shaban, Sheikh Arif Raihan, and Balakumar 
            % Balasingam. "A scaling approach for improved state of charge 
            % representation in rechargeable batteries." Applied energy
            % 267 (2020): 114880.
            %
            % >> epsilon = 0.175; % optimal value for soc scaling [1]
            %
            switch upper(scaling_mode)
                case 'FORWARD' % Forward scaling
                    scaled_soc = soc.*(1-2*epsilon) + epsilon;
                case 'BACKWARD' % Backward scaling
                    scaled_soc = (soc - epsilon)./(1-2*epsilon);
                otherwise
                    error('select scaling_mode as forward or backward')
            end
        end

        function [soc_k] = coulomb_count(soc_mk1, i_mk1, dt, Cbatt, eta)
            % assumes positive current for charging, negative current for discharging
            soc_k = soc_mk1 +  (eta/Cbatt)*(dt*i_mk1); 
        end

    end
end

