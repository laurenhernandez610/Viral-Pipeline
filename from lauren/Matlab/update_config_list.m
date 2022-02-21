% this will overwrite "param.cfg" to list every filename in "configs"
% directory


fileNames = string({ dir('configs/*.cfg').name });

fileID = fopen("param.cfg", 'w');
for i = 1:length(fileNames)
    if (contains(fileNames(i), ".cfg"))
        fprintf(fileID, '%s\n', fileNames(i));
    end
end