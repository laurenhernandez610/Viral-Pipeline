clear all;

%change these
county = "Broward";
state = "FL";

sumColumns = [
    "residents_weekly_admissions",
    "residents_total_admissions",
    "residents_weekly_confirmed",
    "residents_total_confirmed",
    "residents_weekly_suspected",
    "residents_total_suspected",
    "residents_weekly_all_deaths",
    "residents_total_all_deaths",
    "residents_weekly_covid_19",
    "residents_total_covid_19",
    "number_of_all_beds",
    "total_number_of_occupied",
    "staff_weekly_confirmed_covid",
    "staff_total_confirmed_covid",
    "staff_weekly_suspected_covid",
    "staff_total_suspected_covid",
    "staff_weekly_covid_19_deaths",
    "staff_total_covid_19_deaths"
    ];

select = "week_ending";
for i=[1:length(sumColumns)]
    select = select + ",sum(" + sumColumns(i) + ")";
end
where = "county= '" + county + "' AND provider_state= '" + state + "'";
group = "week_ending";
order = "week_ending";
token = "G58tYB4YmrmExfgskrjrMBaOX";
url = "https://data.cms.gov/resource/s2uc-8wxp.csv";
limit = 10000;

fullResults = table;
% retrieve paged results until complete
csvPage = -1;
i=0;
while (~isempty(csvPage))
    offset = i*limit;
    soqlStr = "?$$app_token=" + token + "&$select=" + select + "&$where=" + where + "&$group=" + group + "&$order=" + order + "&$offset=" + offset + "&$limit=" + limit;
    csvPage = webread(url + soqlStr);
    fprintf("%s\n",url + soqlStr);
    if (~isempty(csvPage))
        fullResults = [fullResults;csvPage];
    end
    i=i+1;
end

date = datetime('now','TimeZone','local','Format','yy-MM-dd');
outputFileName = "nursing_" + county + state + "_" + string(date) + ".csv";


%{
========= this is now done with the SoQL above =========
%iterate through full table
%sum all entries for the same date
%this will get whole county data instead of provider data
for i=[0:height(fullResults)]  
end
%}

% save
fprintf("saving to %s\n",outputFileName);
writetable(fullResults, outputFileName);


% function to retrieve a page of csv results
% unused in above loop
function csvPage = getPagedResults(url, select, where, order, limit, offset, token)
    %fprintf("limit=%d | offset=%d\n",limit,offset);
    soqlStr = "?$$app_token=" + token + "&$select=" + select + "&$where=" + where + "&$order=" + order + "&$offset=" + offset + "&$limit=" + limit
    csvPage = webread(url + soqlStr);
end