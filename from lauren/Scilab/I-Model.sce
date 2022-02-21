// I Model
// Spread is only dependendt on I
// Good model for beginning of disease spread 
// Infected people stay infected
// Infinite pool of people
// Two infected people do not interact

// Parameters
I0 = 10; //Initial number of infected 
a = 0.25; // Infected Coefficient in weeks ^-1 
tmax = 10; // Number of weeks
Imax = 1e6; // Max number infected for graph 
dt = .01; // Time Step 

// Vectors
t = 0:dt:tmax; // time vector
Nt = length(t); // numher of time steps
I = zeros(1,Nt); // infection vector
I(1)= I0; // initial infection value

// Calculations 
for it = 1:Nt-1
    dI = a*I(it); // rate of change per week 
    I(it + 1) = I(it)+ dI*dt;        
end

// Plot 

plot(t,I) // I vs Time
xtitle("I - Model: Number of Infections vs. Time","Time (Weeks)","Number Infected");
xgrid(1)

