% CSTR Dynamic Simulation Project
% Solves Mass and Energy Balances for a Non-Isothermal Reactor
clear all; clc; close all;

% --- 1. DEFINE PARAMETERS ---
F = 100;        % Flow rate (L/min)
V = 1000;       % Reactor Volume (L)
CA_in = 1.0;    % Inlet Concentration (mol/L)
T_in = 350;     % Inlet Temperature (K)
T_cool = 300;   % Coolant Temperature (K)

% Reaction Parameters
k0 = 7.2e10;    % Pre-exponential factor (1/min)
E_R = 8750;     % Activation Energy / R (K)
dH = -50000;    % Heat of Reaction (J/mol) (Exothermic)
rho = 1000;     % Density (g/L)
Cp = 0.239;     % Heat Capacity (J/g-K)
UA = 50000;     % Heat Transfer coeff * Area (J/min-K)

% --- 2. SET TIME SPAN ---
t_span = [0 20];  % Simulate for 20 minutes
initial_conditions = [0.1, 300]; % Start with CA=0.1, T=300K

% --- 3. SOLVE ODEs ---
% We use 'ode45', the standard solver for differential equations
[t, y] = ode45(@(t,y) reactor_odes(t, y, F, V, CA_in, T_in, T_cool, k0, E_R, dH, rho, Cp, UA), t_span, initial_conditions);

% --- 4. VISUALIZE RESULTS ---
figure(1)

% Plot 1: Concentration vs Time
subplot(2,1,1);
plot(t, y(:,1), 'b', 'LineWidth', 2);
title('Reactor Concentration Profile');
xlabel('Time (min)');
ylabel('Concentration C_A (mol/L)');
grid on;

% Plot 2: Temperature vs Time
subplot(2,1,2);
plot(t, y(:,2), 'r', 'LineWidth', 2);
title('Reactor Temperature Profile');
xlabel('Time (min)');
ylabel('Temperature T (K)');
grid on;

% --- 5. THE EQUATIONS FUNCTION ---
function dydt = reactor_odes(t, y, F, V, CA_in, T_in, T_cool, k0, E_R, dH, rho, Cp, UA)
    CA = y(1); % Current Concentration
    T = y(2);  % Current Temperature
    
    % Calculate Rate Constant (Arrhenius)
    k = k0 * exp(-E_R / T);
    
    % Mass Balance: dCA/dt
    dCAdt = (F/V)*(CA_in - CA) - k*CA;
    
    % Energy Balance: dT/dt
    dTdt = (F/V)*(T_in - T) + (-dH*k*CA)/(rho*Cp) - (UA/(rho*Cp*V))*(T - T_cool);
    
    dydt = [dCAdt; dTdt];
end