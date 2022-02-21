// SI Model
// Spread of disease is dependent on S and I
// People infected stay infected and contagious
// Transimssion rate is proportional to S*I
// I = logistic growth
// I + S = 1 (100% of Population)
// S = 1-I 
 

// Parameters
I0 = 0.001; //Initial proportion infected
a = 1.25; // Infection Coefficient in weeks ^-1 
tmax = 10; // Number of weeks
Imax = 1.1; // Max proportion infected for graph 
dt = .01; 
plotchoice = 3; // 1 = Susceptible, 2 = Infected , 3 = ALL
// Vectors
t = 0:dt:tmax; // time vector
Nt = length(t); // numher of time steps
S = zeros(1,Nt); // susceptible vector 
I = zeros(1,Nt); // infection vector
I(1)= I0; // initial infection value

// Calculations 
for it = 1:Nt-1
    S(it)=1-I(it);
    dI = a*I(it)*S(it); // rate of change per week 
    I(it + 1) = I(it)+ dI*dt;        
end
S(Nt) = 1-I(Nt);
// Plot 
switch plotchoice 
case 1 // S vs Time
     plot(t,S,'b')
    xtitle("SI - Model: Proportion of Susceptible vs. Time","Time (Weeks)","Proportion of Susceptible")
    xgrid(1)  
case 2 // I vs Time
    plot(t,I,'r')
    xtitle("SI - Model: Proportion of Infected vs. Time","Time (Weeks)","Proportion Infected")
    xgrid(1)  
case 3 // SI vs Time
     plot(t,S,'b')
     plot(t,I,'r')
    xtitle("SI - Model: Proportion of Susceptible and Infected vs. Time","Time (Weeks)","Proportion of Susceptible and Infected")
    xgrid(1)  
    h1 = legend(['S';'I'])
end

