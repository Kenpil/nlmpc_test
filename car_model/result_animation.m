clear all;
clc;

load('xypath.mat');
load('xHistory.mat');

figure(1);
plot(xypath(:,1), xypath(:,2));
axis equal;

%%

carWB = 0.3;
carFrame = 0.2;

hold on;

rearX = xHistory(1,1);
rearY = xHistory(1,2);
rearTire = plot(rearX, rearY, 'o', 'MarkerSize' ,5, 'MarkerFaceColor', 'r');

frontX = xHistory(1,1) + carWB * cos(xHistory(1,3));
frontY = xHistory(1,2) + carWB * sin(xHistory(1,3));
frontTire = plot(xHistory(1,1), xHistory(1,2), 'o', 'MarkerSize' ,5, 'MarkerFaceColor', 'b');

carPos =  [(rearX-carFrame) (rearY-carFrame) (carWB+2*carFrame) (2*carFrame)]';
carX = [(rearX-carFrame) (rearX+carWB+carFrame) (rearX+carWB+carFrame) (rearX-carFrame)];
carY = [(rearY-carFrame) (rearY-carFrame) (rearY+carFrame) (rearY+carFrame)];
car = patch('XData', carX, 'YData', carY, 'FaceColor', 'none');

carPath = plot(xHistory(1,1), xHistory(2,1), 'Color', '#D95319');

xlim([-4, 10]);
ylim([-0.5, 10.5]);

legend("reference", "actual (rear)", "actual (front)");
title("Vehicle Control by Non-linear MPC");
xlabel("x");
ylabel("y");

hold off;

myVideo = VideoWriter('MPC_car_result'); %open video file
myVideo.FrameRate = 15;  %can adjust this, 5 - 10 works well for me
open(myVideo)

for t = 1:length(xHistory(1,:))
    rearX = xHistory(1,t);
    rearY = xHistory(2,t);
    set(rearTire, 'XData', rearX, 'YData', rearY);
    
    frontX = xHistory(1,t) + carWB * cos(xHistory(3,t));
    frontY = xHistory(2,t) + carWB * sin(xHistory(3,t));
    set(frontTire, 'XData', frontX, 'YData', frontY);
    
    carX = [(rearX-carFrame) (rearX+carWB+carFrame) (rearX+carWB+carFrame) (rearX-carFrame)];
    carY = [(rearY-carFrame) (rearY-carFrame) (rearY+carFrame) (rearY+carFrame)];
    set(car, 'XData', carX, 'YData', carY);
    direction = [0 0 1];
    deg = xHistory(3,t) * 180 / 3.14159265;
    tireOrigin = [rearX, rearY, 0];
    rotate(car, direction, deg, tireOrigin);
    
    set(carPath, 'XData', xHistory(1,1:t), 'YData', xHistory(2,1:t));
    
    drawnow;
    
    frame = getframe(gcf); %get frame
    writeVideo(myVideo, frame);
    
    pause(0.05);
end

close(myVideo)