function xk1 = carStateFcn(xk, u)

uk = u(1:2);
Ts = u(3);
xk1 = carDT(xk, uk, Ts);