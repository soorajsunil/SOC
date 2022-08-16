classdef battery_simulator
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sample_length 
        current
        time
    end

    properties(Hidden,Constant)
        % signal controllers: 
        a   = 10;  % signal amplitude in Ampheres 
        f   = 0.1;   % signal frequency in hertz
        phi = 0;   % phase in radians 
    end
    
    methods
        function obj = battery_simulator(sampling_period, sample_duration)
            obj.sample_length = sample_duration/sampling_period;
            obj.time = (0:obj.sample_length-1)*sampling_period;
        end

        function ik = constant_charge(obj)
            % simulates constant charge (positive) current
            ik = obj.a*ones(1,obj.sample_length);
        end

        function ik = pulse_charge(obj)
            % simulates pulse charge (positive) current
            ik = obj.a*sign(cos(2*pi*obj.f*obj.time + obj.phi)); 
            ik(ik<0)=0; 
        end

        function ik = charge_and_discharge(obj)
            % simulates charge (positive) and discharge (negative) current
            ik = obj.a*sign(cos(2*pi*obj.f*obj.time + obj.phi)); % basic square wave
        end

        function ik = pulse_discharge(obj)
            % simulates discharge (negative) current
            ik = obj.a*sign(cos(2*pi*obj.f*obj.time + obj.phi)); % basic square wave
            ik(ik>0) = 0; 
        end 

        function ik = constant_discharge(obj)
            % simulates constant charge current
            ik = -obj.a*ones(1,obj.sample_length);
        end

        function ik = random_discharge(obj)
            % random discharge current
            ik = randi([-2,0], 1, obj.sample_length); 
        end


    end
end

