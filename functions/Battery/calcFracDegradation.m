function [ fracDegradation ] = calcFracDegradation(cfg, battery, qInt, ...
    bInt)

% calcFracDegradation: Calculate the fractional degradation from a battery
%                       charging decision.

%% Calculate properties of the charge-decision
q_kWh = battery.statesKwh(qInt);
b_kWh = bInt*battery.increment;
SoCav = 100*((q_kWh - 0.5*b_kWh)/battery.capacity); %#ok<NASGU>
DoD = abs(100*b_kWh/battery.capacity);

switch cfg.bat.damageModel
    
    case 'fixed'
%% Fixed per kWh Damage
fracDegradation = DoD/(cfg.bat.nominalCycleLife*cfg.bat.nominalDoD*2);

    case 'staticMultifactor'
%% Static multi-factor Damage

    case 'dynamicMultifactor'
%% Static multi-factor Damage

end

if fracDegradation < 0
    error('Battery fractional degradation negative!');
end

% Apply a minimum amount of calendar damage
minDamage = (1/cfg.sim.stepsPerHour)/(cfg.bat.maxLifeHours);
if fracDegradation < minDamage
    fracDegradation = minDamage;
end

end
