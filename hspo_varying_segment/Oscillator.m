% Pend   COCO-compatible encoding of a hybrid system (1DoF, negative damping oscillator)
classdef Oscillator
properties
  % No data members (static class)
end
methods(Static)
    function y = f(x, p, mode)
        % Params: a:alpha (natural freq), d:delta (rel. damping)
        v = x(1,:); % v = xdot
        x = x(2,:);
        a = p(1);
        d = p(2);
        switch mode
          case 'uncontrolled'
            y(1,:) = -a^2.*x + 2*a*d.*v;
            y(2,:) = v;
          case 'controlled'
            M = sign(v).*1;
            y(1,:) = -a^2.*x + 2*a*d.*v-M;
            y(2,:) = v;
          case 'sliding'
            y(1,:) = zeros(1,numel(v));
            y(2,:) = v;
        end
    end
    function y = events(x, p, event)
        switch event
            case 'mplus'
              y = x(1,:)-1; % v == 1
            case 'mminus'
              y = x(1,:)+1; % v == -1
            case 'escape' 
              % Escape from sliding mode, when the uncontrolled dynamics no longer
              % pushes the trajectory towards the switching manifold, that is y'=0
              f = Oscillator.f(x, p, 'uncontrolled');
              y = f(1,:);
        end
    end
    function y = resets(x, p, reset)
        % Identity, no change
        y = x;
    end
    function [data,y] = monitor_sliding_begins(prob, data, u)
        % End of validity check, u(1:2) = [v x] at the beginning of the 1rd seg
        x = u(1:2);
        p = u(3:4);
        dy = Oscillator.f(x, p, 'uncontrolled');
        y = dy(1); % If dv is zero, sliding begins. 
    end
    function [data,y] = monitor_ctrl_disappears(prob, data, u)
        % Check when sliding mode 'devours' the controlled mode
        % u(1:2) = [v x] at the beginning of the 2nd segment
        x = u(1:2);
        p = u(3:4);
        dy = Oscillator.f(x, p, 'controlled');
        y = dy(1); % If dv is zero, sliding starts immediately without the controlled segment in the solution.
    end
end % end method defs
end % end class



