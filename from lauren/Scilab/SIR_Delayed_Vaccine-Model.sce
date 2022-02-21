// SIR Model with a vaccine and a time delay (vaccine is introduced later on)
// Spread of disease is dependent on S,I and R and Vaccine
// Vaccine allows Susceptible --> Recovered/Removed, bypassing Infection
// Assume people are vaccinated at a constant rate
// 

// Parameters
I0 = 0.0004; //Initial proportion infected
a = 0.4; // Infected Coefficient in weeks ^-1 
b = 0.1; // Removal Coefficient in weeks^-1
dv = 0.3; // Vaccine rate per week
tdelay = 30; // Time Delay to vaccine ready in weeks 
tmax = 52; // Number of weeks
Imax = 1.1; // Max proportion infected for graph 
dt = .01; 
plotchoice = 4; // 1 = Susceptible, 2 = Infected, 3 = Recovered, 4 = ALL

// Vectors
t = 0:dt:tmax; // time vector
Nt = length(t); // numher of time steps
S = zeros(1,Nt); // susceptible vector 
I = zeros(1,Nt); // infection vector
R = zeros(1,Nt); // recovered vector
I(1)= I0; // initial infection value

// Calculations 
for it = 1:Nt-1
    S(it)=1-I(it)-R(it);
    dI = a*I(it)*S(it)-b*I(it); 
    I(it + 1) = I(it)+ dI*dt; 
    if (S(it)> 0 && t(it)>=tdelay)
        dR = b*I(it)+dv;
    else 
        dR = b*I(it);
    end 
    R(it+1)= R(it)+ dR*dt;       
end
S(Nt) = 1-I(Nt)-R(Nt);

// Plot 
switch plotchoice 
case 1 // S vs Time
     plot(t,S,'b')
    xtitle("SIR - Model: Proportion of Susceptible vs. Time","Time (Weeks)","Proportion of Susceptible")
    xgrid(1)  
case 2 // I vs Time
    plot(t,I,'r')
    xtitle("SIR - Model: Proportion of Infected vs. Time","Time (Weeks)","Proportion Infected")
    xgrid(1)  
case 3 // R vs Time
    plot(t,R,'m')
    xtitle("SIR - Model: Proportion of Recovered vs. Time","Time (Weeks)","Proportion Recovered")
case 4 /// SIR vs Time
     plot(t,S,'b')
     plot(t,I,'r')
     plot(t,R,'m')
    xtitle("SIR - Model: Proportion of Susceptible, Recovered and Infected vs. Time","Time (Weeks)","Proportion of Susceptible,Infected and Recovered")
    xgrid(1)  
    h1=legend(['S';'I';'R'])
end

