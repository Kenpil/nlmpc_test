clear all;
clc;

xy = [0, 0; % (x,y) points where car moves
      5, 0;
      8, 2;
      5, 6;
      2, 4;
      0, 1;
      -3, 6;
      -1, 8;
      3, 10;
      7, 9;
      10, 6];
  
p = 1:length(xy(:,1));
q = 1:0.05:length(xy(:,1));

% create car trajectory via xy points
x = spline(p, xy(:,1), q);
y = spline(p, xy(:,2), q);

xypath = [x', y'];

figure;
plot(xypath(:,1), xypath(:,2));
title("car reference trajectory");
xlabel("x");
ylabel("y");

save('xypath', 'xypath');