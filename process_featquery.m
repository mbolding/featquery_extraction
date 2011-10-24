function process_featquery()
% proccess featquery results from pvem experiment
% mark.bolding@gmail.com

%% get list of subjects to process
fp1 = fopen('subjectdirs.txt');
subjectdir = fgetl(fp1);
while ischar(subjectdir)
    disp(subjectdir)
    
    
    subjectdir = fgetl(fp1);
end



%% clean up
fclose(fp1);