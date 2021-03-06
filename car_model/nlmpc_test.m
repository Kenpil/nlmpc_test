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

nlobj.Model.StateFcn = "carDT"; % give discrete car model
nlobj.Model.IsContinuousTime = false;
nlobj.Model.NumberOfParameters = 1;
nlobj.Model.OutputFcn = @(x,u,Ts) [x(1); x(2)]; % x, y

% initial values for x, u
x0 = [0; 0; 0];
u0 = [0; 0];
validateFcns(nlobj, x0, u0, [], {Ts});

% Kalman filter to estimate car state in executing
EKF = extendedKalmanFilter(@carStateFcn,@carMeasurementFcn);
x = x0;
y = x0(1:2);
EKF.State = x; % initial value for EKF
mv = [0; 0]; % = u (v; delta)

nloptions = nlmpcmoveopt; % object of options for MPC
nloptions.Parameters = {Ts};

load('xypath.mat'); % reference car (x,y) path

Duration = 10; % simulation time
tLength = Duration/Ts;
xHistory = zeros(length(x(:,1)), tLength); % x state result
xHistory(:, 1) = x0;

for t = 1:tLength
    t
    % Correct previous prediction
    xk = correct(EKF,y);
    % Compute optimal control moves
    yref = xypath(t,:);
    [mv,nloptions] = nlmpcmove(nlobj,xk,mv,yref,[],nloptions);
    % Predict prediction model states for the next iteration
    predict(EKF,[mv; Ts]);
    % Implement first optimal control move
    x = carDT(x,mv,Ts);
    % Generate sensor data (with noise)
    y = x([1 2]) + randn(2,1)*0.01;
    % Save plant states
    xHistory(:, t + 1) = x;
end

save ("xHistory", "xHistory");

%%

load("xHistory.mat");
figure;
plot(xypath(:,1), xypath(:,2));
hold on;
plot(xHistory(1,:), xHistory(2,:));
legend("reference", "actual");
title("Vehicle Control by Non-linear MPC");
xlabel("x");
ylabel("y");
hold off;