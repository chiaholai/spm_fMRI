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
    spm('fMRI');
    spm_jobman('initcfg'); % SPM8 only (does nothing in SPM5)


    % Working directory (useful for .ps outputs only)
    %---------------------------------------------------------------------
    clear jobs
    jobs{1}.util{1}.cdir.directory = cellstr(subj_path); %cellstr(data_path);
    spm_jobman('run',jobs);
    
    
    % RUN MODEL BATCH
    %---------------------------------------------------------------------
    clear jobs
    
    MP_data = spm_select('FPList', fullfile(subj_path,'Anatomy','MP'), '^s.*\.img$');
    sess1_data = spm_select('FPList', fullfile(subj_path,'Sessions','sess1'), '^f.*\.img$');
    sess2_data = spm_select('FPList', fullfile(subj_path,'Sessions','sess2'), '^f.*\.img$');
    sess3_data = spm_select('FPList', fullfile(subj_path,'Sessions','sess3'), '^f.*\.img$');
    
    jobs{1}.cfg_basicio.runjobs.jobs = cellstr(fullfile(batch_path,'spm12_preproc_batch.mat'));
    jobs{1}.cfg_basicio.runjobs.inputs{1}{1}.innifti = cellstr(sess1_data);
    jobs{1}.cfg_basicio.runjobs.inputs{1}{2}.innifti = cellstr(sess2_data);
    jobs{1}.cfg_basicio.runjobs.inputs{1}{3}.innifti = cellstr(sess3_data);
    jobs{1}.cfg_basicio.runjobs.inputs{1}{4}.innifti = cellstr(MP_data);
    jobs{1}.cfg_basicio.runjobs.save.savejobs.outstub = 'preproc';
    jobs{1}.cfg_basicio.runjobs.save.savejobs.outdir = cellstr(subj_path);
    jobs{1}.cfg_basicio.runjobs.missing = 'error';
    spm_jobman('serial',jobs);
    
    clear jobs
    movefile([subj_path '/preproc_1.m'],[subj_path '/preproc_' char(subjID(i)) '.m'])
    ps_temp = dir('*.ps');
    movefile(ps_temp.name,['preproc_' char(subjID(i)) '.ps'])
    clearvars -except group subjID listno script_path batch_path main_path data_path
end;