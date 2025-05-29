function init_T(T)
% Read the content of the file
file_path='../../WEC-Sim/examples/RM3/wecSimInputfile.m';
fid = fopen(file_path, 'r');
new_content = {};
if fid == -1
    error('Unable to open the file for reading');
end

% Read the file line by line
while ~feof(fid)
    line = fgetl(fid);
    
    % Check if the line contains 'wave.T'
    if contains(line, 'waves.T')
        if contains(line, '%')
        
            % Change the value of wave.T

        else; line = sprintf('waves.T = %d;',T);
        end
    end
    
    new_content = [new_content; line];
end
% Close the file
fclose(fid);

% Write the modified content back to the file
fid = fopen(file_path, 'w');
if fid == -1
    error('Unable to open the file for writing');
end

for i = 1:numel(new_content)
    fprintf(fid, '%s\n', new_content{i});
end

% Close the file
fclose(fid);
disp('File updated successfully.');