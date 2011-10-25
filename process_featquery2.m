function process_featquery2()
% proccess featquery results from pvem experiment
% mark.bolding@gmail.com

RAWDATA = 2;
PARTIALFIT = 3;
MODELFIT = 4;
REDUCED = 5;
datacoltype = REDUCED;
stattype = 'maxzstat';

%% directory and file name lists
subjectdirs = {};
rundirs = {};
roidirs = {};
importfilelist('subjectdirs.txt') % reads in list in subject dirs and assigns to var 'subjectdirs'
importfilelist('rundirs.txt') % reads in list in run dirs and assigns to var 'rundirs'
importfilelist('roidirs.txt') % reads in list in roi dirs and assigns to var 'roidirs'
% meandataname = 'mean_mask_ts.txt';

numsubs = length(subjectdirs);
numruns = length(rundirs);
numrois = length(roidirs);
numpts = 16; % 16 vols in each block
numzsts = 4;
Y = zeros(numsubs,numruns,numrois,numzsts,numpts);

%% untangle zstats and evs
tsplotdir = 'tsplot';
switch stattype
    case 'clusterzstat'
        pstpdatanames = {...
            'ps_tsplotc_zstat1_ev1','ps_tsplotc_zstat2_ev3','ps_tsplotc_zstat3_ev5','ps_tsplotc_zstat4_ev7';...
            'ps_tsplotc_zstat1_ev5','ps_tsplotc_zstat2_ev7','ps_tsplotc_zstat3_ev1','ps_tsplotc_zstat4_ev3';...
            'ps_tsplotc_zstat1_ev1','ps_tsplotc_zstat2_ev5','ps_tsplotc_zstat3_ev3','ps_tsplotc_zstat4_ev7';...
            'ps_tsplotc_zstat1_ev7','ps_tsplotc_zstat2_ev5','ps_tsplotc_zstat3_ev3','ps_tsplotc_zstat4_ev1';...
            'ps_tsplotc_zstat1_ev5','ps_tsplotc_zstat2_ev1','ps_tsplotc_zstat3_ev7','ps_tsplotc_zstat4_ev3'};
    case 'clusterzfstat'
        pstpdatanames = {...
            'ps_tsplotc_zfstat1_ev1','ps_tsplotc_zfstat1_ev3','ps_tsplotc_zfstat1_ev5','ps_tsplotc_zfstat1_ev7';...
            'ps_tsplotc_zfstat1_ev5','ps_tsplotc_zfstat1_ev7','ps_tsplotc_zfstat1_ev1','ps_tsplotc_zfstat1_ev3';...
            'ps_tsplotc_zfstat1_ev1','ps_tsplotc_zfstat1_ev5','ps_tsplotc_zfstat1_ev3','ps_tsplotc_zfstat1_ev7';...
            'ps_tsplotc_zfstat1_ev7','ps_tsplotc_zfstat1_ev5','ps_tsplotc_zfstat1_ev3','ps_tsplotc_zfstat1_ev1';...
            'ps_tsplotc_zfstat1_ev5','ps_tsplotc_zfstat1_ev1','ps_tsplotc_zfstat1_ev7','ps_tsplotc_zfstat1_ev3'};
    case 'maxzfstat'
        pstpdatanames = {...
            'ps_tsplot_zfstat1_ev1','ps_tsplot_zfstat1_ev3','ps_tsplot_zfstat1_ev5','ps_tsplot_zfstat1_ev7';...
            'ps_tsplot_zfstat1_ev5','ps_tsplot_zfstat1_ev7','ps_tsplot_zfstat1_ev1','ps_tsplot_zfstat1_ev3';...
            'ps_tsplot_zfstat1_ev1','ps_tsplot_zfstat1_ev5','ps_tsplot_zfstat1_ev3','ps_tsplot_zfstat1_ev7';...
            'ps_tsplot_zfstat1_ev7','ps_tsplot_zfstat1_ev5','ps_tsplot_zfstat1_ev3','ps_tsplot_zfstat1_ev1';...
            'ps_tsplot_zfstat1_ev5','ps_tsplot_zfstat1_ev1','ps_tsplot_zfstat1_ev7','ps_tsplot_zfstat1_ev3'};
    case 'maxzstat'
        pstpdatanames = {...
            'ps_tsplot_zstat1_ev1','ps_tsplot_zstat2_ev3','ps_tsplot_zstat3_ev5','ps_tsplot_zstat4_ev7';...
            'ps_tsplot_zstat1_ev5','ps_tsplot_zstat2_ev7','ps_tsplot_zstat3_ev1','ps_tsplot_zstat4_ev3';...
            'ps_tsplot_zstat1_ev1','ps_tsplot_zstat2_ev5','ps_tsplot_zstat3_ev3','ps_tsplot_zstat4_ev7';...
            'ps_tsplot_zstat1_ev7','ps_tsplot_zstat2_ev5','ps_tsplot_zstat3_ev3','ps_tsplot_zstat4_ev1';...
            'ps_tsplot_zstat1_ev5','ps_tsplot_zstat2_ev1','ps_tsplot_zstat3_ev7','ps_tsplot_zstat4_ev3'};

end
% zstsnames = {'sacc','spem','vergtr','vergst'};

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
%                     fprintf('sub:%d, run:%d, roi:%d, %s:%d ',subidx,runidx,roiidx,stattype,zstidx)
                    pstpdata = load(pstpdatafile);
                    if size(pstpdata,1) == 64;
                        pstpdata = pstpdata(:,datacoltype); % load the data column from the psts file
                        pstpdata = sum(reshape(pstpdata,[],4),2)/4;
                        Y(subidx,runidx,roiidx,zstidx,:) = pstpdata;
                    else
                        fprintf('not enough pts ')
                        disp(pstpdatafile)
                    end
%                     fprintf('sub:%d, run:%d, roi:%d, %s:%d \n',subidx,runidx,roiidx,stattype,zstidx)
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
datasavename = ['Y' stattype '.mat'];
save(datasavename,'Y','Ymean','numruns','numrois','numzsts','missingcount','usedcount','roidirs')

%% plot data
clf
Yrng = [-5 140];
for roiidx = 1:numrois   
    subplot(numrois/2,2,roiidx)
    y = squeeze(Ymean(roiidx,:,:))';
    y = y - repmat(y(1,:),size(y,1),1); % start them all at same point
    t = 0:2.5:39;
    plot(t,y)
    hold on
    plot([20 20], Yrng, 'k:')
    hold off
%     axis off
    roititle = roidirs{roiidx}(10:end-11);
    roititle = strrep(roititle,'_',' ');
    title(sprintf('%s',roititle))
    ylim(Yrng)
end
legend('sacc','spem','vergtr','vergst','Location','Best')
disp(['missing:' num2str(missingcount) '  used:' num2str(usedcount)])
%% clean up
