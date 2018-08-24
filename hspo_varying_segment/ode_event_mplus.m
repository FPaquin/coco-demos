function [position,isterminal,direction] = ode_event_mplus(t,y)
position = y(1)-1; % y == 1
isterminal = 1;    % Halt integration 
direction = 0;     % from either direction
end