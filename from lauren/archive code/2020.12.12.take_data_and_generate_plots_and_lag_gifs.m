clear all;

%read parameter file
paramFilename = "param.cfg";
fileID = fopen(paramFilename, 'r');

%{ 
paramters of the form:
paramName=paramField
ex.
filename=.\directory\datafile.csv
movavg=1
xtitle=covid count
ytitle=covid deaths

parameters may be specified in any order

possible parameters:
filename - filename of data; include directory path if not in same folder
plottype - scatter or line
data1 - string at first row of column data for data set 1 (x axis / left)
data2 - string at first row of column data for y data (y axis / right)

graphtitle - title of graphic
title1 - name of data1 axis on graphic
title2 - name of data2 axis on graphic

getLog - take the log of data; 0 or 1
movAvg - take the 7 day moving average of data; 0 or 1

datefile - filename of date file; include directory path if not in same
folder
dateTitle - title of date column in csv; defaults to "Date"
dateFormat - format of dates in csv; defaults to yyyy-MM-dd
%}
fprintf("reading parameter file\n");
index=1;
while (~feof(fileID))
    line = fgetl(fileID);
    if (~isempty(line))
        params(index,:) = strsplit(line,"=");
        index = index+1;
    end
end
fclose(fileID);

% parse parameter file for parameters
fprintf("parsing parameter file\n");
filename = getParamValue(params, "filename");
getLog = getParamValue(params, "getLog");
movAvg = getParamValue(params, "movAvg");
graphtitle = getParamValue(params, "graphtitle");
title1 = getParamValue(params, "title1");
title2 = getParamValue(params, "title2");
data1 = getParamValue(params, "data1");
data2 = getParamValue(params, "data2");
datefile = getParamValue(params, "datefile");
plottype = getParamValue(params, "plottype");
dateTitle = getParamValue(params, "dateTitle");
dateFormat = getParamValue(params, "dateFormat");

% read the csv file
fprintf("reading data file\n");
table = readtable(filename);

if (~exist("dateTitle", 'var'))
    dateTitle = "Date";
end

if (~exist(dateFormat, 'var'))
    dateFormat = "yyyy-MM-dd";
end

% read datefile if found
if (exist(datefile, 'file'))
    fprintf("date file found\n");
    datetable = readtable(datefile);
    dates = datetime(transpose(datetable.(1)), 'InputFormat', 'yyyy-MM-dd');
    firstDate = table.(dateTitle)(1);
    if (iscell(firstDate))
        firstDate = cell2mat(firstDate);
    end
    firstDate = datetime(firstDate, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    dateDays = daysact( firstDate, dates );
else
    dateDays = 0;
end

% grabbing columns from the csv table
axisData1 = table.(data1);
axisData2 = table.(data2);

% moving average module
if (exist('movAvg', 'var') && movAvg)
    fprintf("taking moving average of data\n");
    axisData1 = movmean(axisData1, 7);
    axisData2 = movmean(axisData2, 7);
end

% logarithm module
if (exist('getLog', 'var') && getLog)
    fprintf("taking log of data\n");
    if any(axisData1 == 0) || any(axisData2 == 0)
        fprintf("warning: taking log of 0 to be 1\n");
    end
    axisData1 = log(axisData1);
    axisData2 = log(axisData2);
end

%default to scatter plottype
if (~exist('plottype', 'var'))
    fprintf("no plot type found. defaulting to scatter.\n");
    plottype = "scatter";
end

%generate lag plot gif
generateLagPlots(axisData1, axisData2, title1, title2, graphtitle, dateDays, plottype);

% searches for the parameter string contained by parameter_name in the
% parameter_arrray, and then returns the value of the parameter
function value = getParamValue(param_array, parameter_name)
    value = cell2mat(param_array(param_array(:,1)==parameter_name,2));
    if isequal(value, '0') || isequal(value, '1')
        value = str2num(value);
    end
end

%generate lag plot gif
function generateLagPlots(data1, data2, xtitleString, ytitleString, titleString, dateDays, plottype)
    fprintf("generating lag plot gif for %s: %s / %s\n",titleString, ytitleString, xtitleString);
    h = figure;
    axis tight manual % this ensures that getframe() returns a consistent size
    filename = "lagPlot" + plottype + ".gif";
    note = "";
    for n = 0:20 % lag in days
        % split into lag segments
        data1_seg = data1(1:length(data1) - n);
        data2_seg = data2(1+n:length(data2));
        % if our segment has gone passed an important date, remove it
        while (dateDays(length(dateDays)) > length(data1))
            dateDays = dateDays(1:length(dateDays) - 1);
        end
        
        if (length(data1_seg) ~= length(data2_seg))
            fprintf("Error: x length ~= y length\n");
            break;
        end
        
        if (plottype == "scatter")
            % generate scatter plot
            % blue -> yellow-green
            c = zeros(length(data1_seg),3);
            gradient = linspace(0,1,length(data1_seg));
            c(:,1) = .75*gradient;
            c(:,2) = .25 + .75*gradient;
            c(:,3) = 1 - .75*gradient;
            
            dateDays = transpose(nonzeros((dateDays > 0).*dateDays));
            
            % purple-red -> orange
            % change color of specific days
            if (dateDays ~= 0)
                dateColor = zeros(length(dateDays), 3);
                dateColor(:,1) = 1;
                dateColor(:,2) = .5*transpose(linspace(0,1, length(dateDays)));
                dateColor(:,3) = .5 - dateColor(:,2);
                for i=1:length(dateDays)
                    c(dateDays(i),:) = dateColor(i,:);
                end
            end
            scatter(data1_seg, data2_seg, [], c, 'filled');
            xlabel(xtitleString);
            ylabel(ytitleString);
        elseif (plottype == "line")  
            plot([1:length(data1_seg)], data1_seg);
            yyaxis left
            ylabel (xtitleString);

            yyaxis right
            plot(data2_seg);
            ylabel(ytitleString);
            for i=1:length(dateDays)
                xline(dateDays(i));
            end
            legend(xtitleString, ytitleString, "Location", "northwest");
        end
        correlation = corr(data1_seg, data2_seg);
        title(titleString);
        dim = [.2, .5, .3, .3];
        str = {"Lag time: " + n + " days.", "Corrrelation " + correlation};
        note = annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on');
        drawnow

        % Capture the plot as an image 
        frame = getframe(h); 
        im = frame2im(frame); 
        [imind,cm] = rgb2ind(im,256);

        % Write to the GIF File 
        if n == 0
            imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
        else 
            imwrite(imind,cm,filename,'gif','WriteMode','append'); 
        end
        delete(note);
    end
end
