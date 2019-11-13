[group subjID listno] = textread('subj_list.txt', '%s%s%d');

script_path = pwd;
batch_path = fullfile(script_path,'batch');
cd ..
main_path = pwd;
data_path = fullfile(main_path,'Indiv');

for i = 1:length(subjID)
    
    subj_path = fullfile(data_path,char(subjID(i)),'Ana_spm12');
    
    % Initialise SPM
    %---------------------------------------------------------------------
    spm('Defaults','fMRI');
    spm_jobman('initcfg'); % SPM8 only (does nothing in SPM5)


    % Working directory (useful for .ps outputs only)
    %---------------------------------------------------------------------
    clear jobs
    jobs{1}.util{1}.cdir.directory = cellstr(subj_path); %cellstr(data_path);
    spm_jobman('run',jobs);
    
    % RUN MODEL BATCH
    %---------------------------------------------------------------------
    clear jobs
    
    results_path = fullfile(subj_path,'Results');
    model_path = fullfile(results_path,'model');
    mkdir(model_path)

    sess1_data = spm_select('FPList', fullfile(subj_path,'Sessions','sess1'), '^swarf.*\.img$');
    sess2_data = spm_select('FPList', fullfile(subj_path,'Sessions','sess2'), '^swarf.*\.img$');
    sess3_data = spm_select('FPList', fullfile(subj_path,'Sessions','sess3'), '^swarf.*\.img$');
    
    sess1_rp = spm_select('FPList', fullfile(subj_path,'Sessions','sess1'), '^rp.*\.txt$');
    sess2_rp = spm_select('FPList', fullfile(subj_path,'Sessions','sess2'), '^rp.*\.txt$');
    sess3_rp = spm_select('FPList', fullfile(subj_path,'Sessions','sess3'), '^rp.*\.txt$');
    
    if listno(i) == 1
        jobs{1}.cfg_basicio.runjobs.jobs = cellstr(fullfile(batch_path,'spm12_model_list1_prime.mat'));
    elseif listno(i) == 2
        jobs{1}.cfg_basicio.runjobs.jobs = cellstr(fullfile(batch_path,'spm12_model_list2_prime.mat'));
    elseif listno(i) == 148
        jobs{1}.cfg_basicio.runjobs.jobs = cellstr(fullfile(batch_path,'spm12_model_EPI148.mat'));
    elseif listno(i) == 178
        jobs{1}.cfg_basicio.runjobs.jobs = cellstr(fullfile(batch_path,'spm12_model_EPI178.mat'));
    end;
    
    jobs{1}.cfg_basicio.runjobs.inputs{1}{1}.indir = cellstr(model_path);
    jobs{1}.cfg_basicio.runjobs.inputs{1}{2}.innifti = cellstr(sess1_data);
    jobs{1}.cfg_basicio.runjobs.inputs{1}{3}.inany = cellstr(sess1_rp);
    jobs{1}.cfg_basicio.runjobs.inputs{1}{4}.innifti = cellstr(sess2_data);
    jobs{1}.cfg_basicio.runjobs.inputs{1}{5}.inany = cellstr(sess2_rp);
    jobs{1}.cfg_basicio.runjobs.inputs{1}{6}.innifti = cellstr(sess3_data);
    jobs{1}.cfg_basicio.runjobs.inputs{1}{7}.inany = cellstr(sess3_rp);
    jobs{1}.cfg_basicio.runjobs.save.savejobs.outstub = 'model';
    jobs{1}.cfg_basicio.runjobs.save.savejobs.outdir = cellstr(subj_path);
    jobs{1}.cfg_basicio.runjobs.missing = 'error';
    spm_jobman('serial',jobs);
    
    clear jobs
    if listno(i) == 1
        movefile([subj_path '/model_1.m'],[subj_path '/model_list1_' char(subjID(i)) '.m'])
    elseif listno(i) == 2
        movefile([subj_path '/model_1.m'],[subj_path '/model_list2_' char(subjID(i)) '.m'])
    elseif listno(i) == 148
        movefile([subj_path '/model_1.m'],[subj_path '/model_list1_' char(subjID(i)) '_EPI148.m'])
    elseif listno(i) == 178
        movefile([subj_path '/model_1.m'],[subj_path '/model_list1_' char(subjID(i)) '_EPI178.m'])
    end;
    
    clearvars -except group subjID listno script_path batch_path main_path data_path
end;