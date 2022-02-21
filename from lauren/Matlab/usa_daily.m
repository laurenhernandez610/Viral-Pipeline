%% COVID-19 DATA PULLED FROM THE CDC
% NURSING HOME DATA & USA DATA
% DATA CATEGORIES: VACCINE, DEATH, CASE

% ---------- PULLING LOCALLY SAVED DATA -----------------------------------
% NOTE: Need to modify later to be more efficient 

nursing_nationwide_weekly = readtable('nursing_nationwide_21-04-16.csv',"VariableNamingRule","preserve");

vaccines_US_daily = readtable('trends_in_number_of_covid19_vaccinations_US.csv',"VariableNamingRule","preserve");

vaccines_LTC_daily = readtable('trends_in_number_of_covid19_vaccinations_in_LTC.csv',"VariableNamingRule","preserve");

cases_US_daily = readtable('case_daily_trends__united_states.csv',"VariableNamingRule","preserve");

deaths_US_daily = readtable('death_daily_trends__united_states.csv',"VariableNamingRule","preserve");

% -------------------------------------------------------------------------
% Making data sets so they read old:new for timeseries plot 

vaccines_US_daily = flip(vaccines_US_daily);

vaccines_LTC_daily = flip(vaccines_LTC_daily);

cases_US_daily = flip(cases_US_daily);

deaths_US_daily = flip(deaths_US_daily);

nursing_nationwide_weekly = nursing_nationwide_weekly(:,2:19);
% -------------------------------------------------------------------------
% Making weekly data into daily data 
% NOTE: Should optimize later

nursing_nationwide_weekly = table2array(nursing_nationwide_weekly);

nursing_nationwide_weekly = nursing_nationwide_weekly(:,:)./7;

new_mat = ones(117,3); 

new_mat(1:7,1) = nursing_nationwide_weekly(1,1);
new_mat(1:7,2) = nursing_nationwide_weekly(1,2);
new_mat(1:7,3) = nursing_nationwide_weekly(1,3);
new_mat(8:14,1) = nursing_nationwide_weekly(2,1);
new_mat(8:14,2) = nursing_nationwide_weekly(2,2);
new_mat(8:14,3) = nursing_nationwide_weekly(2,3);
new_mat(15:21,1) = nursing_nationwide_weekly(3,1);
new_mat(15:21,2) = nursing_nationwide_weekly(3,2);
new_mat(15:21,3) = nursing_nationwide_weekly(3,3);
new_mat(22:28,1) = nursing_nationwide_weekly(4,1);
new_mat(22:28,2) = nursing_nationwide_weekly(4,2);
new_mat(22:28,3) = nursing_nationwide_weekly(4,3);
new_mat(29:35,1) = nursing_nationwide_weekly(5,1);
new_mat(29:35,2) = nursing_nationwide_weekly(5,2);
new_mat(29:35,3) = nursing_nationwide_weekly(5,3);
new_mat(36:42,1) = nursing_nationwide_weekly(6,1);
new_mat(36:42,2) = nursing_nationwide_weekly(6,2);
new_mat(36:42,3) = nursing_nationwide_weekly(6,3);
new_mat(43:49,1) = nursing_nationwide_weekly(7,1);
new_mat(43:49,2) = nursing_nationwide_weekly(7,2);
new_mat(43:49,3) = nursing_nationwide_weekly(7,3);
new_mat(50:56,1) = nursing_nationwide_weekly(8,1);
new_mat(50:56,2) = nursing_nationwide_weekly(8,2);
new_mat(50:56,3) = nursing_nationwide_weekly(8,3);
new_mat(57:63,1) = nursing_nationwide_weekly(9,1);
new_mat(57:63,2) = nursing_nationwide_weekly(9,2);
new_mat(57:63,3) = nursing_nationwide_weekly(9,3);
new_mat(64:70,1) = nursing_nationwide_weekly(10,1);
new_mat(64:70,2) = nursing_nationwide_weekly(10,2);
new_mat(64:70,3) = nursing_nationwide_weekly(10,3);
new_mat(71:77,1) = nursing_nationwide_weekly(11,1);
new_mat(71:77,2) = nursing_nationwide_weekly(11,2);
new_mat(71:77,3) = nursing_nationwide_weekly(11,3);
new_mat(78:84,1) = nursing_nationwide_weekly(12,1);
new_mat(78:84,2) = nursing_nationwide_weekly(12,2);
new_mat(78:84,3) = nursing_nationwide_weekly(12,3);
new_mat(85:91,1) = nursing_nationwide_weekly(13,1);
new_mat(85:91,2) = nursing_nationwide_weekly(13,2);
new_mat(85:91,3) = nursing_nationwide_weekly(13,3);
new_mat(92:98,1) = nursing_nationwide_weekly(14,1);
new_mat(92:98,2) = nursing_nationwide_weekly(14,2);
new_mat(92:98,3) = nursing_nationwide_weekly(14,3);
new_mat(99:105,1) = nursing_nationwide_weekly(15,1);
new_mat(99:105,2) = nursing_nationwide_weekly(15,2);
new_mat(99:105,3) = nursing_nationwide_weekly(15,3);
new_mat(106:112,1) = nursing_nationwide_weekly(16,1);
new_mat(106:112,2) = nursing_nationwide_weekly(16,2);
new_mat(106:112,3) = nursing_nationwide_weekly(16,3);
new_mat(113:117,1) = nursing_nationwide_weekly(17,1);
new_mat(113:117,2) = nursing_nationwide_weekly(17,2);
new_mat(113:117,3) = nursing_nationwide_weekly(17,3);

new_mat = array2table(new_mat);

% -------------------------------------------------------------------------
% Organizing a few initial matricies for conveinence

vaccines_LTC_daily_1 = vaccines_LTC_daily(1:117, [2 4:6 15]);

USA_daily = [vaccines_US_daily(1:117,[2 4:6 15]) cases_US_daily(327:443,2) deaths_US_daily(327:443,2)];

nursing_nationwide_weekly = nursing_nationwide_weekly(30:46,[4 10 14]);

nursing_nationwide_daily = [vaccines_LTC_daily_1(:,1) new_mat(:,:) vaccines_LTC_daily_1(:,2:5)];

nursing_nationwide_daily.Properties.VariableNames = {'Date' 'sum_residents_weekly_confirmed' 'sum_residents_weekly_covid_19' 'sum_staff_weekly_confirmed_covid' 'Total Doses Administered Daily' 'Daily Count People Receiving Dose 1' 'Daily Count People Receiving Dose 2' 'Daily Count of People Fully Vaccinated'};

nursing_nationwide_weekly = array2table(nursing_nationwide_weekly);

usa_and_nursing = [USA_daily(:,[1 6:7]) nursing_nationwide_daily(:,2:8)];

% -------------------------------------------------------------------------
% NORMALIZATION PARAMETER: VACCINATION FRACTION (1 - vf) 
% vf = Number of fully vaccinated individuals
% (1 - vf) = Number of individuals not fully vaccinated

% Just pulling the raw cumulative vaccine data for LTC and US

vaccination_cumulative_US = vaccines_US_daily( :, [2 17]);

vaccination_cumulative_LTC =  vaccines_LTC_daily(:, [2 17]);

% Making arrays of each total population; getting ready to take Vf

US_population = 331449281.*ones(118,1);

LTC_population = 5000000.*ones(118,1); % 5 million is based on the CDC reportings of how many LTC residents have received one dose

% Calculating Vf and outputting arrays

vf_US = table2array(vaccination_cumulative_US(:, 2))./US_population;

vf_LTC = table2array(vaccination_cumulative_LTC(:,2))./LTC_population;

% Calculating 1-Vf and outputting arrays

one_minus_vf_US = (1 - vf_US);

one_minus_vf_LTC = (1 - vf_LTC);

% Putting the vf and 1-vf arrays togetherwith date column, ready to plot

vf_US = [vaccination_cumulative_US(:, 1) array2table(vf_US)];

vf_LTC = [vaccination_cumulative_LTC(:,1) array2table(vf_LTC)];

one_minus_vf_US = [vaccination_cumulative_US(:, 1) array2table(one_minus_vf_US)];

one_minus_vf_LTC = [vaccination_cumulative_LTC(:,1) array2table(one_minus_vf_LTC)]; 

% -------------------------------------------------------------------------
% NORMALIZATION PARAMETER: VACCINATION FRACTION (1 - vf_one_dose) 
% vf_one_dose = Number of individuals with one or more vaccine doses
% (1 - vf_one_dose) = Number of individuals fully susceptible

% Just pulling the raw cumulative vaccine data for LTC and US

vaccination_cumu_US = vaccines_US_daily( :, [2 16]);

vaccination_cumu_LTC =  vaccines_LTC_daily(:, [2 16]);

% Calculating Vf and outputting arrays

vf_one_dose_US = table2array(vaccination_cumu_US(:, 2))./US_population;

vf_one_dose_LTC = table2array(vaccination_cumu_LTC(:,2))./LTC_population;

% Calculating 1-Vf and outputting arrays

one_minus_vf_one_dose_US = (1 - vf_one_dose_US);

one_minus_vf_one_dose_LTC = (1 - vf_one_dose_LTC);

% Putting the vf and 1-vf arrays togetherwith date, ready to plot

vf_one_dose_US = [vaccination_cumu_US(:, 1) array2table(vf_one_dose_US)];

vf_one_dose_LTC = [vaccination_cumu_LTC(:,1) array2table(vf_one_dose_LTC)];

one_minus_vf_one_dose_US = [vaccination_cumu_US(:, 1) array2table(one_minus_vf_one_dose_US)];

one_minus_vf_one_dose_LTC = [vaccination_cumu_LTC(:,1) array2table(one_minus_vf_one_dose_LTC)]; 

% -------------------------------------------------------------------------
% NORMALIZATION PARAMETERS: ORGANIZING ALL NEW INFO INTO ONE MATRIX 

% Starting with data normalized by (1 - vf)
% AKA: data normalized by number of individials fully susceptible

LTC_normalized_one = [table2array(nursing_nationwide_daily(:,2))./table2array(one_minus_vf_LTC([1:117],2)) table2array(nursing_nationwide_daily(:,3))./table2array(one_minus_vf_LTC([1:117],2))];

USA_normalized_one = [table2array(USA_daily(:,6))./table2array(one_minus_vf_US([1:117],2)) table2array(USA_daily(:,7))./table2array(one_minus_vf_US([1:117],2))];

% Starting with data normalized by vf
% AKA: data normalized by number of individuals fully vaccinated

LTC_normalized_two = [table2array(nursing_nationwide_daily(:,2))./table2array(vf_LTC([1:117],2)) table2array(nursing_nationwide_daily(:,3))./table2array(vf_LTC([1:117],2))];

USA_normalized_two = [table2array(USA_daily(:,6))./table2array(vf_US([1:117],2)) table2array(USA_daily(:,7))./table2array(vf_US([1:117],2))];

% -------------------------------------------------------------------------
% DATA NORMALIZATION WITH TWO PARAMETERS 
% Paramaters: Vaccination fraction & (USA Cases OR USA Deaths) 


% Adjusting USA Cases & USA Deaths 
% Taking the array, dividing it by the largest element of that array.
% Returns a normalization paramater that is between 0:1 (better for division)

usa_death_temporary = table2array(USA_daily(:,7)); % Usa death column

usa_cases_temporary = table2array(USA_daily(:,6)); % Usa cases column 

max_death =max(usa_death_temporary); % max element in death array

max_cases = max(usa_cases_temporary); % max element in cases array 

usa_death_adjusted = usa_death_temporary./(table2array(one_minus_vf_US(1:117,2))/max_death); % usa cases/ 

usa_cases_adjusted = usa_cases_temporary./(table2array(vf_US(1:117,2))*max_cases); 
 
normalization_denominator_USA_cases = (table2array(USA_daily(:,6)) / max(table2array(USA_daily(:,6)))) ./ table2array(one_minus_vf_US(1:117,2));

normalization_demonimator_USA_deaths = (table2array(USA_daily(:,7)) / max(table2array(USA_daily(:,7)))) ./ table2array(one_minus_vf_one_dose_US(1:117,2));

% ------------------------------------------------------------------------

% Setting up the double normalization denominator 
% normalizing by (1 - vf) and USA cases or USA fatalities

ltc_normalized_by_one_minus_vf_one_dose_cases = table2array(one_minus_vf_one_dose_LTC(1:117,2)).*normalization_denominator_USA_cases;

ltc_normalized_by_one_minus_vf_one_dose_fatalities = table2array(one_minus_vf_one_dose_LTC(1:117,2)).*normalization_demonimator_USA_deaths;

% Applying the double normalization demonimator to the LTC datasets 

LTC_double_normalized_vf_us_cases = [table2array(nursing_nationwide_daily(:,2))./ltc_normalized_by_one_minus_vf_one_dose_cases table2array(nursing_nationwide_daily(:,3))./ltc_normalized_by_one_minus_vf_one_dose_cases ];

LTC_double_normalized_vf_us_deaths = [table2array(nursing_nationwide_daily(:,2))./ltc_normalized_by_one_minus_vf_one_dose_fatalities table2array(nursing_nationwide_daily(:,3))./ltc_normalized_by_one_minus_vf_one_dose_fatalities];

% Organizing the normalized arrays together 

normalized_one = [LTC_normalized_one USA_normalized_one];

normalized_one = array2table(normalized_one);

normalized_two = [LTC_normalized_two USA_normalized_two];

% ----- Getting rid of infinity from division by zero calculations --------
% -------------------------------------------------------------------------
normalized_two(isinf(normalized_two)) = 0;

LTC_double_normalized_vf_us_cases(isinf(LTC_double_normalized_vf_us_cases)) = 0;

LTC_double_normalized_vf_us_deaths(isinf(LTC_double_normalized_vf_us_deaths)) = 0;

LTC_double_normalized_vf_us_cases = array2table(LTC_double_normalized_vf_us_cases);

LTC_double_normalized_vf_us_deaths = array2table(LTC_double_normalized_vf_us_deaths);

normalized_two = array2table(normalized_two);

% Making the final matrix
% Note: Need to rename columns: [Date LTC_cases LTC_deaths USA_cases USA_deaths]

%normalized_vf = [nursing_nationwide_daily(:,1) normalized_one(:,:) normalized_two(:,:) LTC_double_normalized_vf_us_cases(:,:) LTC_double_normalized_vf_us_deaths(:,:) ];


normalized_vf = [nursing_nationwide_daily(:,1) LTC_double_normalized_vf_us_cases(:,:) LTC_double_normalized_vf_us_deaths(:,:) ];


%normalized_vf = [nursing_nationwide_daily(:,1) LTC_double_normalized_vf_us_cases(:,:) LTC_double_normalized_vf_us_deaths(:,:) ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Normalization Datasets : Cases and Deaths Normalized by (1 - vf one dose)
% Working on normalized data; then going to organize it all into one matrix

% Starting with data normalized by (1 - vf one dose)

LTC_normalized_one_dose_one = [table2array(nursing_nationwide_daily(:,2))./table2array(one_minus_vf_one_dose_LTC([1:117],2)) table2array(nursing_nationwide_daily(:,3))./table2array(one_minus_vf_one_dose_LTC([1:117],2))];

LTC_normalized_one_dose_two = [table2array(nursing_nationwide_daily(:,2))./table2array(vf_one_dose_LTC([1:117],2)) table2array(nursing_nationwide_daily(:,3))./table2array(vf_one_dose_LTC([1:117],2))];

USA_normalized_one_dose_one = [table2array(USA_daily(:,6))./table2array(one_minus_vf_one_dose_US([1:117],2)) table2array(USA_daily(:,7))./table2array(one_minus_vf_one_dose_US([1:117],2))];

USA_normalized_one_dose_two = [table2array(USA_daily(:,6))./table2array(vf_one_dose_US([1:117],2)) table2array(USA_daily(:,7))./table2array(vf_one_dose_US([1:117],2))];

% Setting up the double normalization denominators 
% Normalizing by (1 - vf_one_dose) and USA cases or USA fatalities 

ltc_normalized_by_vf_one_dose_cases = table2array(one_minus_vf_one_dose_LTC(1:117,2)).*usa_cases_adjusted;

ltc_normalized_by_vf_one_dose_fatalities = table2array(one_minus_vf_one_dose_LTC(1:117,2)).*usa_death_adjusted;

% Applying the double normalization demonimator to the LTC datasets 

%LTC_normalized_vf_one_dose_us_cases = [table2array(nursing_nationwide_daily(:,2))./ltc_normalized_by_vf_one_dose_cases table2array(nursing_nationwide_daily(:,3))./ltc_normalized_by_vf_cases ];

%LTC_normalized_vf_one_dose_us_deaths = [table2array(nursing_nationwide_daily(:,2))./ltc_normalized_by_vf_one_dose_fatalities table2array(nursing_nationwide_daily(:,3))./ltc_normalized_by_vf_fatalities];


% Organizing the normalization matrix 

normalized_one_dose_one = [LTC_normalized_one_dose_one USA_normalized_one_dose_one];

normalized_one_dose_one = array2table(normalized_one_dose_one);

normalized_one_dose_two = [LTC_normalized_one_dose_two USA_normalized_one_dose_two];

normalized_one_dose_two = array2table(normalized_one_dose_two);

% Getting rid of infinity from division by zero calculations

%LTC_normalized_vf_one_dose_us_cases(isinf(LTC_normalized_vf_one_dose_us_cases)) = 0;

%LTC_normalized_vf_one_dose_us_deaths(isinf(LTC_normalized_vf_one_dose_us_deaths)) = 0;

%LTC_normalized_vf_one_dose_us_cases = array2table(LTC_normalized_vf_one_dose_us_cases);

%LTC_normalized_vf_one_dose_us_deaths = array2table(LTC_normalized_vf_one_dose_us_deaths);

% ------ MAKING THE MATRIX ------
% **Need to rename columns: [Date LTC_cases LTC_deaths USA_cases
% USA_deaths]

%normalized_vf_one_dose = [nursing_nationwide_daily(:,1) normalized_one_dose_one(:,:) normalized_one_dose_two(:,:) LTC_normalized_vf_one_dose_us_cases LTC_normalized_vf_one_dose_us_deaths];

% ---- Filtering out unwanted columns & aligning start date ----

%ltc_usa_one_minus_vf = [one_minus_vf_US(1:117,:) one_minus_vf_LTC(1:117, 2) usa_and_nursing(1:117, 2:10) normalized_vf(:, 2:5)];

%normalizations_x = [normalized_vf(:,:) normalized_vf_one_dose(:, 2:13) one_minus_vf_LTC(1:117,2) one_minus_vf_US(1:117,2) vf_LTC(1:117,2) vf_US(1:117,2) one_minus_vf_one_dose_LTC(1:117,2) one_minus_vf_one_dose_US(1:117,2) vf_one_dose_LTC(1:117,2) vf_one_dose_US(1:117,2) usa_and_nursing(1:117, [2 3 4 5])];


% Making a side matrix from normalizations_x matrix so we can look at
% windowed data

%normalizations_y = normalizations_x(:,:);

% multiplication_factor1 = table2array(normalizations_y(1,37))./table2array(normalizations_y(1,25));
% 
% multiplication_factor2 = table2array(normalizations_y(1,37))./table2array(normalizations_y(1,23));
% 
% LTC_normalized_vf_one_dose_us_deaths2_scaled = table2array(normalizations_y(:,25))*multiplication_factor1;
% 
% LTC_normalized_vf_one_dose_us_cases2_scaled = table2array(normalizations_y(:,23))*multiplication_factor2;
% 
% %normalizations_y = [normalizations_x(1:20,:) array2table(LTC_normalized_vf_one_dose_us_deaths2_scaled) array2table(LTC_normalized_vf_one_dose_us_cases2_scaled)];
% 
% ethan_request = [normalizations_x(:,1) normalizations_y(:, 34) array2table(LTC_normalized_vf_one_dose_us_deaths2_scaled) array2table(LTC_normalized_vf_one_dose_us_cases2_scaled)];
% 
% num_fully_suscept_nursing = normalizations_y(1:20, [1 30 34]);
% 
% writetable(num_fully_suscept_nursing, 'Ethan_request.csv');
% 
% writetable(ethan_request, 'vaccination_fraction_normalized.csv');

% ethan_matrix = [normalizations_x(:,[1 30]) array2table(usa_cases_adjusted)];
% 
% writetable(ethan_matrix, 'normalization comparison.csv');

%% Hand Plots: Not meant for the pipeline

LTC_cases = movmean(table2array(usa_and_nursing(:, 4)),7);
US_cases = movmean(table2array(usa_and_nursing(:, 2)),7);
US_deaths = movmean(table2array(usa_and_nursing(:, 3)),7);
LTC_deaths = movmean(table2array(usa_and_nursing(:, 5)),7);
vf_one_dose_nursing = movmean(table2array(one_minus_vf_one_dose_LTC(:,2)),7);
susceptible = array2table(vf_one_dose_nursing(1:117,:).*(10000*ones(117,1)));

US_cases = table2array(USA_daily(:,6))./table2array(one_minus_vf_one_dose_US(1:117,2));
US_cases_per_susceptible = movmean(US_cases,7);

mv_avg_vf = movmean(table2array(normalized_vf(:,2:5)),7);

cases_mv_avg = movmean(table2array(LTC_double_normalized_vf_us_cases(:,1)),7);
deaths_mv_avg = movmean(table2array(LTC_double_normalized_vf_us_cases(:,2)),7);

cases_death_mv_avg = movmean(table2array(LTC_double_normalized_vf_us_deaths(:,1)),7);
deaths_death_mv_avg = movmean(table2array(LTC_double_normalized_vf_us_deaths(:,2)),7);

hand_plots = [array2table(mv_avg_vf) array2table(LTC_cases)];

cases_death_mv_avg = cases_death_mv_avg(1:30,:);
deaths_death_mv_avg = deaths_death_mv_avg(1:30,:);
LTC_cases = LTC_cases(1:30,:);
LTC_deaths = LTC_deaths(1:30,:);
cases_mv_avg = cases_mv_avg(1:30,:);
deaths_mv_avg = deaths_mv_avg(1:30,:);
US_cases_per_susceptible = US_cases_per_susceptible(1:30,:);
US_cases = US_cases(1:30,:);
US_deaths = US_deaths(1:30,:);

figure(1)
title('Nursing home cases: Normalized by susceptible in nursing homes and US cases')
subtitle('Shown is the rolling 7 day average')
ylabel('');

tsa = timeseries(LTC_cases, 1:30);
tsa.TimeInfo.Units = 'days';
tsa.TimeInfo.StartDate ='13-Dec-2020';
tsa.TimeInfo.Format = 'mmm dd, yy';
tsaTime = tsa.Time - tsa.Time(1);
plot(tsa,'b','LineWidth',0.75)
hold on 

tsc = timeseries(LTC_deaths, 1:30);
tsc.TimeInfo.Units = 'days';
tsc.TimeInfo.StartDate ='13-Dec-2020';
tsc.TimeInfo.Format = 'mmm dd, yy';
tsaTime = tsc.Time - tsc.Time(1);
plot(tsc,'r','LineWidth',0.75)
hold on 

tsb = timeseries(cases_mv_avg, 1:30);
tsb.TimeInfo.Units = 'days';
tsb.TimeInfo.StartDate = '13-Dec-2020';
tsb.TimeInfo.Format = 'mmm dd, yy';
tsb.Time = tsb.Time - tsb.Time(1);
plot(tsb, 'k','LineWidth',0.75)

hold on 
tMark = datetime(2021,1,1);
plot([tMark tMark], ylim,'LineWidth',1.5);

grid on 
grid minor
legend('Nursing Home cases','Nursing Home Fatalities','Nursing Home Cases Normalized by US cases','Vaccine Distribution Date','Location','southeastoutside');

figure(2)

title('Nursing home Fatalities: Normalized by susceptible in nursing homes and US cases')
subtitle('Shown is the rolling 7 day average')
ylabel('');

tsa = timeseries(LTC_cases, 1:30);
tsa.TimeInfo.Units = 'days';
tsa.TimeInfo.StartDate ='13-Dec-2020';
tsa.TimeInfo.Format = 'mmm dd, yy';
tsaTime = tsa.Time - tsa.Time(1);
plot(tsa,'b','LineWidth',0.75)
hold on 

tsc = timeseries(LTC_deaths, 1:30);
tsc.TimeInfo.Units = 'days';
tsc.TimeInfo.StartDate ='13-Dec-2020';
tsc.TimeInfo.Format = 'mmm dd, yy';
tsaTime = tsc.Time - tsc.Time(1);
plot(tsc,'r','LineWidth',0.75)
hold on 

tsb = timeseries(deaths_mv_avg, 1:30);
tsb.TimeInfo.Units = 'days';
tsb.TimeInfo.StartDate = '13-Dec-2020';
tsb.TimeInfo.Format = 'mmm dd, yy';
tsb.Time = tsb.Time - tsb.Time(1);
plot(tsb, 'k','LineWidth',0.75)

hold on 
tMark = datetime(2021,1,1);
plot([tMark tMark], ylim,'LineWidth',1.5);

grid on 
grid minor
legend('Nursing Home cases','Nursing Home Fatalities','Nursing Home Fatalities Normalized by US Cases','Location','southeastoutside');


figure(3)

title('Nursing home cases: Normalized by susceptible in nursing homes and US fatalities')
subtitle('Shown is the rolling 7 day average')
ylabel('');

tsa = timeseries(LTC_cases, 1:30);
tsa.TimeInfo.Units = 'days';
tsa.TimeInfo.StartDate ='13-Dec-2020';
tsa.TimeInfo.Format = 'mmm dd, yy';
tsaTime = tsa.Time - tsa.Time(1);
plot(tsa,'b','LineWidth',0.75)
hold on 

tsc = timeseries(US_deaths, 1:30);
tsc.TimeInfo.Units = 'days';
tsc.TimeInfo.StartDate ='13-Dec-2020';
tsc.TimeInfo.Format = 'mmm dd, yy';
tsaTime = tsc.Time - tsc.Time(1);
plot(tsc,'r','LineWidth',0.75)
hold on 

tsb = timeseries(cases_death_mv_avg, 1:30);
tsb.TimeInfo.Units = 'days';
tsb.TimeInfo.StartDate = '13-Dec-2020';
tsb.TimeInfo.Format = 'mmm dd, yy';
tsb.Time = tsb.Time - tsb.Time(1);
plot(tsb, 'k','LineWidth',0.75)

hold on 
tMark = datetime(2021,1,1);
plot([tMark tMark], ylim,'LineWidth',1.5);

grid on 
grid minor
legend('Nursing Home cases','US Fatalities','Nursing Home Cases Normalized by US Fatalities','Location','southeastoutside');

figure(4)

title('Nursing home Fatalities: Normalized by susceptible in nursing homes and US fatalities')
subtitle('Shown is the rolling 7 day average')
ylabel('');

tsa = timeseries(LTC_deaths, 1:30);
tsa.TimeInfo.Units = 'days';
tsa.TimeInfo.StartDate ='13-Dec-2020';
tsa.TimeInfo.Format = 'mmm dd, yy';
tsaTime = tsa.Time - tsa.Time(1);
plot(tsa,'b','LineWidth',0.75)
hold on 

tsc = timeseries(US_deaths, 1:30);
tsc.TimeInfo.Units = 'days';
tsc.TimeInfo.StartDate ='13-Dec-2020';
tsc.TimeInfo.Format = 'mmm dd, yy';
tsaTime = tsc.Time - tsc.Time(1);
plot(tsc,'r','LineWidth',0.75)
hold on 

tsb = timeseries(deaths_death_mv_avg, 1:30);
tsb.TimeInfo.Units = 'days';
tsb.TimeInfo.StartDate = '13-Dec-2020';
tsb.TimeInfo.Format = 'mmm dd, yy';
tsb.Time = tsb.Time - tsb.Time(1);
plot(tsb, 'k','LineWidth',0.75)

hold on 
tMark = datetime(2021,1,1);
plot([tMark tMark], ylim,'LineWidth',1.5);

grid on 
grid minor
legend('Nursing Home Fatalities','US Fatalities','Nursing Home Fatalities Normalized by US Fatalities','Location','southeastoutside');


%% --- Writing oranized data into CSV for quick plots ----

writetable(USA_daily,'usa_daily_stats_21_12_16.csv');

%writetable(vaccines_LTC_daily, 'ltc_daily_vaccine_stats_21_12_16.csv');

%writetable(nursing_nationwide_weekly, 'ltc_weekly_stats_21_12_16.csv');

writetable(nursing_nationwide_daily, 'ltc_daily_stats_21_12_16.csv');

writetable(usa_and_nursing, 'usa_nursing_daily_stats.csv');

%% ----- Writing total people vaccinated cumulative ------

writetable(vaccination_cumulative_US, 'vaccination_cumulative_US.csv');

writetable(vaccination_cumulative_LTC, 'vaccination_cumulative_LTC.csv');

%% ----- Writig vaccination fraction -----

writetable(vf_LTC, 'vaccination_fraction_LTC.csv');

writetable(vf_US, 'vaccination_fraction_US.csv');

%% ----- Writing (1- vaccination fraction) aka percent not-vaccinated -----

writetable(one_minus_vf_US, 'non_vaccination_fraction_US.csv');

writetable(one_minus_vf_LTC, 'non_vaccination_fraction_LTC.csv');

%% ---- Writing Normalized Data-Sets

writetable(normalized_vf, 'normalized_one_minus_vf.csv');

%% ----- Writing combined table of vf, 1-vf, X, and same paramaters for fully vaccinated and one dose

% writetable(normalizations_x, 'all_normalizations_x.csv');
% writetable(normalizations_y , 'all_normalizations_y.csv');
