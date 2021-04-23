function LLR = BCJRdec(cwN,Eb,sigma,aPriori)
% this function accepts a noisy codeword and decodes it using the trellis
% of the convolutional encoder in Fig. 1
% set aPriori to 'equal' if the apriori input bits are statistically equal.

    % initialize parameters
    trelLen = numel(cwN)/2; 
    alpha = zeros([4,trelLen+1]); % each row correponds to trellis state
    beta  = zeros([4,trelLen+1]); % each col is the time instant
    gam0000 = zeros([1,trelLen]);
    gam0010 = zeros([1,trelLen]);
    gam1001 = zeros([1,trelLen]);
    gam1011 = zeros([1,trelLen]);
    gam0100 = zeros([1,trelLen]);
    gam0110 = zeros([1,trelLen]);
    gam1101 = zeros([1,trelLen]);
    gam1111 = zeros([1,trelLen]);
    LLR = zeros([1,trelLen]);
    
    % set the initial conditions
    alpha(1,1) = 1; 
    beta(1,trelLen+1) = 1; 
    C2 = 1 / (2*pi*sigma)^2*exp(-2*Eb/(sigma^2));
    if sigma <.07
        sigma = .07; % prevent overflow errors. 
    end
    
    
    % iteratively compute alphas 
    for k = 1 : 1 : trelLen
        % get recieved symbol at time t
        y_t1 = cwN(2*k-1);
        y_t2 = cwN(2*k); 
        
        % set the prior bit probabilities for time t
        if strcmp(aPriori,'equal')
            p1 = .5;
            p0 = .5; 
            L = log(p1/p0);
        else
            L = aPriori(k);
        end
        C1 = exp(-L/ 2) / (1+exp(-L/2));
%         if isnan(C1)
%             if L<0
%                 C1 = -realmax;
%             else
%                 C1 = realmax; 
%             end
%         end
        C = C1 * C2; 
        
        % compute each gamma for the forward probability
        % 00 to 00 (input bit -1)
        gam0000(k) = C*exp(-1 * L/2) * exp(Eb/(sigma^2)*( y_t1*(-1)+y_t2*(-1)));
        
        % 00 to 10 (input bit +1)
        gam0010(k) = C*exp(1 * L/2) * exp(Eb/(sigma^2)*( y_t1*(1)+y_t2*(1)));
        
        % 10 to 01 (input bit -1)
        gam1001(k) = C*exp(-1 * L/2) * exp(Eb/(sigma^2)*( y_t1*(-1)+y_t2*(-1)));

        % 10 to 11 (input bit +1)
        gam1011(k) = C*exp(1 * L/2) * exp(Eb/(sigma^2)*( y_t1*(1)+y_t2*(1)));
        
        % 01 to 00 (input bit -1)
        gam0100(k) = C*exp(-1 * L/2) * exp(Eb/(sigma^2)*( y_t1*(1)+y_t2*(-1)));

        % 01 to 10 (input bit +1)
        gam0110(k) =  C*exp(1 * L/2) * exp(Eb/(sigma^2)*( y_t1*(-1)+y_t2*(1)));

        % 11 to 01 (input bit -1)
        gam1101(k) = C*exp(-1 * L/2) * exp(Eb/(sigma^2)*( y_t1*(1)+y_t2*(-1)));
        
        % 11 to 11 (input bit +1)
        gam1111(k) = C*exp(1 * L/2) * exp(Eb/(sigma^2)*( y_t1*(-1)+y_t2*(1)));
        
        % compute the alphas
        % state 00 alpha
        alpha(1,k+1) = alpha(1,k)*gam0000(k) + alpha(3,k)*gam0100(k); 
        % state 10 alpha
        alpha(2,k+1) = alpha(1,k)*gam0010(k) + alpha(3,k)*gam0110(k); 
        % state 01 alpha
        alpha(3,k+1) = alpha(2,k)*gam1001(k) + alpha(4,k)*gam1101(k); 
        % state 11 alpha 
        alpha(4,k+1) = alpha(4,k)*gam1111(k) + alpha(2,k)*gam1011(k);
        
        % normalize the alphas to stop computational overflow errors
        alpha(:,k+1) = alpha(:,k+1) / sum(alpha(:,k+1));
    end 
    
    % back compute the betas (probably something wrong with the betas)
    for k = trelLen:-1:1
        
        % compute the betas
        % state 00 beta
        beta(1,k) = beta(1,k+1)*gam0000(k) + beta(2,k+1)*gam0010(k); 
        % state 10 beta
        beta(2,k) = beta(4,k+1)*gam1011(k) + beta(3,k+1)*gam1001(k); 
        % state 01 beta
        beta(3,k) = beta(1,k+1)*gam0100(k) + beta(2,k+1)*gam0110(k); 
        % state 11 beta 
        beta(4,k) = beta(4,k+1)*gam1111(k) + beta(3,k+1)*gam1101(k);
        
        % normalize the betas to stop computational overflow errors
        beta(:,k) = beta(:,k) / sum(beta(:,k));
    end
    
    % compute the LLR output of decoder
    for k = 1 : 1 : trelLen
        sig1 = alpha(1,k)*gam0010(k)*beta(2,k+1)+alpha(2,k)*gam1011(k)*beta(4,k+1)...
              +alpha(3,k)*gam0110(k)*beta(2,k+1)+alpha(4,k)*gam1111(k)*beta(4,k+1); %sigma_t(m',m) associated with 1 bit
        sig0 = alpha(1,k)*gam0000(k)*beta(1,k+1)+alpha(2,k)*gam1001(k)*beta(3,k+1)...
              +alpha(3,k)*gam0100(k)*beta(1,k+1)+alpha(4,k)*gam1101(k)*beta(3,k+1); %sigma_t(m',m) associated with 0 bit
        LLR(k) = log(sig1/sig0);
    end
end