[group, subjID, listno, VOI_name, VOI_coord] = textread('spm12_ppi_list.txt', '%s%s%d%s%s', 'delimiter', ',');

script_path = pwd;
cd ..
main_path = pwd;
data_path = fullfile(main_path,'Indiv');
group_ppi_path = fullfile(main_path,'Group_PPI');

for i = 1:length(subjID)
    
    subj_path = fullfile(data_path,char(subjID(i)),'Ana_spm12');
    results_path = fullfile(subj_path,'Results');
    model_path = fullfile(results_path,'model');
    
    % Initialise SPM
    %---------------------------------------------------------------------
    spm('fMRI');

    spm_jobman('initcfg'); % SPM8 only (does nothing in SPM5)


    % Working directory (useful for .ps outputs only)
    %---------------------------------------------------------------------
    clear jobs
    jobs{1}.util{1}.cdir.directory = cellstr(subj_path); %cellstr(data_path);
    spm_jobman('run',jobs);
        

    % DISPLAY THE CONTRAST RESULTS
    %---------------------------------------------------------------------
    clear jobs
    jobs{1}.stats{1}.results.spmmat = cellstr(fullfile(model_path,'SPM.mat'));
    jobs{1}.stats{1}.results.conspec(1).titlestr = 'Gram-Ungram'; % contrast title
    jobs{1}.stats{1}.results.conspec(1).contrasts = 5; % contrast number
    jobs{1}.stats{1}.results.conspec(1).threshdesc = 'none';
    jobs{1}.stats{1}.results.conspec(1).thresh = 1;
    jobs{1}.stats{1}.results.conspec(1).extent = 0;
    jobs{1}.stats{1}.results.print = 0; % printing = 1, no printing = 0 
    output_list = spm_jobman('run',jobs);


    % updating file names in "SPM.xY.VY"
    % re-directing to the original preprocessing folder
    %---------------------------------------------------------------------
    clear jobs;
    
    %{
    sess1_path = [subj_path '\seman\sess1_136' char(sess_fd(i))];
    sess2_path = [subj_path '\seman\sess2_136' char(sess_fd(i))];
    f1 = spm_select('FPList', fullfile(sess1_path), '^swaf.*\.img$');
    f2 = spm_select('FPList', fullfile(sess2_path), '^swaf.*\.img$');
    fname_temp = [f1;f2];
    
    for j = 1:length(SPM.xY.VY)
        SPM.xY.VY(j).fname = fname_temp(j,:);
    end;
    %}


    % EXTRACT THE EIGENVARIATE
    %---------------------------------------------------------------------
    xY.xyz  = spm_mip_ui('SetCoords',eval(char(VOI_coord(i))));
    xY.name = char(VOI_name(i));
    xY.Ic   = 0;
    xY.Sess = 1;
    xY.def  = 'sphere';
    xY.spec = 6;
    [Y,xY]  = spm_regions(xSPM,SPM,hReg,xY);
    VOI_filname1 = ['VOI_' xY.name '_1.pdf'];
    saveas(gcf,VOI_filname1);

    % EXTRACT THE EIGENVARIATE
    %---------------------------------------------------------------------
    xY.xyz  = spm_mip_ui('SetCoords',eval(char(VOI_coord(i))));
    xY.name = char(VOI_name(i));
    xY.Ic   = 0;
    xY.Sess = 2;
    xY.def  = 'sphere';
    xY.spec = 6;
    [Y,xY]  = spm_regions(xSPM,SPM,hReg,xY);
    VOI_filname2 = ['VOI_' xY.name '_2.pdf'];
    saveas(gcf,VOI_filname2);
    
    % EXTRACT THE EIGENVARIATE
    %---------------------------------------------------------------------
    xY.xyz  = spm_mip_ui('SetCoords',eval(char(VOI_coord(i))));
    xY.name = char(VOI_name(i));
    xY.Ic   = 0;
    xY.Sess = 3;
    xY.def  = 'sphere';
    xY.spec = 6;
    [Y,xY]  = spm_regions(xSPM,SPM,hReg,xY);
    VOI_filname3 = ['VOI_' xY.name '_3.pdf'];
    saveas(gcf,VOI_filname3);

    % GENERATE PPI STRUCTURE
    %=====================================================================
    VOI_name1 = ['VOI_' char(VOI_name(i)) '_1.mat'];
    load(VOI_name1);
    PPI_temp1 = ['sess1_' char(VOI_name(i)) '_' char(subjID(i))];
    PPI = spm_peb_ppi(fullfile(model_path,'SPM.mat'),'ppi',xY,...
        [1 1 -1;2 1 1],PPI_temp1,1);
    PPI_filname1 = ['PPI_' PPI_temp1 '.pdf'];
    saveas(gcf,PPI_filname1);
    clear Y xy PPI;
    
    VOI_name2 = ['VOI_' char(VOI_name(i)) '_2.mat'];
    load(VOI_name2);
    PPI_temp2 = ['sess2_' char(VOI_name(i)) '_' char(subjID(i))];
    PPI = spm_peb_ppi(fullfile(model_path,'SPM.mat'),'ppi',xY,...
        [1 1 -1;2 1 1],PPI_temp2,1);
    PPI_filname2 = ['PPI_' PPI_temp2 '.pdf'];
    saveas(gcf,PPI_filname2);
    clear Y xy PPI;

    VOI_name3 = ['VOI_' char(VOI_name(i)) '_3.mat'];
    load(VOI_name3);
    PPI_temp3 = ['sess3_' char(VOI_name(i)) '_' char(subjID(i))];
    PPI = spm_peb_ppi(fullfile(model_path,'SPM.mat'),'ppi',xY,...
        [1 1 -1;2 1 1],PPI_temp3,1);
    PPI_filname3 = ['PPI_' PPI_temp3 '.pdf'];
    saveas(gcf,PPI_filname3);
    clear Y xy PPI;
    
    % OUTPUT DIRECTORY
    %---------------------------------------------------------------------
    %{
    clear jobs
    PPI_path = fullfile(results_path,'PPI',char(VOI_name(i)));
    jobs{1}.util{1}.md.basedir = cellstr(PPI_path);
    jobs{1}.util{1}.md.name = 'Gram-Ungram';
    spm_jobman('run',jobs);
    %}
    
    % MODEL SPECIFICATION
    %=====================================================================
    clear jobs
    
    PPI_name1 = ['PPI_' PPI_temp1 '.mat'];
    PPI_name2 = ['PPI_' PPI_temp2 '.mat'];
    PPI_name3 = ['PPI_' PPI_temp3 '.mat'];
    PPI1 = load(PPI_name1);
    PPI2 = load(PPI_name2);
    PPI3 = load(PPI_name3);
    PPI_path = fullfile(results_path,'PPI','Gram-Ungram',char(VOI_name(i)));
    output_path = fullfile(PPI_path, 'output_file');
    mkdir(output_path)
    
    movefile(PPI_name1,PPI_path)
    movefile(PPI_name2,PPI_path)
    movefile(PPI_name3,PPI_path)
    movefile(VOI_name1,PPI_path)
    movefile(VOI_name2,PPI_path)
    movefile(VOI_name3,PPI_path)
    
    movefile(VOI_filname1,output_path)
    movefile(VOI_filname2,output_path)
    movefile(VOI_filname3,output_path)
    movefile(PPI_filname1,output_path)
    movefile(PPI_filname2,output_path)
    movefile(PPI_filname3,output_path)

    % Directory
    %---------------------------------------------------------------------
    jobs{1}.stats{1}.fmri_spec.dir = cellstr(PPI_path);

    % Timing
    %---------------------------------------------------------------------
    jobs{1}.stats{1}.fmri_spec.timing.units = 'scans';
    jobs{1}.stats{1}.fmri_spec.timing.RT = 2;

    % Scans
    %---------------------------------------------------------------------
    f1 = spm_select('FPList', fullfile(subj_path,'Sessions','sess1'), '^swarf.*\.img$');
    f2 = spm_select('FPList', fullfile(subj_path,'Sessions','sess2'), '^swarf.*\.img$');
    f3 = spm_select('FPList', fullfile(subj_path,'Sessions','sess3'), '^swarf.*\.img$');
    
    jobs{1}.stats{1}.fmri_spec.sess(1).scans = cellstr(f1);
    jobs{1}.stats{1}.fmri_spec.sess(2).scans = cellstr(f2);
    jobs{1}.stats{1}.fmri_spec.sess(3).scans = cellstr(f3);

    % Regressors
    %---------------------------------------------------------------------
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(1).name = 'PPI';
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(1).val  = PPI1.PPI.ppi;
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(2).name = 'P';
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(2).val  = PPI1.PPI.P;
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(3).name = 'Y';
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(3).val  = PPI1.PPI.Y;
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(1).name = 'PPI';
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(1).val  = PPI2.PPI.ppi;
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(2).name = 'P';
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(2).val  = PPI2.PPI.P;
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(3).name = 'Y';
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(3).val  = PPI2.PPI.Y;
    jobs{1}.stats{1}.fmri_spec.sess(3).regress(1).name = 'PPI';
    jobs{1}.stats{1}.fmri_spec.sess(3).regress(1).val  = PPI3.PPI.ppi;
    jobs{1}.stats{1}.fmri_spec.sess(3).regress(2).name = 'P';
    jobs{1}.stats{1}.fmri_spec.sess(3).regress(2).val  = PPI3.PPI.P;
    jobs{1}.stats{1}.fmri_spec.sess(3).regress(3).name = 'Y';
    jobs{1}.stats{1}.fmri_spec.sess(3).regress(3).val  = PPI3.PPI.Y;
    
    % MODEL ESTIMATION
    %=====================================================================
    jobs{1}.stats{2}.fmri_est.spmmat = cellstr(fullfile(PPI_path,'SPM.mat'));

    spm_jobman('run',jobs);


    % INFERENCE & RESULTS
    %=====================================================================
    clear jobs
    jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(PPI_path,'SPM.mat'));
    jobs{1}.stats{1}.con.consess{1}.tcon.name = 'Interaction';
    jobs{1}.stats{1}.con.consess{1}.tcon.convec = [1 0 0 1 0 0 1 0 0];
    jobs{1}.stats{1}.con.consess{2}.tcon.name = 'Psy';
    jobs{1}.stats{1}.con.consess{2}.tcon.convec = [0 1 0 0 1 0 0 1 0];
    jobs{1}.stats{1}.con.consess{3}.tcon.name = 'Phy';
    jobs{1}.stats{1}.con.consess{3}.tcon.convec = [0 0 1 0 0 1 0 0 1];
    spm_jobman('run',jobs);
    
    % DISPLAY THE CONTRAST RESULTS
    %---------------------------------------------------------------------
    clear jobs
    jobs{1}.stats{1}.results.spmmat = cellstr(fullfile(PPI_path,'SPM.mat'));
    jobs{1}.stats{1}.results.conspec(1).titlestr = 'Interaction'; % contrast title
    jobs{1}.stats{1}.results.conspec(1).contrasts = 1; % contrast number
    jobs{1}.stats{1}.results.conspec(1).threshdesc = 'none';
    jobs{1}.stats{1}.results.conspec(1).thresh = 0.05;
    jobs{1}.stats{1}.results.conspec(1).extent = 10;
    jobs{1}.stats{1}.results.print = 1; % printing = 1, no printing = 0 
    output_list = spm_jobman('run',jobs);
    
    source_nii = fullfile(PPI_path, 'con_0001.nii');
    
    ppigroup_path = fullfile(group_ppi_path,'Gram-Ungram',char(VOI_name(i)),'confiles');
    if isempty(dir(ppigroup_path)) == 1
        mkdir(ppigroup_path)
    end;
    
    dest_nii = fullfile(ppigroup_path, [char(subjID(i)) '_con_0001.nii']);
    copyfile(source_nii,dest_nii)

    clear jobs
    clearvars -except group subjID listno VOI_name VOI_coord script_path main_path data_path group_ppi_path
end