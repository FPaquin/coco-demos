%% Auxiliary figure 5, Vector field of the system

[sol,data] = hspo_read_solution('', 'sixseg1', 2);
p0 = sol.p;
[X,Y] = meshgrid(-1.5:.1:1.5,-.9:0.1:.9);
DX = zeros(size(X,1),size(X,2));
DY = zeros(size(X,1),size(X,2));
for i=1:size(X,1)
    for j=1:size(Y,2)
        f = Oscillator.f([Y(i,j);X(i,j)], p0, 'uncontrolled');
        DX(i,j)=f(2); DY(i,j)=f(1);
    end
end
[X2,Y2] = meshgrid(-1.5:.1:1.5,[-1.5:0.1:-1.1 1.1:0.1:1.5]);
DX2 = zeros(size(X2,1),size(X2,2));
DY2 = zeros(size(X2,1),size(X2,2));
for i=1:size(X2,1)
    for j=1:size(Y2,2)
        f = Oscillator.f([Y2(i,j);X2(i,j)], p0, 'controlled');
        DX2(i,j)=f(2); DY2(i,j)=f(1);
    end
end

figure(5)
hold on
title 'Vector field of Oscillator';
quiver(X2,Y2,DX2,DY2);  % Vector field of 'controlled' state
quiver(X,Y,DX,DY);      % Vector field of 'uncontrolled' state
% Switching lines
mplus = [1; 1];  mminus = [-1; -1];  endpts = [-2.0; 2.0];
plot(endpts, mplus , 'LineStyle', '-', 'Color', [0.0 0.0 0.0]);
plot(endpts, mminus, 'LineStyle', '-', 'Color', [0.0 0.0 0.0]);
% Example solution
plot(sol.xbp{1,1}(:,2), sol.xbp{1,1}(:,1), 'LineWidth', 2, 'LineStyle', '-', 'Color', [1.0 0.2 0.2]);
plot(sol.xbp{1,2}(:,2), sol.xbp{1,2}(:,1), 'LineWidth', 2, 'LineStyle', '-', 'Color', [0.2 0.2 1.0]);
plot(sol.xbp{1,3}(:,2), sol.xbp{1,3}(:,1), 'LineWidth', 2, 'LineStyle', '-', 'Color', [0.2 1.0 0.2]);
plot(sol.xbp{1,4}(:,2), sol.xbp{1,4}(:,1), 'LineWidth', 2, 'LineStyle', '-', 'Color', [1.0 0.2 0.2]);
plot(sol.xbp{1,5}(:,2), sol.xbp{1,5}(:,1), 'LineWidth', 2, 'LineStyle', '-', 'Color', [0.2 0.2 1.0]);
plot(sol.xbp{1,6}(:,2), sol.xbp{1,6}(:,1), 'LineWidth', 2, 'LineStyle', '-', 'Color', [0.2 1.0 0.2]);
hold off