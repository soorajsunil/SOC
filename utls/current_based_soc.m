classdef current_based_soc
    properties
        intial_soc
        capacity
        scaling_factor

    end
    properties(Dependent)
        coulombic_efficiency
        soc
        scaled_soc
    end
    properties(Hidden)
        ik
        tk
        Nsamples
        charge_efficiency    = 0.95
        discharge_efficiency = 1
    end
    methods
        function obj = current_based_soc(ik, tk, varargin)
            % default values
            intial_soc     = 0.5; 
            capacity       = 1.9*3600; % cell capacity
            scaling_factor = 0.175;

            p = inputParser;
            validate = @(x) isnumeric(x) && isscalar(x);
            addOptional(p,'intial_soc', intial_soc, validate);
            addOptional(p,'capacity', capacity, validate);
            addOptional(p,'scaling_factor', scaling_factor, validate);
            parse(p,varargin{:});
            obj.intial_soc = p.Results.intial_soc;
            obj.capacity   = p.Results.capacity;
            obj.scaling_factor = p.Results.scaling_factor; 
            obj.ik = ik; 
            obj.tk = tk;
            obj.Nsamples = size(tk,2); 
        end

        function coulombic_efficiency = get.coulombic_efficiency(obj)
            coulombic_efficiency = ones(size(obj.ik)); 
            coulombic_efficiency(obj.ik>0) = obj.charge_efficiency; 
            coulombic_efficiency(obj.ik<0) = obj.discharge_efficiency; 
        end 

        function soc = get.soc(obj)
            soc = zeros(1, obj.Nsamples);
            soc(:,1) = obj.intial_soc;
            for k = 2:obj.Nsamples
                dt = obj.tk(:,k)-obj.tk(:,k-1);
                soc(:,k) = soc(:,k-1) +  ...
                    (obj.coulombic_efficiency(:,k)*obj.ik(:,k)*dt)/obj.capacity; 
            end
            soc(soc>1) = 1; 
            soc(soc<0) = 0; 
        end

        function scaled_soc = get.scaled_soc(obj)
          scaled_soc = soc_scaling(obj.soc, obj.scaling_factor, 'forward');
        end
        
    end
    methods(Static)
        function zk_i = add_noise(current, current_noise)
            zk_i = current + current_noise*randn(size(current));
        end
    end


end

