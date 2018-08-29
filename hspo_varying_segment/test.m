%%% Self-test script for HSPO_VARYING_SEGMENT_DEMO
%%% COCO version: 2017 Nov 18
%%% Created by: Gergely Gyebroszki, gyebro@mm.bme.hu
%%% At: 2018 Aug 22
function result = test()
% Put everything in a try/catch block, see bottom of the script for catching errors
try
    p0 = [1.5; 0.2];
    y01 = [-1, -0.87];
    t01 = 0;
    f = @(varargin) varargin{:};
    ode_event_mplus  = @(t,y)f(y(1)-1,1,0); 
    ode_event_mminus = @(t,y)f(y(1)+1,1,0); 
    opt1 = odeset('Events',ode_event_mplus,'RelTol',1e-13);
    [t1,y1] = ode45(@(t,y)Oscillator.f(y,p0,'uncontrolled'),[t01 t01+10],y01,opt1);
    y02 = [y1(end,1)+0.001; y1(end,2)];
    t02 = t1(end);
    [t2,y2] = ode45(@(t,y)Oscillator.f(y,p0,'controlled'),[t02 t02+10],y02,opt1);
    y03 = [y2(end,1)-0.001; y2(end,2)];
    t03 = t2(end);
    opt3 = odeset('Events',ode_event_mminus,'RelTol',1e-13);
    [t3,y3] = ode45(@(t,y)Oscillator.f(y,p0,'uncontrolled'),[t03 t03+10],y03,opt3);
    y04 = [y3(end,1)-0.001; y3(end,2)];
    t04 = t3(end);
    [t4,y4] = ode45(@(t,y)Oscillator.f(y,p0,'controlled'),[t04 t04+10],y04,opt3);
    % First run 'fourseg1'
    modes  = {'uncontrolled' 'controlled' 'uncontrolled' 'controlled'};
    events = {'mplus'        'mplus'      'mminus'       'mminus'};
    resets = {'null'         'null'       'null'         'null'};
    t0 = {t1 t2 t3 t4};
    x0 = {y1 y2 y3 y4};
    prob = ode_isol2hspo(coco_prob(), '',       ...
        {@Oscillator.f, @Oscillator.events, @Oscillator.resets},	...
        modes, events, resets,                  ...
        t0, x0, {'al' 'be'}, p0);
    [data, uidx] = coco_get_func_data(prob, 'hspo.orb.bvp.seg1.coll', 'data', 'uidx');
    prob = coco_add_func(prob, 'monitor', @Oscillator.monitor_sliding_begins, ...
        [], 'regular', 'sliding_begins', 'uidx',  ...
        [uidx(data.coll_seg.maps.x0_idx) uidx(data.coll_seg.maps.p_idx)]);
    prob = coco_add_event(prob, 'SL', 'sliding_begins', 0);
    coco(prob, 'fourseg1', [], 1, 'al', [1.0 1.6]);
    % Test results of first run
    bd    = coco_bd_read('fourseg1'); 
    labs  = coco_bd_labs(bd);         
    labSL = coco_bd_labs(bd, 'SL'); 
    if (numel(labs) < 1) 
        error("HSPO:VaryingSegment:Test","Run 'fourseg1' failed, no results!");
    elseif (numel(labSL) ~= 1)
        error("HSPO:VaryingSegment:Test","Run 'fourseg1' failed, no SL event found!");
    end
    % Second run 'sixseg1'
    [solSL,dataSL] = hspo_read_solution('', 'fourseg1', labSL); 
    p0 = solSL.p;           % Get alpha and beta
    x1 = solSL.xbp{1,1};    t1 = solSL.tbp{1,1};    % 1st segment: 1st segment of solSL
    x2 = solSL.xbp{1,2};    t2 = solSL.tbp{1,2};    % 2nd segment: 2nd segment of solSL
    x3 = [solSL.xbp{1,2}(end,:)];      t3 = [0];    % 3rd segment: single point (sliding)
    x4 = solSL.xbp{1,3};    t4 = solSL.tbp{1,3};    % 4th segment: 3rd segment of solSL
    x5 = solSL.xbp{1,4};    t5 = solSL.tbp{1,4};    % 5th segment: 4th segment of solSL
    x6 = [solSL.xbp{1,4}(end,:)];      t6 = [0];    % 6th segment: single point (sliding)
    modes  = {'uncontrolled' 'controlled' 'sliding' ...
              'uncontrolled' 'controlled' 'sliding'};
    events = {'mplus'        'mplus'      'escape' ...
              'mminus'       'mminus'     'escape'};
    resets = {'null' 'null' 'null' 'null' 'null' 'null'};
    t0 = {t1 t2 t3 t4 t5 t6};
    x0 = {x1 x2 x3 x4 x5 x6};
    prob = coco_prob();
    prob = ode_isol2hspo(prob, '', ...
        {@Oscillator.f, @Oscillator.events, @Oscillator.resets}, ...
        modes, events, resets, ...
        t0, x0, {'al' 'be'}, p0);
    [data, uidx] = coco_get_func_data(prob, 'hspo.orb.bvp.seg2.coll', 'data', 'uidx');
    prob = coco_add_func(prob, 'monitor', @Oscillator.monitor_ctrl_disappears, ...
        [], 'regular', 'ctrl_disappears', 'uidx', ...
        [uidx(data.coll_seg.maps.x0_idx) uidx(data.coll_seg.maps.p_idx)]);
    prob = coco_add_event(prob, 'CD', 'ctrl_disappears', 0);
    coco(prob, 'sixseg1', [], 1, 'al', [0.64 p0(1)]);
    bd    = coco_bd_read('sixseg1');  
    labs  = coco_bd_labs(bd);        
    labCD = coco_bd_labs(bd, 'CD');
    % Check second run
    if (numel(labs) < 1) 
        error("HSPO:VaryingSegment:Test","Run 'sixseg1' failed, no results!");
    elseif (numel(labCD) ~= 1)
        error("HSPO:VaryingSegment:Test","Run 'sixseg1' failed, no CD event found!");
    end
    % Third run 'fourseg2'
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
    prob = ode_isol2hspo(coco_prob(), '', ...
        {@Oscillator.f, @Oscillator.events, @Oscillator.resets}, ...
        modes, events, resets, ...
        t0, x0, {'al' 'be'}, p0);
    coco(prob, 'fourseg2', [], 1, 'al', [0.1 p0(1)]);
    bd   = coco_bd_read('fourseg2'); 
    labs = coco_bd_labs(bd);         
    if (numel(labs) < 1) 
        error("HSPO:VaryingSegment:Test","Run 'fourseg2' failed, no results!");
    end
    result = true;
catch MatlabException
    warning('There was an exception! Test failed!\nException: %s, \nMessage:%s',...
        MatlabException.identifier, MatlabException.message);
	result = false;
	return;
end % try
end % function