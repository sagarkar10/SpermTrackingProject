function [beta] = iteratedMultiAssignment(T, M, r, tau, L)

% % // If Tracks and Measurements are not empty sets
% if (~isempty(T) || ~isempty(M))
%     
%     Tn = length(T);
%     
%     % // For each Track in T    
%     for 1:Tn
%         
%         
%         
%         
%     end
%     
%         
%     
%     
% end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
%
%   Calculate negative log likelihood ratio (NLLR) cost matrix A
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %

% Negative log likelihood ratio matrix
A = -log(LR);

% Number of measurements Nm, number of tracks Nt
[m, n] = size(A);

% Round 1
[S, V] = munkres(A)


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
%
%   Find N-best assignments using Murty's method
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %

% Initial problem
P0 = A_orig;

% Initial (0-th) optimal assignment
[S0, V0] = munkres(P0);

% Number of Solutions to Find
if (m == 1)
    SOLUTIONS{1} = S0;    
else
    % Calculate the N-best solutions - here, N = 25
    SOLUTIONS = murtys_best(P0, S0, V0, 1000);
end


% Number of events found
num_events = length(SOLUTIONS);
        

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
%
%   Calculate the Probability of Each Joint Event
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %

for N = 1:num_events
    
    % Hadamard product of L and the N-th best ranked assignment    
    THETA = LR .* SOLUTIONS{N};
    
    % Find the individual assignment likelihoods 
    [tau_j, delta_t, L_jt] = find(THETA);
    
    % First term of P{theta | z^k}
    term1 = prod(L_jt);    
    
    % Second term of P{theta | z^k}
    term2 = (PD)^(length(tau_j)) * (1 - PD)^(n - length(delta_t));
    
    % Probability of joint event
    P_THETA{N} = term1 * term2;
    
end

% Calculate the normalization constant c
c = sum(cell2mat(P_THETA));

% Normalize the probabilities
for N = 1:num_events
    
    P_THETA{N} = P_THETA{N}/c;
    
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
%
%   Calculate the Joint Association Probability
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %

% Initialize the beta matrix
beta = zeros(m,n);

% For each target
for t = 1:n
    
    % For each measurement
    for j = 1:m
        
        % For each association event 
        for N = 1:num_events
                    
            beta(j,t) = beta(j,t) + P_THETA{N} * SOLUTIONS{N}(j,t);
            
        end        

    end
    
end