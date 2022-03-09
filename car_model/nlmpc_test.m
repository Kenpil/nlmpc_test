clear all;
clc;

nx = 3; % x, y, theta
ny = 2; % x, y
nu = 2; % v, delta
nlobj = nlmpc(nx, ny, nu);

Ts = 0.05; % 50ms sampling
nlobj.Ts = Ts;
nlobj.PredictionHorizon = 20;
nlobj.ControlHorizon = 5;

nlobj.Model.StateFcn = "carDT";
nlobj.Model.IsContinuousTime = false;
nlobj.Model.NumberOfParameters = 1;
nlobj.Model.OutputFcn = @(x,u,Ts) [x(1); x(2)]; % x, y

x0 = [0; 0; 0];
u0 = [0; 0];
validateFcns(nlobj, x0, u0, [], {Ts});

EKF = extendedKalmanFilter(@carStateFcn,@carMeasurementFcn);
x = x0
y = x0(1:2);
EKF.State = x;
mv = [0; 0];

load('xypath.mat');

nloptions = nlmpcmoveopt;
nloptions.Parameters = {Ts};

Duration = 10;
xHistory = x;
Duration/Ts
for ct = 1:(Duration/Ts)
    ct
    % Correct previous prediction
    xk = correct(EKF,y);
    % Compute optimal control moves
    yref = xypath(ct,:);
    [mv,nloptions] = nlmpcmove(nlobj,xk,mv,yref,[],nloptions);
    % Predict prediction model states for the next iteration
    predict(EKF,[mv; Ts]);
    % Implement first optimal control move
    x = carDT(x,mv,Ts);
    % Generate sensor data (with noise)
    y = x([1 2]) + randn(2,1)*0.01;
    % Save plant states
    xHistory = [xHistory x];
end

%%

figure;
plot(xypath(:,1), xypath(:,2));
hold on;
plot(xHistory(1,:), xHistory(2,:));
legend("reference", "actual");
title("Vehicle Control by Non-linear MPC");
xlabel("x");
ylabel("y");
hold off;