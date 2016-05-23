classdef Battery < handle
    %BATTERY Represent a battery, track SoC, check for violations etc.
    
    properties
        cfg                 % local copy of config variable
        SoC                 % kWh state of charge (energy in battery)
        capacity            % kWh capacity
        maxChargeRate       % max kW in/out of battery
        maxChargeEnergy     % max kWh/interval in/out of battery
        eps                 % threshold for constraint checking
    end
    
    methods
        % Constructor
        function obj = Battery(cfg, capacity)
            obj.cfg = cfg;
            obj.capacity = capacity;
            obj.maxChargeRate = cfg.sim.batteryChargingFactor*...
                capacity;
            
            obj.eps = cfg.sim.eps;
            obj.maxChargeEnergy = obj.maxChargeRate/...
                cfg.sim.stepsPerHour;
            
            obj.SoC = 0.5*obj.capacity;
        end
        
        % Attempt to put kWh into battery
        function chargeBy(this, kWhCharge)
            
            % Check for charge rate constraint violation:
            if kWhCharge > this.maxChargeEnergy + this.eps
                error(['Charge constraint violated, kWhCharge:'...
                    num2str(kWhCharge) ', maxChargeEnergy:'...
                    num2str(this.maxChargeEnergy)]);
            end
            
            % Check for discharge rate constraint violation:
            if kWhCharge < -this.maxChargeEnergy - this.eps
                error(['Discharge constraint violated, kWhCharge:'...
                    num2str(kWhCharge) ', -maxChargeEnergy:'...
                    num2str(-this.maxChargeEnergy)]);
            end
            
            % Check for upper SoC violation
            if kWhCharge + this.SoC > this.capacity + this.eps
                error(['Upper SoC constraint violation, SoC+kWhCharge:'...
                    num2str(kWhCharge + this.SoC) ', capacity:'...
                    num2str(this.capacity)]);
            end
            
            % Check for lower SoC violation
            if kWhCharge + this.SoC < -this.eps
                error(['Lower SoC constraint violation, SoC+kWhCharge:'...
                    num2str(kWhCharge + this.SoC)]);
            end
            
            % All constraints OK, so update charge in battery
            this.SoC = this.SoC + kWhCharge;
        end
        
        % Constrain kWh charge decision to batteries capability
        function ltdCharge = limitCharge(this, kWhCharge)
            
            % Initially set value to requested charge value
            ltdCharge = kWhCharge;
            
            % Check for charge rate constraint violation:
            if kWhCharge > this.maxChargeEnergy
                ltdCharge = this.maxChargeEnergy;
            end
            
            % Check for discharge rate constraint violation:
            if kWhCharge < -this.maxChargeEnergy
                ltdCharge = -this.maxChargeEnergy;
            end
            
            % Check for upper SoC violation
            if kWhCharge + this.SoC > this.capacity
                ltdCharge = this.capacity - this.SoC;
            end
            
            % Check for lower SoC violation
            if kWhCharge + this.SoC < 0
                ltdCharge = -this.SoC;
            end
        end
        
        
        % Reset the SoC of battery to starting value (0.5 x capacity)
        function reset(this)
            this.SoC = 0.5*this.capacity;
        end
        
        function randomReset(this)
            this.SoC = rand(1,1).*(this.capacity - 0) + 0;
        end
    end
end
