function Y = process_featquery2()
% proccess featquery results from pvem experiment
% mark.bolding@gmail.com

%% directory and file name lists
importfilelist('subjectdirs.txt') % reads in list in subject dirs and assigns to var 'subjectdirs'
importfilelist('rundirs.txt') % reads in list in run dirs and assigns to var 'rundirs'
importfilelist('roidirs.txt') % reads in list in roi dirs and assigns to var 'roidirs'
meandataname = 'mean_mask_ts.txt';

numsubs = length(subjectdirs);
numruns = length(rundirs);
numrois = length(roidirs);
numpts = 162; % 162 vols in each run
numzsts = 4;
Y = zeros(numsubs,numruns,numrois,numpts);

%% untangle zstats and evs
tsplotdir = 'tsplot';
pstpdatanames = {...
    'ps_tsplot_zstat1_ev1','ps_tsplot_zstat2_ev2','ps_tsplot_zstat3_ev3','ps_tsplot_zstat4_ev4';...
    'ps_tsplot_zstat1_ev3','ps_tsplot_zstat2_ev4','ps_tsplot_zstat3_ev1','ps_tsplot_zstat4_ev2';...
    'ps_tsplot_zstat1_ev1','ps_tsplot_zstat2_ev3','ps_tsplot_zstat3_ev2','ps_tsplot_zstat4_ev4';...
    'ps_tsplot_zstat1_ev4','ps_tsplot_zstat2_ev3','ps_tsplot_zstat3_ev2','ps_tsplot_zstat4_ev1';...
    'ps_tsplot_zstat1_ev3','ps_tsplot_zstat2_ev1','ps_tsplot_zstat3_ev4','ps_tsplot_zstat4_ev2'};
    

%% loop through all combinations and load data
subidx = 0;
for subjectdir = subjectdirs'
    subidx = subidx +1;
    runidx = 0;
    for rundir = rundirs'
        runidx = runidx +1;
        roiidx = 0;
        for roidir = roidirs'
            roiidx = roiidx +1;
            datadir = strcat(subjectdir{1}, filesep, rundir{1}, filesep, roidir{1});
            meandatafile = strcat(datadir, filesep, meandataname);
            if ~exist(meandatafile,'file')
                disp(meandatafile)
            else
                Y(subidx,runidx,roiidx,:) = load(meandatafile);
                fprintf('sub: %d, run: %d, roi: %d \n',subidx,runidx,roiidx)
            end
        end
    end
end
save('Y.mat','Y','numruns','numrois')
%% plot data
Ymean = squeeze(mean(Y,1));
clf
for roiidx = 1:numrois
    for runidx = 1:numruns
        subplot(numrois,numruns,runidx+((roiidx-1)*numruns))
        y = squeeze(Ymean(runidx,roiidx,:));
        plot(y)
%         axis off
        title(sprintf('run:%d roi:%d',runidx,roiidx))
    end
end

%% clean up
