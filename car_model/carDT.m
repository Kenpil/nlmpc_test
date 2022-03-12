function xk1 = carDT(xk, uk, Ts)

M = 10;
delta = Ts / M;
xk1 = xk;

% new_x = old_x + sum(dx/dt_1 ~ dx/dt_10)
for ct = 1:M
    xk1 = xk1 + delta * carCT(xk1, uk);
end