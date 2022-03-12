function dxStatedt = carCT(xState, uInput)

% state x
x = xState(1);
y = xState(2);
theta = xState(3);

% input u
v = uInput(1);
delta = uInput(2);

WB = 0.3; % wheel base length

% dx/dt
xDot = v * cos(theta);
yDot = v * sin(theta);
thetaDot = v * tan(delta) / WB;

dxStatedt = [xDot; yDot; thetaDot];