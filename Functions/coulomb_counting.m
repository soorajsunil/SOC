classdef coulomb_counting
    properties
        intial_soc
        capacity
        scaling_factor
        charge_efficiency    = 1
        discharge_efficiency = 1
    end
    properties(Dependent)
        efficiency
        soc
        scaled_soc
    end
    properties(Hidden)
        ik
        tk
        Nsamples
    end
    methods
        function obj = coulomb_counting(ik, tk, varargin)
            % default values
            intial_soc     = 0.5;
            capacity       = 3*3600; % cell capacity in As
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

        function efficiency = get.efficiency(obj)
            efficiency = obj.cc_efficiency(obj.ik, ...
                obj.charge_efficiency, obj.discharge_efficiency);
        end

        function soc = get.soc(obj)
            soc = zeros(1, obj.Nsamples);
            soc(:,1) = obj.intial_soc;
            for k = 2:obj.Nsamples
                dt = obj.tk(:,k)-obj.tk(:,k-1);
                soc(:,k) = soc(:,k-1) +  ...
                    (obj.efficiency(:,k)*obj.ik(:,k)*dt)/obj.capacity;
            end
            soc(soc>1) = 1;
            soc(soc<0) = 0;
        end

        function scaled_soc = get.scaled_soc(obj)
            scaled_soc = soc_scaling(obj.soc, obj.scaling_factor, 'forward');
        end

        function variance = theoretical_variance(obj, current_noise)
            variance = zeros(size(obj.Nsamples));
            for k = 2:obj.Nsamples
                dt = obj.tk(:,k)-obj.tk(:,k-1);
                variance(k) = k*(obj.efficiency(k)^2)*(dt^2) ...
                    *(current_noise^2)/(obj.capacity^2);
            end

        end
    end

    methods(Static)

        function zk_i = add_noise(current, current_noise)
            zk_i = current + current_noise*randn(size(current));
        end

        function eta = cc_efficiency(current, charge_eff, discharge_eff)
            eta = ones(size(current));
            eta(current>0) = charge_eff;
            eta(current<0) = discharge_eff;
        end

    end
end

