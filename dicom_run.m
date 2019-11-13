[group subjID listno] = textread('subj_list.txt', '%s%s%d');

script_path = pwd;
batch_path = fullfile(script_path,'batch');
cd ..
main_path = pwd;
cd ..
raw_path = fullfile(pwd,'Raw_data');
data_path = fullfile(main_path,'Indiv');
cd(data_path)

for i = 1:length(subjID)
    
    subj_path = fullfile(data_path,char(subjID(i)));
    subj_path12 = fullfile(subj_path,'Ana_spm12');
    MP_path12 = fullfile(subj_path12,'Anatomy','MP');
    MP_backup_path12 = fullfile(subj_path12,'Anatomy','MP_raw');
    sess1_path12 = fullfile(subj_path12,'Sessions','sess1');
    sess1_backup_path12 = fullfile(subj_path12,'Sessions','sess1_raw');
    sess2_path12 = fullfile(subj_path12,'Sessions','sess2');
    sess2_backup_path12 = fullfile(subj_path12,'Sessions','sess2_raw');
    sess3_path12 = fullfile(subj_path12,'Sessions','sess3');
    sess3_backup_path12 = fullfile(subj_path12,'Sessions','sess3_raw');
    results_path12 = fullfile(subj_path12,'Results');
    
    if isempty(dir(subj_path)) == 0
        mkdir(subj_path12); mkdir(MP_path12); mkdir(MP_backup_path12); mkdir(sess1_path12); mkdir(sess1_backup_path12); mkdir(sess2_path12); mkdir(sess2_backup_path12); mkdir(sess3_path12); mkdir(sess3_backup_path12); mkdir(results_path12);
        
        MP_path = fullfile(subj_path,'Anatomy','MP');
        MP_backup_path = fullfile(subj_path,'Anatomy','MP_raw');
        sess1_path = fullfile(subj_path,'Sessions','sess1');
        sess1_backup_path = fullfile(subj_path,'Sessions','sess1_raw');
        sess2_path = fullfile(subj_path,'Sessions','sess2');
        sess2_backup_path = fullfile(subj_path,'Sessions','sess2_raw');
        sess3_path = fullfile(subj_path,'Sessions','sess3');
        sess3_backup_path = fullfile(subj_path,'Sessions','sess3_raw');
        
        copyfile(MP_backup_path,MP_path12)
        copyfile(MP_backup_path,MP_backup_path12)
        copyfile(sess1_backup_path,sess1_path12)
        copyfile(sess1_backup_path,sess1_backup_path12)
        copyfile(sess2_backup_path,sess2_path12)
        copyfile(sess2_backup_path,sess2_backup_path12)
        copyfile(sess3_backup_path,sess3_path12)
        copyfile(sess3_backup_path,sess3_backup_path12)
        
    else
       mkdir(subj_path12); mkdir(MP_path12); mkdir(MP_backup_path12); mkdir(sess1_path12); mkdir(sess1_backup_path12); mkdir(sess2_path12); mkdir(sess2_backup_path12); mkdir(sess3_path12); mkdir(sess3_backup_path12); mkdir(results_path12);
     
        % Initialise SPM
        %---------------------------------------------------------------------
        spm('Defaults','fMRI');
        spm_jobman('initcfg'); % SPM8 only (does nothing in SPM5)


        % Working directory (useful for .ps outputs only)
        %---------------------------------------------------------------------
        clear jobs
        jobs{1}.util{1}.cdir.directory = cellstr(subj_path12); %cellstr(data_path);
        spm_jobman('run',jobs);


        % RUN MODEL BATCH
        %---------------------------------------------------------------------
        clear jobs
        
        if char(group(i)) == 'T'
            subj_raw_path = fullfile(raw_path,'subj_tw',char(subjID(i)));
        elseif char(group(i)) == 'F'
            subj_raw_path = fullfile(raw_path,'subj_fr',char(subjID(i)));
        end;

        MP_rawdata = spm_select('FPList', fullfile(subj_raw_path,'MP'), '.IMA*');
        sess1_rawdata = spm_select('FPList', fullfile(subj_raw_path,'sess1'), '.IMA*');
        sess2_rawdata = spm_select('FPList', fullfile(subj_raw_path,'sess2'), '.IMA*');
        sess3_rawdata = spm_select('FPList', fullfile(subj_raw_path,'sess3'), '.IMA*');

        jobs{1}.cfg_basicio.runjobs.jobs = cellstr(fullfile(batch_path,'dicom_batch.mat'));
        jobs{1}.cfg_basicio.runjobs.inputs{1}{1}.inany = cellstr(MP_rawdata);
        jobs{1}.cfg_basicio.runjobs.inputs{1}{2}.indir = cellstr(MP_path12);
        jobs{1}.cfg_basicio.runjobs.inputs{1}{3}.inany = cellstr(sess1_rawdata);
        jobs{1}.cfg_basicio.runjobs.inputs{1}{4}.indir = cellstr(sess1_path12);
        jobs{1}.cfg_basicio.runjobs.inputs{1}{5}.inany = cellstr(sess2_rawdata);
        jobs{1}.cfg_basicio.runjobs.inputs{1}{6}.indir = cellstr(sess2_path12);
        jobs{1}.cfg_basicio.runjobs.inputs{1}{7}.inany = cellstr(sess3_rawdata);
        jobs{1}.cfg_basicio.runjobs.inputs{1}{8}.indir = cellstr(sess3_path12);
        jobs{1}.cfg_basicio.runjobs.save.savejobs.outstub = 'dicom';
        jobs{1}.cfg_basicio.runjobs.save.savejobs.outdir = cellstr(subj_path12);
        jobs{1}.cfg_basicio.runjobs.missing = 'error';
        spm_jobman('serial',jobs);


        clear jobs
        movefile('dicom_1.m',['dicom_' char(subjID(i)) '.m'])

        copyfile(MP_path12,MP_backup_path12)
        copyfile(sess1_path12,sess1_backup_path12)
        copyfile(sess2_path12,sess2_backup_path12)
        copyfile(sess3_path12,sess3_backup_path12)
        
    end;
    
    clearvars -except group subjID listno script_path batch_path main_path raw_path data_path
    
end;