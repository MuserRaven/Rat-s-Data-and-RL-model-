
pL=[0.8*ones(3000,1); 0.4*ones(4000,1); 0.9*ones(3000,1)]; % Probability of Left Paying Off
pR=[0.4*ones(3000,1); 0.8*ones(4000,1); 0.2*ones(3000,1)]; % Probability of Right Paying Off 

qL=nan(10000,1); %Expected Value for Left
qR=nan(10000,1); %Exepected Value for Right

qL(1)=0; % Set initial Value to 0
qR(1)=0;

timesteps = 10000; 
A=nan(10000,1); % Action Matrix


R_L=nan(timesteps,1);% Left Reward
R_R=nan(timesteps,1); % Right Reward

BetaA1=nan;
BetaA2=nan;
BetaB1=nan;
BetaB2=nan;

b1=nan;
b2=nan;
x1=nan;
x2=nan;

BetaA11=nan(10000,1);
BetaA22=nan(10000,1);
BetaB11=nan(10000,1);
BetaB22=nan(10000,1);

b11=nan(10000,101);
b22=nan(10000,101);
x11=nan(10000,1);
x22=nan(10000,1);

 
a=0.1; %Epsilon

for t=1:100
     if randn>0.5 
       A(t)=1;
     else
       A(t)=2;
     end

       if A(t)==1 
        R_R(t) = rand <= pL(t);
        qR(t+1) = qR(t) + (R_R(t) - qR(t))/t;
        qL(t+1) = qL(t);
       elseif A(t)==2
        R_L(t) = rand <= pR(t);
        qL(t+1) = qL(t) + (R_L(t) - qL(t))/t;
        qR(t+1) = qR(t);
       end 
    
       BetaA1=sum(R_R(1:100)==1); % calculate the A,B for option L's for beta distribution
       BetaA2=sum(R_R(1:100)==0);% Beta2= total # of choice A - # of A gets rewards
       b1=betapdf(0:0.01:1,BetaA1,BetaA2); %beta distribution of Beta1 and Beta2
       x1=find(b1==randsample(b1,1)); %randomly sample one point from the distribution
       
       BetaB1=sum(R_L(1:100)==1); % calculate the A,B for option L's for beta distribution
       BetaB2=sum(R_L(1:100)==0);% Beta2= total # of no rewards
       b2=betapdf(0:0.01:1,BetaB1,BetaB2); %beta distribution of Beta1 and Beta2
       x2=find(b2==randsample(b2,1)); %randomly sample one point from the distribution
end  

for t=101:timesteps

       if x11(t)>x22(t)
             A(t)=1;

       elseif x11(t)<x22(t)
             A(t)=2;
       end 

       if A(t)==1 
        R_R(t) = rand <= pL(t);
        qR(t+1) = qR(t) + (R_R(t) - qR(t))/t;
        qL(t+1) = qL(t);

       else
         
        R_L(t) = rand <= pR(t);
        qL(t+1) = qL(t) + (R_L(t) - qL(t))/t;
        qR(t+1) = qR(t);
           
       end 
            
       BetaA11(t)= sum(R_R(1:t)==1); % # of time get reward
       BetaA22(t)= sum(R_R(1:t)==0);% Beta2=# of times get no reward
       b11(t,:)= betapdf(0:0.01:1,BetaA11(t),BetaA22(t)); %beta distribution of Beta1 and Beta2
       x11(t)= find(unique(b11(t,:))==randsample(unique(b11(t,:)),1));%randomly sample one point from the distribution and get its corresponding x value
       % The unique function here is to sift out the repeating values in
       % b11(t,:),
       BetaB11(t)= sum(R_L(1:t)==1);
       BetaB22(t)= sum(R_L(1:t)==0);
       b22(t,:)= betapdf(0:0.01:1,BetaB11(t),BetaB22(t)); 
       x22(t)= find(unique(b22(t,:))==randsample(unique(b22(t,:)),1));
 end

plot(1:10001,qL,LineWidth=1.5)
hold on
plot(1:10001,qR,LineWidth=1.5)