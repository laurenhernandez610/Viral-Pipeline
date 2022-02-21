%% Summer Project 2020: Interacting cities and infections between cities
% Setting up three cities where nobody is infected
N = 100;
City_A = zeros(1,N);
City_B = zeros(1,N);
City_C = zeros(1,N);

% Intentionally "exposing" one person from each city
City_A(randi(numel(City_A))) = 1;
City_B(randi(numel(City_B))) = 1;
City_C(randi(numel(City_C))) = 1;

% Option 2: Randomly "exposing" one person from one city
City_Matrix = zeros(3,N);
City_Matrix(randi(numel(City_Matrix)))= 1;

% Applied a random probability that that initial infected person actually
% becomes infected 

M = rand(3,100); % Random decimal matrix

Cities = [City_A; % Turned cities into a 3 row matrix bc why not
    City_B;
    City_C];

First_Round_City_Matrix = M.*City_Matrix; % Applied a random decimal probability to the individual who was exposed

First_Round_Cities = M.*Cities; % Applied a random decimal probability to the individual who was exposed






F = [];

i = 1;
j = 1;
while  1:size(FirstRound,1)  % For the rows
    while 1:1:size(FirstRound,N) % For the columns
    
           if First_Round(i,j) > 0.6    %FirstRound is my matrix
            First_Round(i,j) = 1;
            
           else First_Round(i,j) <= 0.6   
               First_Round(i,j) = 0;
      
           end
    
    end
    F = [First_Round(i,j)];
end 


















