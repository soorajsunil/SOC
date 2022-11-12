classdef equivalent_circuit_model

    properties
        open_circuit_voltage
        terminal_voltage
        drop
        model 
        soc
        scaled_soc
        R0
        R1
        R2
        I1
        I2
        H
    end

    properties(Constant)
        resolution = 0.01;
        ocv_params = [-9.082; 103.087; -18.185; 2.062; -0.102; ...
            -76.604; 141.199; -1.117]; % curve fitters characterized offline
    end

    properties(Hidden)
        current_soc
        scaling_factor
    end

    methods
        function obj = equivalent_circuit_model(current_soc, scaling_factor)
            obj.current_soc     = current_soc;
            obj.scaling_factor = scaling_factor;
            obj.open_circuit_voltage   = obj.get_ocv(obj.ocv_params, obj.current_soc);
        end

        function obj = internal_resistance(obj, ik, R0)
            % simple (internal resistance) model
            obj.model = 'R-internal'; 
            obj.R0       = R0;
            obj.drop     = ik*obj.R0;
            obj.terminal_voltage = obj.open_circuit_voltage + obj.drop;
            obj.scaled_soc = obj.SOC_lookup(obj.resolution, ...
                obj.scaling_factor, obj.ocv_params, obj.open_circuit_voltage); % OCV-SOC table
            obj.soc = soc_scaling(obj.scaled_soc, obj.scaling_factor, 'backward');
        end

        function variance = theoretical_variance(obj, current_noise, voltage_noise)
            variance = zeros(size(obj.scaled_soc));
            
            diff_eq = @(x, ocv_params) ...
                -ocv_params(2)*(x^(-2)) - 2*ocv_params(3)*(x^(-3)) - ...
                3*ocv_params(4)*(x^(-4)) - 4*ocv_params(5)*(x^(-5)) +  ...
                ocv_params(6) + ocv_params(7)/x - ...
                ocv_params(8)/(1-x); % first order of combined +3 model 

            for k = 1:length(obj.scaled_soc)
                variance(k) = (voltage_noise^2+obj.R0^2*current_noise^2) ...
                    *(1/diff_eq(obj.scaled_soc(k), obj.ocv_params))^2;
            end
        end

    end

    methods(Static)
        function SOC = SOC_lookup(resolution, scaling_factor, ocv_params, ocv)
            SOC = nan(size(ocv));
            min_soc = soc_scaling(0,scaling_factor,'forward');
            max_soc = soc_scaling(1,scaling_factor,'forward');
            for k = 1:length(ocv)
                SOC(k) = lookup(min_soc, max_soc, resolution, ocv_params, ocv(k));
            end
            function SOC = lookup(min_soc, max_soc, resolution, ocv_params, ocv)
                % bisection method for root finding
                ea = 1;
                xr = double((min_soc + max_soc)/2);
                i  = 0;
                while(ea > resolution)
                    fxl = equivalent_circuit_model.get_ocv(ocv_params, min_soc) - ocv;
                    fxr = equivalent_circuit_model.get_ocv(ocv_params, xr) - ocv;
                    if(fxl*fxr<=0)
                        max_soc = xr;
                    elseif(fxl*fxr>0)
                        min_soc = xr;
                    end
                    xr_new  = (min_soc + max_soc)/2;
                    ea      = (abs(xr_new-xr)/xr_new);
                    ea      = ea*100;
                    i       = i+1;
                    xr      = xr_new;
                end
                SOC  = xr_new;
            end
        end
        function ocv = get_ocv(ocv_params, SOC)
            % OCV characterization using "combined +3" model
            % [1]. Pattipati, B., Balasingam, B., Avvari, G. V., Pattipati,
            % K. R., & Bar-Shalom, Y. (2014). Open circuit voltage
            % characterization of lithium-ion batteries. Journal of
            % Power Sources, 269, 317-333.
            ocv = ocv_params(1) + ocv_params(2).*(1./SOC) ...
                + ocv_params(3).*(1./(SOC.^2)) ...
                + ocv_params(4).*(1./(SOC.^3)) ...
                + ocv_params(5).*(1./(SOC.^4)) ...
                + ocv_params(6).*SOC + ocv_params(7).*(log(SOC)) ...
                + ocv_params(8).*(log(1-SOC));
        end

        function zk_v = add_noise(voltage, voltage_noise)
            zk_v = voltage + voltage_noise*randn(size(voltage));
        end
    end
end

