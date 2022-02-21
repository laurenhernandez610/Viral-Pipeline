close all
% "param.cfg" is now used to list the filenames of multiple configuration
% files (previously, these were the 'param.cfg' files)

% configuration files must be in ./configs/*

% run "update_config_list.m" to overwrite "param.cg" with a list of all
% .cfg files in the configs directory

% use '#' in config_list.cfg to comment out a line, which will cause that file to be ignored
% use '#{' in config_list.cfg to begin a comment block
% use '#}' to end a comment block
% every line inside the comment block is ignored
paramFilename = "config_list.cfg";
paramFileID = fopen(paramFilename, 'r');

% reading config list
fprintf("reading config list file\n");
index=1;
paramFileNames = [ "" ];
commentBlock = 0;
while (~feof(paramFileID))
    line = fgetl(paramFileID);
    if (~commentBlock)
        if (contains(line,"#{"))
            commentBlock = 1;
        elseif (~isempty(line) && ~contains(line,"#"))
            fprintf("found %s\n",line);
            paramFileNames(index) = strtrim(string(line));
            index = index+1;
        end
    else
        commentBlock = ~contains(line,"#}");
        if commentBlock == 0
        end
    end
end
fclose(paramFileID);

%{ 
paramters of the form:
paramName=paramField
ex.
filename=.\directory\datafile.csv
movavg=7
xtitle=covid count
ytitle=covid deaths

parameters may be specified in any order

possible parameters:
filename - filename of data; include directory path if not in same folder
plottype - scatter or line
data1 - string at first row of column data for data set 1 (x axis / left)
data2 - (optional) string at first row of column data for y data (y axis / right)
data3 - (optional) string at first row of column data for a third data set

graphtitle - title of graphic
subtitle - subtitle of graphic
title1 - name of data1 axis on graphic
title2 - name of data2 axis on graphic
title3 - (optional) name to display in legend for data3

startDay - yymmdd of day to start data
endDay - yymmdd of day to end data

getLog - take the log10 of data; 0 or 1
movAvg - number of days of moving average of data
ratio - get ratio of data1 over data2; 0 or 1

lagDepth - maximum lag time in days

datefile - filename of date file; include directory path if not in same
folder
dateTitle - title of date column in csv; defaults to "Date"
dateFormat - format of dates in csv; defaults to yyyy-MM-dd

saveFilename - name of file to save .gif (and images) as
%}

% create new tex input file with time signature indicating new run
if (~exist('./tex_input','dir'))
    fprintf("tex_input directory not found. creating ./tex_input\n");
    mkdir('tex_input');
end

tex_filename = "tex_input-" + string(datetime('now','TimeZone','local','Format','yy-MM-dd-HHmmss')) + ".txt";
fileID = fopen('tex_input/' + tex_filename, 'at');
texTime = string(datetime('now'));
fprintf(fileID, "%%-----------------------\n");
fprintf(fileID, "%% %s     \n",texTime);
fprintf(fileID, "%%-----------------------\n");
fclose(fileID);

for (i=1:length(paramFileNames))
    fileID = fopen("configs/" + paramFileNames(i), 'r');
    
    fprintf("reading %s\n",paramFileNames(i));
    
    % 1/18/21 refactor, all params inside config struct
    config = {};
    config.tex_filename = tex_filename;
    clear params;
    
    % read configuration file, ignoring empty lines or lines containing '#'
    index = 1;
    while (~feof(fileID))
        line = fgetl(fileID);
        if (~isempty(line) && ~contains(line,"#"))
            params(index,:) = strsplit(line,"=");
            index = index+1;
        end
    end
    fclose(fileID);
    
    % parse parameter file for parameters
    fprintf("parsing config file\n");
    config.filename = getParamValue(params, "filename");
    config.getLog = getParamValue(params, "getLog");
    config.movAvg = getParamValue(params, "movAvg");
    config.graphtitle = getParamValue(params, "graphtitle");
    config.subtitle = getParamValue(params, "subtitle");
    config.title1 = getParamValue(params, "title1");
    config.title2 = getParamValue(params, "title2");
    config.title3 = getParamValue(params, "title3");
    config.startDay = getParamValue(params, "startDay");
    config.endDay = getParamValue(params, "endDay");
    config.data1 = getParamValue(params, "data1");
    config.data2 = getParamValue(params, "data2");
    config.data3 = getParamValue(params, "data3");
    config.datefile = getParamValue(params, "datefile");
    config.plottype = getParamValue(params, "plottype");
    config.dateTitle = getParamValue(params, "dateTitle");
    config.dateFormat = getParamValue(params, "dateFormat");
    config.saveFilename = getParamValue(params, "saveFilename");
    config.legendFilename = getParamValue(params, "legendFilename");
    config.lagDepth = getParamValue(params, "lagDepth");
    config.ratio = getParamValue(params, "ratio");
    config.prevalenceMatrix = getParamValue(params, "prevalenceMatrix");
    config.titleFontSize = 12;
    config.subtitleFontSize = 8.2;
    
    % if parameter was not found in config file:
    % its value will be an empty array
    % here we look for missing parameters and set default values,
    % and do preprocessing like moving average and log 
    
    % read the csv file
    if (isempty(config.filename))
        fprintf("data file not found!\n");
    else
        fprintf("reading data file\n");
        table = readtable(config.filename);
    end
    
    % grab data from the csv table column titles
    config.axisData1 = table.(config.data1);
    config.axisData2 = [];
    config.axisData3 = [];
    if (~isempty(config.data2))
        config.axisData2 = table.(config.data2);
    end
    if (~isempty(config.data3))
        config.axisData3 = table.(config.data3);
    end
        
    % get first date in file
    config.firstDate = table.(config.dateTitle)(1);
    if (iscell(config.firstDate))
        config.firstDate = cell2mat(config.firstDate);
    end
    config.firstDate = datetime(config.firstDate, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    
    % default crop limits
    config.startDayIndex = 1;
    config.endDayIndex = length(config.axisData1);
    
    % get crop window size
    if (~isempty(config.startDay))
        config.startDayFormat = datetime(config.startDay, "InputFormat", 'yyMMdd');
        config.startDayIndex = daysact(config.firstDate, config.startDayFormat);
    end
    if (~isempty(config.endDay))
        config.endDayFormat = datetime(config.endDay, "InputFormat", 'yyMMdd');
        config.endDayIndex = daysact(config.firstDate, config.endDayFormat);
    end
    
    % if crop is necessary, then crop
    if (config.startDayIndex ~= 1 && config.endDayIndex ~= length(config.axisData1))
        fprintf("crop from %s through %s\n",config.startDayFormat,config.endDayFormat);
        config.axisData1 = config.axisData1(config.startDayIndex:config.endDayIndex); 
        config.axisData2 = config.axisData2(config.startDayIndex:config.endDayIndex);
        config.firstDate = config.startDayFormat;
    end
    
    % moving average module
    if (~isempty(config.movAvg))
        config.movAvg = str2double(config.movAvg);
        if (config.movAvg)
            fprintf("using %d day moving averages\n",config.movAvg);
            config.axisData1 = movmean(config.axisData1, config.movAvg);
            config.axisData2 = movmean(config.axisData2, config.movAvg);
            config.axisData3 = movmean(config.axisData3, config.movAvg);
        end
    end
    
    % logarithm module
    if (~isempty(config.getLog))
        config.getLog = str2double(config.getLog);
        if (config.getLog)
            fprintf("using log10 of data\n");
            if any(config.axisData1 == 0) || any(config.axisData2 == 0)
                fprintf("warning: taking log of 0 to be 0\n");
                config.axisData1 = config.axisData1 + (config.axisData1 == 0);
                config.axisData2 = config.axisData2 + (config.axisData2 == 0);
                config.axisData3 = config.axisData3 + (config.axisData3 == 0);
            end
            config.axisData1 = log10(config.axisData1);
            config.axisData2 = log10(config.axisData2);
            config.axisData3 = log10(config.axisData3);
            
            % this would change the title, but we are using manual naming
            %config.title1 = "log10 " + config.title1;
            %config.title2 = "log10 " + config.title2;
        end
    end
    
    % graphtitle
    if (isempty(config.graphtitle))
        fprintf("graph title not found!\n");
        config.graphtitle = "";
    end
    
    % subtitle
    if (isempty(config.subtitle))
        fprintf("subtitle not found!\n");
        config.subtitle = "";
    end
    
    % default lag depth
    if (isempty(config.lagDepth))
        fprintf("lagDepth does not exist\n");
        config.lagDepth = 30;
    else
        config.lagDepth = str2double(config.lagDepth);
    end
    
    % if data2 is not found, then we are getting a single line plot
    if (isempty(config.data2))
        fprintf("data2 not found\n");
        config.title2 = [];
    end
    
    if (isempty(config.data3))
        fprintf("data3 not found\n");
        config.title3 = [];
    end

    % default gif/image filename
    if (isempty(config.saveFilename))
        fprintf("gif filename not found!\n");
        config.saveFilename = "DefaultName";
    end

    % default legend filename
    if (isempty(config.legendFilename))
        fprintf("legend filename not found!\n");
        config.legendFilename = "dateLegend";
    end

    % default date title
    if (isempty(config.dateTitle))
        fprintf("date title not found!\n");
        config.dateTitle = "Date";
    end
    
    % default date format
    if (isempty(config.dateFormat))
        fprintf("date format not found!\n");
        config.dateFormat = "yyyy-MM-dd";
    end

    % read datefile if found
    if (exist(config.datefile, 'file'))
        fprintf("significant date file found\n");
        datetable = readtable(config.datefile);
        dates = datetime(transpose(datetable.(1)), 'InputFormat', 'yyyy-MM-dd');
        
        config.dateDays = daysact( config.firstDate, dates );
        config.dateStrings = transpose(datetable.(2));
    else
        fprintf("date file not found\n");
        config.dateDays = 0;
    end
    
    % ratio detected, edit axes titles
    if (~isempty(config.ratio))
        config.ratio = str2double(config.ratio);
        if (config.ratio)
            config.title2 = "(" + config.title1 + " / " + config.title2 + ")";
            config.title1 = "";
            fprintf("using ratio %s\n", config.title2);
        end
    end
    
    %default plottype
    if (isempty(config.plottype))
        fprintf("no plot type found. defaulting to scatter.\n");
        config.plottype = "scatter";
    end
    
    % title of x axis for relevant plots
    config.xtitle = "days since " + string(config.firstDate);
    
    if (~isempty(config.axisData3))
        % generate line plot with three lines
        generatePlotThreeLines(config);
    else
        % handles all other plots
        % want to break this into different function calls for each plot
        generateLagPlots(config);
    end
end


% searches for the parameter string contained by parameter_name in the
% parame_array, and then returns the value of the parameter
% returns a string
function value = getParamValue(param_array, parameter_name)
    value = cell2mat(param_array(param_array(:,1)==parameter_name,2));
end

function appendTexInputFile(text_filename, image_filename)
    baseName = image_filename.split(".");
    baseName = baseName(1);
    fileID = fopen('tex_input/' + text_filename, 'at');
    fprintf(fileID, "\\begin{figure}[!h]\n");
    fprintf(fileID, "    \\includegraphics[width=\\linewidth]{%s}\n", image_filename);
	fprintf(fileID, "    \\caption{}\n");
	fprintf(fileID, "    \\label{fig:%s}\n", baseName + "Label");
    fprintf(fileID, "\\end{figure}\n\n");
    fclose(fileID);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate plot with three lines
% pull sigdate figure out after cleaning up generateLagPlots()
% eventually generalize this into any number of lines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function generatePlotThreeLines(config)
    % legend / significant dates figure
    sigDateFig = figure('Position', [10 10 900 600]);
    numberedDateStrings = config.dateStrings;
    for i=1:length(config.dateStrings)
       numberedDateStrings(i) = cellstr(num2str(i) + ": " + string((config.firstDate + config.dateDays(i))) + " - " + string(config.dateStrings(i))); 
    end
    dim = [.2, .5, .3, .3];
    dateNote = annotation('textbox',dim,'String',numberedDateStrings,'FitBoxToText', 'on');
    drawnow
    frame = getframe(sigDateFig); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256);
    
    % save legend / sig date figure
    if (~exist('./legends','dir'))
        fprintf("legends directory not found. creating ./legends\n");
        mkdir('legends');
    end
    
    config.legendFilename = config.legendFilename + ".png";
    fprintf("significant date legend saved as %s\n",config.legendFilename);
    
    imwrite(imind,cm,"legends/" + config.legendFilename);
    appendTexInputFile(config.tex_filename, "legends/" + config.legendFilename);
    
    delete(dateNote);
    close(sigDateFig);
    
    % create figure window with fixed position and size
    h = figure('Position', [10 10 900 600]);
    axis tight manual % this ensures that getframe() returns a consistent size
    note = ""; % this is the text box for lag time and correlation; would prefer some other way to display data
    yAxisLimit = max( max(config.axisData3), max( max(config.axisData2), max(config.axisData1) ) ); % limit of axis for where data1 goes
    
    fprintf("generating line plot for %s, %s, %s / days\n",config.title1, config.title2, config.title3);
    plot([1:length(config.axisData1)], config.axisData1);
    hold on
    plot (config.axisData2);
    plot (config.axisData3);
    %ylabel (config.title1); % config.title1 is y axis if 1 data input
    legend(config.title1, config.title2, config.title3, "Location", "bestoutside");
        
    xlabel (config.xtitle);
    xlim([0 length(config.axisData1)]);
    ylim([0 yAxisLimit]);
    


    for i=1:length(config.dateDays)
        xline(config.dateDays(i), '-', {i}, 'HandleVisibility','off');
    end
    
    title(config.graphtitle, 'FontSize', config.titleFontSize);
    subtitle(config.subtitle, 'FontSize', config.subtitleFontSize);
    ax = gca;
    ax.TitleHorizontalAlignment = 'left';
    
    % xticks display 1st of each month
    xdays = config.firstDate + [0:config.endDayIndex - config.startDayIndex];
    fdom = xdays.Day == 1;
    marks = find(fdom);
    xticks(marks);

    xlabels = string(xdays(marks));
    xticklabels(xlabels);
    xticklabels(xlabels);
    xtickangle(-45);
    xlabels = string(xdays(marks));

    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256);

    imwrite(imind,cm,"images/" + config.saveFilename + ".png");
    appendTexInputFile(config.tex_filename, "images/" + config.saveFilename + ".png");
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate lag plot gif
% plan to pull segments out into their own functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function generateLagPlots(config)
    
    % legend / significant dates figure
    sigDateFig = figure('Position', [10 10 900 600]);
    numberedDateStrings = config.dateStrings;
    for i=1:length(config.dateStrings)
       numberedDateStrings(i) = cellstr(num2str(i) + ": " + string((config.firstDate + config.dateDays(i))) + " - " + string(config.dateStrings(i))); 
    end
    dim = [.2, .5, .3, .3];
    dateNote = annotation('textbox',dim,'String',numberedDateStrings,'FitBoxToText', 'on');
    drawnow
    frame = getframe(sigDateFig); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256);
    
    % save legend / sig date figure
    if (~exist('./legends','dir'))
        fprintf("legends directory not found. creating ./legends\n");
        mkdir('legends');
    end
    
    config.legendFilename = config.legendFilename + ".png";
    fprintf("significant date legend saved as %s\n",config.legendFilename);
    
    imwrite(imind,cm,"legends/" + config.legendFilename);
    appendTexInputFile(config.tex_filename, "legends/" + config.legendFilename);
    
    delete(dateNote);
    close(sigDateFig);
   
    
    h = figure('Position', [10 10 900 600]);
    axis tight manual % this ensures that getframe() returns a consistent size
    note = "";
    axisLimit1 = max(config.axisData1);
    if (~isempty(config.axisData2))
        axisLimit2 = max(config.axisData2);
        if (config.ratio)
            axisLimit2 = min(config.axisData2); % need min of divisor if ratio 
        end
    end
   

    % two sets of data -> get lags, correlation, plot gifs
    if (~isempty(config.axisData2)) 
        fprintf("generating lag plot gif for %s: %s / %s\n",config.graphtitle, config.title2, config.title1);
        correlation = zeros(1, config.lagDepth);
        for n = 0:config.lagDepth % lag in days
            note = [];
            % split into lag segments
            data1_seg = config.axisData1(1:length(config.axisData1) - n);
            data2_seg = config.axisData2(1+n:length(config.axisData2));
            % if our segment has passed an important date, remove it
            while (config.dateDays(length(config.dateDays)) > length(config.axisData1))
                config.dateDays = config.dateDays(1:length(config.dateDays) - 1);
                config.dateStrings = config.dateStrings(1:length(config.dateStrings) - 1);
            end
            
            
            if (length(data1_seg) ~= length(data2_seg))
                fprintf("Error: x length ~= y length\n");
                break;
            end

            if (config.plottype == "scatter") % scatter plot
                % generate scatter plot
                % blue -> yellow-green
                c = zeros(length(data1_seg),3);
                gradient = linspace(0,1,length(data1_seg));
                c(:,1) = .75*gradient;
                c(:,2) = .25 + .75*gradient;
                c(:,3) = 1 - .75*gradient;

                config.dateDays = transpose(nonzeros((config.dateDays > 0).*config.dateDays));

                % purple-red -> orange
                % change color of specific days
                if (config.dateDays ~= 0)
                    dateColor = zeros(length(config.dateDays), 3);
                    dateColor(:,1) = 1;
                    dateColor(:,2) = .5*transpose(linspace(0,1, length(config.dateDays)));
                    dateColor(:,3) = .5 - dateColor(:,2);
                    for i=1:length(config.dateDays)
                        c(config.dateDays(i),:) = dateColor(i,:);
                    end
                end
                scatter(data1_seg, data2_seg, [], c, 'filled');

                xlim([0 axisLimit1]);
                ylim([0 axisLimit2]);
            

                xlabel(config.title1);
                ylabel(config.title2);
                dx=0;
                dy=0;
                dateLabels = [""];
                for i=1:length(config.dateDays)
                    dateLabels(i) = num2str(i);
                end
                text(data1_seg(config.dateDays)+dx, data2_seg(config.dateDays)+dy,dateLabels);
                %legend(config.dateStrings, 'Location', 'bestoutside'); 
            elseif (config.plottype == "line")  % line plot
                if (config.ratio) % get ratio plot with single line
                    if (config.getLog)
                        data1_seg = data1_seg - data2_seg;
                    else
                        data1_seg = data1_seg ./ data2_seg;
                    end
                    data2_seg = [];
                    
                    plot([1:length(data1_seg)], data1_seg);
                    ylabel (config.title2);
                    xlabel (config.xtitle);
                    xlim([0 length(config.axisData1)]);
                    ylim([0 (axisLimit1 / axisLimit2)]);

                    for i=1:length(config.dateDays)
                        xline(config.dateDays(i), '-', {i});
                    end
                    
                    % create lag box
                    dim = [.725, .5, .3, .3];
                    str = {"Lag time: " + n + " days."};
                    note = annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on');
                    drawnow
                else % get normal 2-line plot
                    plot([1:length(data1_seg)], data1_seg);
                    yyaxis left
                    ylabel (config.title1);
                    xlabel (config.xtitle);
                    xlim([0 length(config.axisData1)]);
                    ylim([0 axisLimit1]);
                    
                    yyaxis right
                    plot(data2_seg);

                    %xlim([0 axisLimit1]);
                    ylim([0 axisLimit2]);
                    ylabel(config.title2);

                    for i=1:length(config.dateDays)
                        xline(config.dateDays(i), '-', {i});
                    end

                    legend(config.title1, config.title2, "Location", "bestoutside");
                    
                    % create lag-correlation box
                    correlation(n+1) = corr(data1_seg, data2_seg);    
                    dim = [.725, .5, .3, .3];
                    str = {"Lag time: " + n + " days.", "Correlation " + correlation(n+1)};
                    note = annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on');
                    drawnow
                end
                
                % xticks display 1st of each month
                xdays = config.firstDate + [0:config.endDayIndex - config.startDayIndex];
                fdom = xdays.Day == 1;
                marks = find(fdom);
                xticks(marks);
                
                xlabels = string(xdays(marks));
                xticklabels(xlabels);
                xticklabels(xlabels);
                xtickangle(-45);
                xlabels = string(xdays(marks));
                
            end
            title(config.graphtitle, 'FontSize', config.titleFontSize);
            subtitle(config.subtitle, 'FontSize', config.subtitleFontSize);
            ax = gca;
            ax.TitleHorizontalAlignment = 'left';
            
            % Capture the plot as an image 
            frame = getframe(h); 
            im = frame2im(frame); 
            [imind,cm] = rgb2ind(im,256);

            if (~exist('./images','dir'))
                fprintf("images directory not found. creating ./images\n");
                mkdir('images');
            end

            imwrite(imind,cm,"images/" + config.saveFilename + "-" + n + "lag.png");
            appendTexInputFile(config.tex_filename, "images/" + config.saveFilename + "-" + n + "lag.png");

            % Write to the GIF File 
            if (~exist('./gifs','dir'))
                fprintf("gifs directory not found. creating ./gifs\n");
                mkdir('gifs');
            end
            if n == 0
                imwrite(imind,cm, "gifs/" + config.saveFilename + ".gif","gif", 'Loopcount',inf); 
            else 
                imwrite(imind,cm, "gifs/" + config.saveFilename + ".gif",'gif','WriteMode','append'); 
            end
            if (n ~= config.lagDepth) 
                delete(note);
            end
        end
        % get max correlation
        [~, max_corr_index] = max(correlation);
        max_corr_index = max_corr_index - 1; % correlation(1) = correlation at lag of 0
        fprintf("max correlation at %d days of lag\n",max_corr_index);
        
        % print max correlation to new tex folder
        if (~exist('./tex_input_correlation','dir'))
            fprintf("tex_input_correlation directory not found. creating ./tex_input_correlation\n");
            mkdir('tex_input_correlation');
        end
        
        % TODO: include timestamp
        appendTexInputFile("../tex_input_correlation/tex_input_correlation.txt", "images/" + config.saveFilename + "-" + max_corr_index + "lag.png");
        
    else % single line plot
        fprintf("generating line plot for %s: %s / days\n",config.graphtitle, config.title1);
        plot([1:length(config.axisData1)], config.axisData1);
        ylabel (config.title1); % config.title1 is y axis if 1 data input
        xlabel (config.xtitle);
        xlim([0 length(config.axisData1)]);
        disp(axisLimit1);
        ylim([0 axisLimit1]);

        for i=1:length(config.dateDays)
            xline(config.dateDays(i), '-', {i});
        end
        title(config.graphtitle, 'FontSize', config.titleFontSize);
        subtitle(config.subtitle, 'FontSize', config.subtitleFontSize);
        ax = gca;
        ax.TitleHorizontalAlignment = 'left';
            
        frame = getframe(h); 
        im = frame2im(frame); 
        [imind,cm] = rgb2ind(im,256);
        
        imwrite(imind,cm,"images/" + config.saveFilename + ".png");
        appendTexInputFile(config.tex_filename, "images/" + config.saveFilename + ".png");
    end
   % close all;
end
