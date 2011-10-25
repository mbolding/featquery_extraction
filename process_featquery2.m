function process_featquery2()
% proccess featquery results from pvem experiment
% mark.bolding@gmail.com

clf

%% directory and file name lists
importfilelist('subjectdirs.txt') % reads in list in subject dirs and assigns to var 'subjectdirs'
importfilelist('rundirs.txt') % reads in list in run dirs and assigns to var 'rundirs'
importfilelist('roidirs.txt') % reads in list in roi dirs and assigns to var 'roidirs'
meandataname = 'mean_mask_ts.txt';

numsubs = length(subjectdirs);
numruns = length(rundirs);
numrois = length(roidirs);
numpts = 16; % 16 vols in each block
numzsts = 4;
Y = zeros(numsubs,numruns,numrois,numzsts,numpts);

%% untangle zstats and evs
tsplotdir = 'tsplot';
pstpdatanames = {...
    'ps_tsplotc_zstat1_ev1','ps_tsplotc_zstat2_ev2','ps_tsplotc_zstat3_ev3','ps_tsplotc_zstat4_ev4';...
    'ps_tsplotc_zstat1_ev3','ps_tsplotc_zstat2_ev4','ps_tsplotc_zstat3_ev1','ps_tsplotc_zstat4_ev2';...
    'ps_tsplotc_zstat1_ev1','ps_tsplotc_zstat2_ev3','ps_tsplotc_zstat3_ev2','ps_tsplotc_zstat4_ev4';...
    'ps_tsplotc_zstat1_ev4','ps_tsplotc_zstat2_ev3','ps_tsplotc_zstat3_ev2','ps_tsplotc_zstat4_ev1';...
    'ps_tsplotc_zstat1_ev3','ps_tsplotc_zstat2_ev1','ps_tsplotc_zstat3_ev4','ps_tsplotc_zstat4_ev2'};

zstsnames = {'sacc','spem','vergtr','vergest'};   

%% loop through all combinations and load data
missingcount = 0;
usedcount = 0;
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
            for zstidx = 1:numzsts
                pstpdataname = [pstpdatanames{runidx,zstidx} '.txt'];
                pstpdatafile = strcat(datadir, filesep, tsplotdir, filesep, pstpdataname);
                if ~exist(pstpdatafile,'file')
                    disp(['missing: ' pstpdatafile])
                    missingcount = missingcount +1;
                else
                    pstpdata = load(pstpdatafile);
                    pstpdata = pstpdata(:,4);
                    pstpdata = sum(reshape(pstpdata,[],4),2)/4;
                    plot(pstpdata)
                    Y(subidx,runidx,roiidx,zstidx,:) = pstpdata;
                    fprintf('sub:%d, run:%d, roi:%d, zstat:%d \n',subidx,runidx,roiidx,zstidx)
                    usedcount = usedcount +1; 
                end
            end
        end
    end
end
save('Y.mat','Y','numruns','numrois','numzsts','missingcount','usedcount')

%% average data
Ymean = squeeze(mean(Y,1)); % average over subjects
Ymean = squeeze(mean(Ymean,1)); % average over runs

%% save data
save('Y.mat','Y','Ymean','numruns','numrois','numzsts','missingcount','usedcount','roidirs')

%% plot data

for roiidx = 1:numrois
    for zstidx = 1:numzsts
        subplot(numrois,numzsts,zstidx+((roiidx-1)*numzsts))
        y = squeeze(Ymean(roiidx,zstidx,:));
        plot(y)
        axis off
        roititle = roidirs{roiidx}(10:end-11);
        roititle = strrep(roititle,'_',' ');
        title(sprintf('%s : %s',roititle,zstsnames{zstidx}))
    end
end
disp(['missing:' num2str(missingcount) '  used:' num2str(usedcount)])
%% clean up
