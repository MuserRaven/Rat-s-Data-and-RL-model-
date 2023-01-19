figure
N=9000;

pL=0.3; % Probability of Left Paying Off
pR=0.9; % Probability of Right Paying Off 
qL=nan(N,1); %Expected Value for Left
qR=nan(N,1); %Expected Value for Right

qL(1)=0; % Set initial Value to 0
qR(1)=0;

Left=nan(N,1);
Right=nan(N,1);

timesteps = N; 
A=nan(N,1); % Action Matrix
R=nan(N,1);% Reward Matrix 

e=0.1; %Epsilon
a=0.01; %Fix alpha value  

 for t=1:timesteps 
     if qL(t)==qR(t) || randn<e
        % choose actions randomly if qL=qR 
       A(t)=randsample([1 0], 1);
     else
        if Left(t)>=Right(t)
        
        A(t)=1;
       
        else

        A(t)=0;

        end
    end

    Left(t)=qL(t)+sqrt(2*log(t)/sum(A(1:t)==1));
    Right(t)=qR(t)+sqrt(2*log(t)/sum(A(1:t)==0));

    if A(t)==1 
        R(t) = rand <= pL;
        qL(t+1) = qL(t) + a*(R(t) - qL(t)); % Payoff function
        qR(t+1) = qR(t);
    else
        R(t) = rand <= pR;
        qR(t+1) = qR(t) + a*(R(t) - qR(t)); % Payoff function
        qL(t+1) = qL(t);
    end
end
plot(1:N+1,qL,LineWidth=1)% I guess the reason why R is complete ignored after 7000 trials is because 
hold on
plot(1:N+1,qR,LineWidth=1)
legend('qL','qR')
title('Upper Confidence B Method','Temporal discounting Alpha=0.01 e=0.1',FontSize=12)
ylabel('Expected Payoff',Fontsize=12)
xlabel('# of Turns',Fontsize=12)