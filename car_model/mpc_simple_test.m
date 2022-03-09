clear all;
clc;

m = 1; % mass of car [kg]
c = 0.2; % coefficient of friction
k = 1; % spring constant [N/m]

Ts = 0.1; % sampling time [s]
A = [0 1; -k/m -c/m]; % factor A of state space (ss)
B = [0; 1/m]; % factor B of ss
C = [1 0]; % factor C of ss
D = 0; % factor D of ss

plant = ss(A, B, C, D, Ts) % create discrete ss model
mpcobj = mpc(plant)

xc = mpcstate(mpcobj)

% create reference trajectory r(t)
pi = 3.141592;
t = (0:Ts:10).'; % sampling freq 0.1s, time 0.0s -> 10.0s
% place of car: y(t)
r = sin(0.1 * pi * t) + sin(0.05 * pi * t) .* sin(0.2 * pi * t);

figure;
plot(t, r);

% time step simulation of MPC
N = length(t);
y = zeros(N, 1);
u = zeros(N, 1);
x = [0; 0];
for i = 1:N - 1
    y(i) = xc.Plant(1);
    u(i) = mpcmove(mpcobj, xc, y(i), r(i));
    %dx = A * x + B * u(i);
    %x = x + dx;
    %y(i + 1) = C * x + D * u(i);
end

figure;
plot(t, y);