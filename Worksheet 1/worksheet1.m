close all;
clear all;

euler_index = 1;
heun_index = 2;
runge_kutta_index = 3;

t_end = 5;

tau = [1/8,1/4,1/2,1];
tau_count = numel( tau );

E = struct();
num_sol = struct();

E.error.euler = zeros( tau_count, 1 );
E.error.heun = zeros( tau_count, 1 );
E.error.rungekutta = zeros( tau_count, 1 );

E.approx_error.euler = zeros( tau_count, 1 );
E.approx_error.heun = zeros( tau_count, 1 );
E.approx_error.rungekutta = zeros( tau_count, 1 );

E.red_error.euler = 0;
E.red_error.heun = 0;
E.red_error.rungekutta = 0;

E.red_factor.euler = zeros( tau_count, 1 );
E.red_factor.heun = zeros( tau_count, 1 );
E.red_factor.rungekutta = zeros( tau_count, 1 );

schemes_count = 3;
y0=1;
y_best = 0;
t_best = 0;
curr_errors_ana = zeros( schemes_count, 1 );

for current_tau_index = 1:tau_count
    curr_tau=tau(current_tau_index);
    t=0:curr_tau:t_end;
    
    if ~y_best
        y_best = zeros(schemes_count,size(t,2));
        t_best= zeros(schemes_count,size(t,2));
    end
    
    [t_ee,y_ee] = explicit_euler( @dp, y0, curr_tau, t_end );
    [t_h,y_h] = heun( @dp, y0, curr_tau, t_end );
    [t_rk,y_rk] = runge_kutta_4( @dp, y0, curr_tau, t_end );
    
    y_num = zeros( schemes_count, size(t,2) );
    y_num( euler_index, : ) = y_ee;
    y_num( heun_index, : ) = y_h;
    y_num( runge_kutta_index , : ) = y_rk;
    
    t_num = zeros( size( y_num ) );
    t_num( euler_index, : ) = t_ee;
    t_num( heun_index, : ) = t_h;
    t_num( runge_kutta_index, : ) = t_rk;
    
    str_tau=sprintf('tau%i',current_tau_index);
    
    num_sol.euler.(str_tau).tau=curr_tau;
    num_sol.euler.(str_tau).y=y_ee;
    num_sol.euler.(str_tau).t=t_ee;
    num_sol.heun.(str_tau).tau=curr_tau;
    num_sol.heun.(str_tau).y=y_h;
    num_sol.heun.(str_tau).t=t_h;
    num_sol.rungekutta.(str_tau).tau=curr_tau;
    num_sol.rungekutta.(str_tau).y=y_rk;
    num_sol.rungekutta.(str_tau).t=t_rk;
    
    for i = 1:schemes_count
        curr_errors_ana(i) = Error_norm( y_num(i,:), p(t_num(i,:)), curr_tau, t_end);
    end
    
    E.error.euler( current_tau_index ) = curr_errors_ana( euler_index );
    E.error.heun( current_tau_index ) = curr_errors_ana( heun_index );
    E.error.rungekutta( current_tau_index ) = curr_errors_ana( runge_kutta_index );
    
    [t_ee_halved,y_ee_halved] = explicit_euler( @dp, y0, curr_tau/2, t_end );
    [t_h_halved,y_h_halved] = heun( @dp, y0, curr_tau/2, t_end );
    [t_rk_halved,y_rk_halved] = runge_kutta_4( @dp, y0, curr_tau/2, t_end );
    
    if current_tau_index == 1 %%Case when curr_tau is minimum
        E.red_error.euler = Error_norm( y_ee_halved , p(t_ee_halved), curr_tau/2, t_end);
        E.red_error.heun = Error_norm(y_h_halved, p(t_h_halved), curr_tau/2, t_end);
        E.red_error.rungekutta = Error_norm( y_rk_halved, p(t_rk_halved), curr_tau/2, t_end);
        
        E.red_factor.euler( current_tau_index ) = E.error.euler( current_tau_index ) / E.red_error.euler;
        E.red_factor.heun( current_tau_index ) = E.error.heun( current_tau_index ) / E.red_error.heun;
        E.red_factor.rungekutta( current_tau_index ) = E.error.rungekutta( current_tau_index ) / E.red_error.rungekutta;
    else
        E.red_factor.euler( current_tau_index ) = E.error.euler( current_tau_index ) / E.error.euler( current_tau_index - 1 );
        E.red_factor.heun( current_tau_index ) = E.error.heun( current_tau_index ) / E.error.heun( current_tau_index - 1 );
        E.red_factor.rungekutta( current_tau_index ) = E.error.rungekutta( current_tau_index ) / E.error.rungekutta( current_tau_index - 1 );
    end
    
    
    if current_tau_index == 1 %%Case when curr_tau is minimum
        y_best=y_num;
        t_best=t_num;
        E.approx_error.euler(current_tau_index)=0;
        E.approx_error.heun(current_tau_index)=0;
        E.approx_error.rungekutta(current_tau_index)=0;
    else
        y_best_interpolated = zeros( schemes_count, numel( y_num( euler_index, : ) ) );
        
        for i=1:schemes_count
            y_best_interpolated(i,:) = interp1( t_best(i,:), y_best(i,:), t_num(i,:));
        end
        
        E.approx_error.euler(current_tau_index) = Error_norm( y_ee,y_best_interpolated(euler_index,:),...
            curr_tau,t_end);
        E.approx_error.heun(current_tau_index) = Error_norm(y_h,y_best_interpolated(heun_index,:),...
            curr_tau,t_end);
        E.approx_error.rungekutta(current_tau_index) = Error_norm(y_rk,y_best_interpolated(runge_kutta_index,:),...
            curr_tau,t_end);
    end
    
end

%Printing of the results

fprintf('Error comparing to exact solution:\n')
fprintf('----------------------------------------------------------------------------\n')
fprintf('tau              |%d\t\t\t\t%d\t%d\t%d\n',tau(end:-1:1))
fprintf('explicit euler   |%d\t%d\t%d\t%d\n',E.error.euler(end:-1:1))
fprintf('heun             |%d\t%d\t%d\t%d\n',E.error.heun(end:-1:1))
fprintf('rungekutta       |%d\t%d\t%d\t%d\n',E.error.rungekutta(end:-1:1))
fprintf('----------------------------------------------------------------------------\n\n')

fprintf('Error reduction:\n')
fprintf('----------------------------------------------------------------------------\n')
fprintf('tau              |%d\t\t\t\t%d\t%d\t%d\n',tau(end:-1:1))
fprintf('explicit euler   |%d\t%d\t%d\t%d\n',E.red_factor.euler(end:-1:1))
fprintf('heun             |%d\t%d\t%d\t%d\n',E.red_factor.heun(end:-1:1))
fprintf('rungekutta       |%d\t%d\t%d\t%d\n',E.red_factor.rungekutta(end:-1:1))
fprintf('----------------------------------------------------------------------------\n\n')

fprintf('Error comparing to best numerical solution:\n')
fprintf('----------------------------------------------------------------------------\n')
fprintf('tau              |%d\t\t\t\t%d\t%d\t%d\n',tau(end:-1:1))
fprintf('explicit euler   |%d\t%d\t%d\t%d\n',E.approx_error.euler(end:-1:1))
fprintf('heun             |%d\t%d\t%d\t%d\n',E.approx_error.heun(end:-1:1))
fprintf('rungekutta       |%d\t%d\t%d\t%d\n',E.approx_error.rungekutta(end:-1:1))
fprintf('----------------------------------------------------------------------------\n\n')

%plot of analytical p(t)
figure(1)
hold on
title('p(t)')
plot(0:.1:t_end,p(0:.1:t_end),'k')
xlabel('t')
ylabel('p(t)')
hold off

%plot of numerical solutions using explicit euler method
figure(2)
hold on
title('numerical solution of dp=(1-p/10)*p using explicit euler method');
h_ana=plot(0:.1:t_end,p(0:.1:t_end),'k');
col={'r.','rx','r*','rs'};
for i = 1:4    
    field_name=sprintf('tau%i',i);
    h(i)=plot(num_sol.euler.(field_name).t,num_sol.euler.(field_name).y,col{i});
end
legend([h_ana,h],'analytical solution',...
    ['numerical solution for tau=',mat2str(num_sol.euler.tau1.tau)],...
    ['numerical solution for tau=',mat2str(num_sol.euler.tau2.tau)],...
    ['numerical solution for tau=',mat2str(num_sol.euler.tau3.tau)],...
    ['numerical solution for tau=',mat2str(num_sol.euler.tau4.tau)]);
xlabel('t')
ylabel('p(t)')
hold off

%plot of numerical solutions using heun method
figure(3)
hold on
title('numerical solution of dp=(1-p/10)*p using heun method');
h_ana=plot(0:.1:t_end,p(0:.1:t_end),'k');
col={'b.','bx','b*','bs'};
for i = 1:4    
    field_name=sprintf('tau%i',i);
    h(i)=plot(num_sol.heun.(field_name).t,num_sol.heun.(field_name).y,col{i});
end
legend([h_ana,h],'analytical solution',...
    ['numerical solution for tau=',mat2str(num_sol.heun.tau1.tau)],...
    ['numerical solution for tau=',mat2str(num_sol.heun.tau2.tau)],...
    ['numerical solution for tau=',mat2str(num_sol.heun.tau3.tau)],...
    ['numerical solution for tau=',mat2str(num_sol.heun.tau4.tau)]);
xlabel('t')
ylabel('p(t)')
hold off

%plot of numerical solutions using runge-kutta method
figure(4)
hold on
title('numerical solution of dp=(1-p/10)*p using runge-kutta method');
h_ana=plot(0:.1:t_end,p(0:.1:t_end),'k');
col={'g.','gx','g*','gs'};
for i = 1:4    
    field_name=sprintf('tau%i',i);
    h(i)=plot(num_sol.rungekutta.(field_name).t,num_sol.rungekutta.(field_name).y,col{i});
end
legend([h_ana,h],'analytical solution',...
    ['numerical solution for tau=',mat2str(num_sol.rungekutta.tau1.tau)],...
    ['numerical solution for tau=',mat2str(num_sol.rungekutta.tau2.tau)],...
    ['numerical solution for tau=',mat2str(num_sol.rungekutta.tau3.tau)],...
    ['numerical solution for tau=',mat2str(num_sol.rungekutta.tau4.tau)]);
xlabel('t')
ylabel('p(t)')
hold off

%comparison of the error
figure(5)
hold on

title('Error Plot')
xlabel('tau')
ylabel('Error')

h_euler_error = plot( tau, E.error.euler, 'rx' );
plot( tau, E.error.euler, 'r' );
h_heun_error = plot( tau,E.error.heun,'bx' );
plot( tau, E.error.heun, 'b' );
h_rungekutta_error = plot( tau, E.error.rungekutta, 'gx' );
plot( tau, E.error.rungekutta, 'g');

h_euler_approx_error = plot( tau, E.approx_error.euler, 'r*' );
plot( tau, E.approx_error.euler, 'r' );
h_heun_approx_error = plot( tau, E.approx_error.heun, 'b*' );
plot( tau,E.approx_error.heun,'b');
h_rungekutta_approx_error=plot(tau,E.approx_error.rungekutta,'g*');
plot( tau,E.approx_error.rungekutta,'g');

legend([h_euler_error,h_heun_error,h_rungekutta_error,h_euler_approx_error,...
        h_heun_approx_error,h_rungekutta_approx_error],...
        'Error explicit euler analytical',...
        'Error heun analytical',...
        'Error runge kutta analytical',...
        'Error explicit euler numerical',...
        'Error heun numerical',...
        'Error runge kutta numerical');

% set(gca,'Xscale','log')
% set(gca,'Yscale','log')

hold off