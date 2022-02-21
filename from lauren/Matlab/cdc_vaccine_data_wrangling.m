%% COVID-19 vaccination data wrangling
% Data set from CDC, comprehensive historical data of vaccine distribution
% in US territory

filename = 'COVID-19_Vaccinations_in_the_United_States_Jurisdiction.csv';
T = readtable(filename);
G = findgroups(T{:,1});
%Tc = splitapply(@(varagin) varagin,T,G);

vaccine_data = flip(COVID19VaccinationsintheUnitedStatesJurisdiction(:,:));

california = vaccine_data(1332:1553,:);
texas = vaccine_data(11955:12176,:);
US = vaccine_data(12177:12399,:);

writetable(california,"COVID-19_Vaccinations_California.csv")
writetable(texas, "COVID-19_Vaccinations_Texas.csv")
writetable(US, "COVID-19_Vaccinations_US.csv")
fprintf("Tables are done");