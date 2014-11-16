clear all;
close all;

% N_x=25;
% N_y=25;
% N=N_x*N_y;
length_x = 1;
length_y = 1;



%continuous load
f=@(x,y)-2*pi^2*sin(pi*x).*sin(pi*y);
%discrete load
with_boundaries=0;


solutions = struct();
%the indeces are defining the solution methods:
index_full_matrix   = 1;
index_sparse_matrix	= 2;
index_gauss_seidl	= 3;

method_name={'FullMatrix','SparseMatrix','GaussSeidl'};

N_x = [7 15 31 63];
N_y = [7 15 31 63];
number_of_grid_sizes = numel(N_x);
fig_id =1;

for method_id = 1:index_gauss_seidl 
    for current_grid_size = 1:number_of_grid_sizes
        current_N_x = N_x(current_grid_size);
        current_N_y = N_y(current_grid_size);
        b=build_solution_vector(current_N_x,current_N_y,f,with_boundaries);
        h_x = length_x/(current_N_x+1);
        h_y = length_y/(current_N_y+1);
        switch method_id
            case index_full_matrix
                tic;
                [weights_matrix, storage] = build_weights_matrix(current_N_x,current_N_y);
                T = weights_matrix \ b;
                runtime = toc;
                storage = 0;
            case index_sparse_matrix
                tic;
                [sparse_weights_matrix, storage] = build_sparse_weights_matrix(current_N_x,current_N_y);
                T = sparse_weights_matrix \ b;
                runtime = toc;
                storage = 0;
            case index_gauss_seidl
                tic;
                [T, storage] = solve_gauss_seidl(current_N_x,current_N_y, b);
                runtime = toc;
                storage = 0;
            otherwise 
                disp('No solution method specified for this method_id');
                break
        end   
    end
    
    T_analytic=@(x,y)sin(pi*x).*sin(pi*y);
    %calculate Error
%     E=error_norm(Z,T_analytic(x,y))

    
    
    
    solutions.(method_name{method_id}).N_x=current_N_x;
    solutions.(method_name{method_id}).N_y=current_N_y;
    %solutions.(method_name{method_id}).N_x.T_vector = T;
%     solutions.(method_name{method_id}).N_x.runtime = runtime;
%     solutions.(method_name{method_id}).N_x.storage = storage;
%     solutions.(method_name{method_id}).N_x.error = E;

    
    
    
    %visualize results
    
    %open figure
    figure(fig_id);
    hold on
    str_title = [method_name{method_id} '-Surface Plot: Temperatures for N_x = ' mat2str(current_N_x) ', N_y = ' mat2str(current_N_y)];
    title(str_title);
    
 
    %corresponding grid
    [x,y]=meshgrid([h_x:h_x:length_x-h_x],[h_y:h_y:length_y-h_y]);
    
    %convert solution from vector to matrix
    Z=zeros(current_N_y,current_N_x);
    for i = 1:numel(x)
        T_index=get_discrete_index(x(i),y(i),h_x,h_y,current_N_x,current_N_y,with_boundaries);
        Z(i)=T(T_index);
    end
    
    %Add homogeneous boundary values
    Z=[zeros(1,current_N_x+2);zeros(current_N_y,1),Z,zeros(current_N_y,1);zeros(1,current_N_x+2)];
    %Create grid for plotting
    [X,Y]=meshgrid([0:h_x:length_x],[0:h_y:length_y]);
    [XX,YY]=meshgrid([0:.1:length_x],[0:.1:length_y]);

    surf(X,Y,Z,'FaceColor','interp')
    mesh(XX,YY,T_analytic(XX,YY),'FaceColor','none')
    xlabel('x')
    ylabel('y')
    hold off
    
    fig_id = fig_id + 1;
    
    figure(fig_id)
    hold on
    str_title = [method_name{method_id} '-Contour Plot: Temperatures for N_x = ' mat2str(current_N_x) ', N_y = ' mat2str(current_N_y)];
    title(str_title);
    contour(X,Y,Z)
    xlabel('x')
    ylabel('y')
    hold off
    
    fig_id = fig_id + 1;

    Status= ['Values for N_x = ' mat2str(current_N_x) ', N_y = ' mat2str(current_N_y) ' calculated!']
end

    %Visualize Solutions
%     fig_id = 1;
% for method_id = [index_full_matrix,index_sparse_matrix,index_gauss_seidl]
%     visualize (solutions.(method_name{method_id}), fig_id);
%     fig_id=fig_id+1;
% end


% weights_matrix = build_weights_matrix(N_x,N_y);

% %solve System with MATLAB direct solver
% tic;
% T = weights_matrix \ b;
% toc;

%Now with sparse matrix. Differences are visible with higher values of Ny
%and Nx
% tic;
% T = sparse( weights_matrix ) \ b;
% toc;

% %corresponding grid
% [x,y]=meshgrid([h_x:h_x:length_x-h_x],[h_y:h_y:length_y-h_y]);
% 
% %convert solution from vector to matrix
% Z=zeros(current_N_y,current_N_x);
% for i = 1:numel(x)
%     T_index=get_discrete_index(x(i),y(i),h_x,h_y,current_N_x,current_N_y,with_boundaries);
%     Z(i)=T(T_index);
% end

% T_analytic=@(x,y)sin(pi*x).*sin(pi*y);
% %calculate Error
% E=error_norm(Z,T_analytic(x,y))
% 
% %Add homogeneous boundary values
% Z=[zeros(1,N_x+2);zeros(N_y,1),Z,zeros(N_y,1);zeros(1,N_x+2)];
% %Create grid for plotting
% [X,Y]=meshgrid([0:h_x:length_x],[0:h_y:length_y]);
% [XX,YY]=meshgrid([0:.1:length_x],[0:.1:length_y]);
% 
% figure(1)
% hold on
% title('solution of PDE')
% surf(X,Y,Z,'FaceColor','interp')
% mesh(XX,YY,T_analytic(XX,YY),'FaceColor','none')
% xlabel('x')
% ylabel('y')
% hold off
% 
% figure(2)
% hold on
% title('solution of PDE')
% contour(X,Y,Z)
% xlabel('x')
% ylabel('y')
% hold off


%Print Solutions

