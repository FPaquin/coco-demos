%%% HSPO_VARYING_SEGMENT_DEMO
%%% COCO version: 2017 Nov 18
%%% Created by: Gergely Gyebroszki, gyebro@mm.bme.hu
%%% At: 2018 Aug 22
%%%
%%% Varying segment periodic orbit continuation with the PO toolbox (HSPO)
%%% First a branch of 4-segment POs are continued until an event indicating 
%%% non-physical solution occurs (sliding mode begins). 
%%% Then a 6-segment PO (with two new sliding segments) are initialized and
%%% continued, again, until an event indicating non-physical solutions
%%% occurs (controlled segment disappears)
%%% Finally another 4-segment PO is continued when sliding absorbs the
%%% controlled segments
%%% 

%% 4-segment PO: Initial solution guess (ODE45)
% Initial parameters [alpha, beta]
p0 = [1.5; 0.2];
% Starting point of the first segment
y01 = [-1, -0.87];
t01 = 0;
% First segment: uncontrolled, until the M+ boundary is hit from below
opt1 = odeset('Events',@ode_event_mplus,'RelTol',1e-13);
[t1,y1] = ode45(@(t,y)Oscillator.f(y,p0,'uncontrolled'),[t01 t01+10],y01,opt1);
% Second segment: controlled (again until the M+ boundary from above)
y02 = [y1(end,1)+0.001; y1(end,2)];
t02 = t1(end);
[t2,y2] = ode45(@(t,y)Oscillator.f(y,p0,'controlled'),[t02 t02+10],y02,opt1);
% Third segment: uncontrolled (until M- boundary is hit from above)
y03 = [y2(end,1)-0.001; y2(end,2)];
t03 = t2(end);
opt3 = odeset('Events',@ode_event_mminus,'RelTol',1e-13);
[t3,y3] = ode45(@(t,y)Oscillator.f(y,p0,'uncontrolled'),[t03 t03+10],y03,opt3);
% Fourth segment: controlled (until M- boundary is hit from below)
y04 = [y3(end,1)-0.001; y3(end,2)];
t04 = t3(end);
[t4,y4] = ode45(@(t,y)Oscillator.f(y,p0,'controlled'),[t04 t04+10],y04,opt3);


%% Figure 1: Initial solution guess (ODE45)
figure(1); clf; hold on;
title 'Initial solution guess (ODE45)';
xlabel 'x'; ylabel 'v';
plot(y1(:,2),y1(:,1),'red');
plot(y2(:,2),y2(:,1),'blue');
plot(y3(:,2),y3(:,1),'red');
plot(y4(:,2),y4(:,1),'blue');
hold off;


%% 4-segment PO: Setting up the problem in COCO
% 2 modes: uncontrolled, controlled
% 2 boundaries: mplus, mminus
% no resets
modes  = {'uncontrolled' 'controlled' 'uncontrolled' 'controlled'};
events = {'mplus'        'mplus'      'mminus'       'mminus'};
resets = {'null'         'null'       'null'         'null'};
% Coco compatible initial solution (for the 4 segments respectively)
t0 = {t1 t2 t3 t4};
x0 = {y1 y2 y3 y4};
% Construct a hybrid system, multi segment PO problem from initial solution guess
prob = ode_isol2hspo(coco_prob(), '',       ...
	{@Oscillator.f, @Oscillator.events, @Oscillator.resets},	...
	modes, events, resets,                  ...
	t0, x0, {'al' 'be'}, p0);
% Get the data and location of u indices for the 1st segment (uncontrolled)
[data, uidx] = coco_get_func_data(prob, 'hspo.orb.bvp.seg1.coll', 'data', 'uidx');
% Add a monitor function to monitor when sliding mode should begin
prob = coco_add_func(prob, 'monitor', @Oscillator.monitor_sliding_begins, ...
    [], 'regular', 'sliding_begins', 'uidx',  ...
    [uidx(data.coll_seg.maps.x0_idx) uidx(data.coll_seg.maps.p_idx)]);
% Add a corresponding event
prob = coco_add_event(prob, 'SL', 'sliding_begins', 0);
% Do the magic
coco(prob, 'fourseg1', [], 1, 'al', [1.0 1.6]);

%% Figure 2: Branch of 4-segment POs
bd    = coco_bd_read('fourseg1'); % Extract bifurcation data
labs  = coco_bd_labs(bd);         % Extract labels
labSL = coco_bd_labs(bd, 'SL'); % 'sliding_begins' event

figure(2); clf;
hold on; grid on; box on
title 'Branch of 4-segment POs';
xlabel 'x'; ylabel 'v';
for lab=labs
	[sol,data] = hspo_read_solution('', 'fourseg1', lab);
	if lab>labSL
        % nonphysical solution: gray
        for i=1:data.hspo_orb.nsegs
            plot(sol.xbp{1,i}(:,2), sol.xbp{1,i}(:,1), 'LineStyle', '-', 'Color', [0.4 0.4 0.4]);
        end
    else  
        for i=1:data.hspo_orb.nsegs
        	if mod(i,2)==0   % Controlled segment: blue
            	plot(sol.xbp{1,i}(:,2), sol.xbp{1,i}(:,1), 'LineStyle', '-', 'Color', [0.5 0.5 1.0]);
            else             % Uncontrolled segment: red
            	plot(sol.xbp{1,i}(:,2), sol.xbp{1,i}(:,1), 'LineStyle', '-', 'Color', [1.0 0.5 0.5]);
            end
        end
    end
end
% Sliding mode begins: thick, red
[sol,data] = hspo_read_solution('', 'fourseg1', labSL);
for i=1:data.hspo_orb.nsegs
	plot(sol.xbp{1,i}(:,2), sol.xbp{1,i}(:,1), 'LineStyle', '-',    ...
      'LineWidth', 2, 'Color', [1.0 0.0 0.0]);
end


%% 6-segment PO: starting from the point where sliding begins (SL)
% At this point, two new 'sliding' segments are inserted between the 'controlled'
% and 'uncontrolled' segments.
% Construction of the initial solution
[solSL,dataSL] = hspo_read_solution('', 'fourseg1', labSL); 
p0 = solSL.p;           % Get alpha and beta
x1 = solSL.xbp{1,1};    t1 = solSL.tbp{1,1};    % 1st segment: 1st segment of solSL
x2 = solSL.xbp{1,2};    t2 = solSL.tbp{1,2};    % 2nd segment: 2nd segment of solSL
x3 = [solSL.xbp{1,2}(end,:);solSL.xbp{1,2}(end,:)]; % Sliding mode, single point segment
t3 = [0;0.1];
x4 = solSL.xbp{1,3};    t4 = solSL.tbp{1,3};    % 4th segment: 3rd segment of solSL
x5 = solSL.xbp{1,4};    t5 = solSL.tbp{1,4};    % 5th segment: 4th segment of solSL
x6 = [solSL.xbp{1,4}(end,:);solSL.xbp{1,4}(end,:)]; % Sliding mode, single point segment
t6 = [0;0.1];
modes  = {'uncontrolled' 'controlled' 'sliding' ...
          'uncontrolled' 'controlled' 'sliding'};
events = {'mplus'        'mplus'      'escape' ...
          'mminus'       'mminus'     'escape'};
resets = {'null' 'null' 'null' 'null' 'null' 'null'};
t0 = {t1 t2 t3 t4 t5 t6};
x0 = {x1 x2 x3 x4 x5 x6};
prob = coco_prob();
% 6-seg PO: Continuation with COCO
prob = ode_isol2hspo(prob, '', ...
    {@Oscillator.f, @Oscillator.events, @Oscillator.resets}, ...
    modes, events, resets, ...
    t0, x0, {'al' 'be'}, p0);
% Get the data, location of u indices for the 2nd segment (uncontrolled)
[data, uidx] = coco_get_func_data(prob, 'hspo.orb.bvp.seg2.coll', 'data', 'uidx');
% Add monitor function to monitor when controlled segment disappears
prob = coco_add_func(prob, 'monitor', @Oscillator.monitor_ctrl_disappears, ...
    [], 'regular', 'ctrl_disappears', 'uidx', ...
    [uidx(data.coll_seg.maps.x0_idx) uidx(data.coll_seg.maps.p_idx)]);
% Add a corresponding event
prob = coco_add_event(prob, 'CD', 'ctrl_disappears', 0);
% Do the magic
coco(prob, 'sixseg1', [], 1, 'al', [0.64 p0(1)]);


%% Figure 3: Branch of 6-segment POs
bd    = coco_bd_read('sixseg1');  % Extract bifurcation data
labs  = coco_bd_labs(bd);         % Extract labels
labCD = coco_bd_labs(bd, 'CD');
figure(3); clf;
title 'Branch of 6-segment POs';
for lab=labs
  [sol,data] = hspo_read_solution('', 'sixseg1', lab);
  subplot(4,2,lab);
  ylim([-1.5 1.5]);
  title(strcat('6-segment PO at alpha=',num2str(sol.p(1))));
  xlabel 'x'; ylabel 'v';
  hold on; grid on; box on
  for i=1:data.hspo_orb.nsegs
      if (lab == labCD) % Controlled seg disappears: pink, thick
          plot(sol.xbp{1,i}(:,2), sol.xbp{1,i}(:,1), 'LineStyle', '-',    ...
            'LineWidth', 2, 'Color', [1.0 0.0 1.0]);
      elseif (lab > labCD) % Nonphyical solution: gray
          plot(sol.xbp{1,i}(:,2), sol.xbp{1,i}(:,1), 'LineStyle', '-', 'Color', [0.4 0.4 0.4])
      else
          if mod(i,3)==0        % Sliding segment: green 
              plot(sol.xbp{1,i}(:,2), sol.xbp{1,i}(:,1), 'LineStyle', '-', 'Color', [0.2 1.0 0.2])   
          elseif mod(i,3)==2    % Controlled segment: blue
              plot(sol.xbp{1,i}(:,2), sol.xbp{1,i}(:,1), 'LineStyle', '-', 'Color', [0.2 0.2 1.0])   
          else                  % Uncontrolled segment: red
              plot(sol.xbp{1,i}(:,2), sol.xbp{1,i}(:,1), 'LineStyle', '-', 'Color', [1.0 0.2 0.2])
          end
      end    
  end
end


%% 4-segment PO: starting from the point where sliding mode 'absorbes' the 'controlled' segments
[solCD,dataCD] = hspo_read_solution('', 'sixseg1', labCD); 
p0 = solCD.p;        % Parameters
x1 = solCD.xbp{1,1}; t1 = solCD.tbp{1,1};  % 1st seg = 1st seg from solCD (uncontrolled)
x2 = solCD.xbp{1,3}; t2 = solCD.tbp{1,3};  % 2nd seg = 3rd seg from solCD (sliding)
x3 = solCD.xbp{1,4}; t3 = solCD.tbp{1,4};  % 3rd seg = 4th seg from solCD (uncontrolled)
x4 = solCD.xbp{1,6}; t4 = solCD.tbp{1,6};  % 4th seg = 6th seg from solCD (sliding)
modes  = {'uncontrolled' 'sliding' 'uncontrolled' 'sliding'};
events = {'mplus'        'escape'  'mminus'       'escape'};
resets = {'null'         'null'    'null'         'null'};
t0 = {t1 t2 t3 t4};
x0 = {x1 x2 x3 x4};
% 4-seg PO: Continuation with COCO
prob = ode_isol2hspo(coco_prob(), '', ...
    {@Oscillator.f, @Oscillator.events, @Oscillator.resets}, ...
    modes, events, resets, ...
    t0, x0, {'al' 'be'}, p0);
% Do the magic
coco(prob, 'fourseg2', [], 1, 'al', [0.1 p0(1)]);

%% Figure 4: Branch of 4-segment POs
bd   = coco_bd_read('fourseg2'); % Extract bifurcation data
labs = coco_bd_labs(bd);         % Extract labels
figure(4); clf;
title 'Branch of 4-segment POs';
for lab=labs
  [sol,data] = hspo_read_solution('', 'fourseg2', lab);
  subplot(4,3,lab);
  title(strcat('6-segment PO at alpha=',num2str(sol.p(1))));
  xlabel 'x'; ylabel 'v';
  ylim([-1.5 1.5]);
  xlim([-6 6]);
  hold on; grid on; box on
  for i=1:data.hspo_orb.nsegs
      if mod(i,2)==0 % Sliding segment: green
          plot(sol.xbp{1,i}(:,2), sol.xbp{1,i}(:,1), 'LineStyle', '-', 'Color', [0.5 1.0 0.5])
      else % Uncontrolled segment: red
          plot(sol.xbp{1,i}(:,2), sol.xbp{1,i}(:,1), 'LineStyle', '-', 'Color', [1.0 0.5 0.5])
      end
  end
end