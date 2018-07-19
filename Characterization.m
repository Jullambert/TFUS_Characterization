%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyse des données des acquises lors des mesures réalisées en WELCOME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ! Tous les fichiers à analyser doivent se trouver dans un dossier qui lui même se trouve dans le dossier Tests_Setup_Welcome à l'emplacement E: 
% Ce script réalise les opérations uivantes :
%           1. Création de constantes et préallocations mémoire de
%           variables
%           2. Import et remise dans l'ordre de la liste des fichiers existant dans le dossier
%           pointer lors de l'apparition de la fenêtre prévue à cet effet.
% 

clc
clear all
%% 1: Import of the parameters
% Parameters for the analysis are stored in an Excel file
Params=readtable('D:\data\jlambert\TFUS_Mesures_Welcome\AnalysisParameters.xlsx');
DfN = 290; %  the row number to analyze which correspond to a file
disp('1 : Parameters imported')
%% 2: Initialization of the variables
%Stimulation parameters
UltrasoundBurstPeriod = 1/Params.UltrasoundBurstFrequency(DfN);
ToneBurstDuration = Params.NumberOfCycles(DfN) * UltrasoundBurstPeriod ;% [s]
DutyCycle = ToneBurstDuration * Params.PRF(DfN);
if ~Params.CalibrationPrototype(DfN)
    % If Calibration prototype =0 : meaning that it's a measurement transversal plan to analyze
    % If Calibration prototype =1 : meaning that it's multiple measurmeents
    % performed with the calibration prototype
    Xvector=Params.Xinit(DfN):Params.Xstep(DfN):Params.Xend(DfN) ;   
    Yvector=Params.Yinit(DfN):Params.Ystep(DfN):Params.Yend(DfN) ;
    % Matrix with the indices relative to the steps performed during a measurement session, following the snake pattern of the stage movement 
    s=1;
    v=zeros(length(Xvector),length(Yvector));
    for y=1:length(Yvector)
        for x=1:length(Xvector)
            v(x,y)=s;
            s=s+1;
        end;
    end;
    % Boucle utilisée afin de respecter le schema de déplacement "en snake" de la table
    % x-y
    for y=2:2:length(Yvector)%YTableEnd;
        v(:,y)=flip(v(:,y));
    end;

    %  FFT Parameters
    NSamples = 2^14;
    T= [0:(NSamples-1)]/Params.SamplingFrequency(DfN);
    Freq_Axis = (-Params.SamplingFrequency(DfN)/2)+[0:NSamples-1]/NSamples*Params.SamplingFrequency(DfN); % Permet de créer un vecteur qui va de -fs/2 à 1 echnatillon avant Fs/2
    Haar = (-1).^([0:NSamples-1]); % permet de recentrer les données en 0
    Haar = Haar';
    IndexFreqInterest = round(Params.UltrasoundBurstFrequency(DfN)/Params.SamplingFrequency(DfN)*NSamples+NSamples/2+1);

    FunctionGenVoltage = zeros(length(Xvector),length(Yvector),Params.NumberSamplesRecorded(DfN));
    HydrophoneVoltage = zeros(length(Xvector),length(Yvector),Params.NumberSamplesRecorded(DfN));
    FunctionGenTimeVector = zeros(length(Xvector),length(Yvector),Params.NumberSamplesRecorded(DfN));

    FunctionGenOffset(x,y,:) = mean(FunctionGenVoltage(x,y,1:5000));
    HydrophoneOffset(x,y,:) = mean(HydrophoneVoltage(x,y,1:5000));
    FunctionGenVoltage_Corr = zeros(length(Xvector),length(Yvector),Params.NumberSamplesRecorded(DfN));
    HydrophoneVoltage_Corr = zeros(length(Xvector),length(Yvector),Params.NumberSamplesRecorded(DfN));

    FunctionGenVoltage_Corr_Filtered = zeros(length(Xvector),length(Yvector),Params.NumberSamplesRecorded(DfN));
    HydrophoneVoltage_Corr_Filtered = zeros(length(Xvector),length(Yvector),Params.NumberSamplesRecorded(DfN));

    FunctionGenPeakValue = zeros(length(Xvector),length(Yvector));
    FunctionGenPeakCycle = zeros(length(Xvector),length(Yvector));
    HydrophonePeakValue = zeros(length(Xvector),length(Yvector));
    HydrophonePeakCycle = zeros(length(Xvector),length(Yvector));
    DeltaFunctionGenHydrophone = zeros(length(Xvector),length(Yvector));

    PII = zeros(length(Xvector),length(Yvector));
    Ipa = zeros(length(Xvector),length(Yvector));
    Ita = zeros(length(Xvector),length(Yvector));
    MI = zeros(length(Xvector),length(Yvector));
    TI = zeros(length(Xvector),length(Yvector));

    IsppaXDistance = zeros(length(Xvector),length(Yvector));% Distance en [mm]
    IsppaYDistance = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
    IsppaDistanceDerating = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
    IsppaDerated = zeros(length(Xvector),length(Yvector));
    LinearAttenuationCoeff = zeros(length(Xvector),length(Yvector));

    % Calcul Ispta derated
    IsptaXDistance = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
    IsptaYDistance = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
    IsptaDistanceDerating = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
    IsptaDerated = zeros(length(Xvector),length(Yvector));

    % Calcul MI derated
    MIXDistance = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
    MIYDistance = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
    MIDistanceDerating = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
    MIDerated = zeros(length(Xvector),length(Yvector));

    FWHM = zeros(length(Xvector),length(Yvector)); 
    FWHMRow = zeros(length(Xvector));
    FWHMCol = zeros(length(Yvector));

    FunctionGenVoltageBurstCut = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
    HydrophoneVoltageBurstCut = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
    FunctionGenVoltageBurstVect_FFT = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
    FFT_Burst_Tension_FunGen_Amp_Freq_Intererst = zeros(length(Xvector),length(Yvector));
    FFT_Burst_Tension_Hydro_Amp_Freq_Intererst = zeros(length(Xvector),length(Yvector));
    FFTPhaseshift = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
    Amplitude_FFT_ = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
    HydrophoneVoltageBurstVect_FFT = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
    FunctionGenVoltageBurstVect_Complex = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
    HydrophoneVoltageBurstVect_Complex = zeros(length(Xvector),length(Yvector),length(Freq_Axis)); 
end
disp('2 : Initialization of the variables done')
%% 3: Import data to analyze
if Params.CalibrationPrototype(DfN)
    if isempty(strfind(Params.DataFilename{DfN},'.mat')) % if reference to a folder that was not yet analyzed
        disp('Beginning to importa data')
%         dir(strcat(Params.DataFilename{DfN},'.tdms'))
        cd(Params.DataFilename{DfN})
        DataFilesName = dir(Params.DataFilename{DfN});
        DataFilesName(1:2) = []; % delete . and .
        NameFile = {};
        for i=1:length(DataFilesName)
            filename = fullfile(Params.DataFilename{DfN},DataFilesName(i).name);
            NameFile{i,1} = filename;
        end;
        % Boucle pour trier par ordre numérique des différents "Steps" de mesure les fichiers contenus dans le dossier pointer par RootDir
        for ii=1:length(DataFilesName)
            st=NameFile{ii};
            idx=strfind(st,'Num_Step_')+9;
            idx2=strfind(st,'X_Coordinate')-1;
            stval(ii)=str2num(st(idx:idx2));
            [a,b]=sort(stval);
        end;
        NameFile2=NameFile(b);
        %Loop to import data
        for j=1:length(NameFile2)
                if Params.PXI(DfN)
                    [finalOutput,metaStruct] = TDMS_readTDMSFile(NameFile2{j,1});
                    FunctionGenVoltage(j,1:length(finalOutput.data{:,3})) = finalOutput.data{:,3};
                    HydrophoneVoltage(j,1:length(finalOutput.data{:,4})) = finalOutput.data{:,4};
                    DeltaT = finalOutput.propValues{1,3}{1,3};
                    FunctionGenTimeVector(j,1:length(finalOutput.data{:,3})) = (0:DeltaT(1):(length(FunctionGenVoltage(x,y,:))-1)*DeltaT(1));
                    FilenameMatrix{j,:}=NameFile2{j,1};  
                clear finalOutput
                clear metaStruct
                else
                    [finalOutput,metaStruct] = TDMS_readTDMSFile(NameFile2{j,1});
                    HydrophoneVoltage(j,1:length(finalOutput.data{:,4})) = finalOutput.data{:,3};
                end
        end
    else % condition for loading data from files that were already analyzed
        if Params.PXI(DfN)
            load(Params.DataFilename{DfN},'Tension_FunctionGen','Tension_Hydrophone','VecteurTemps_FunctionGen','listing2') 
            FunctionGenVoltage=Tension_FunctionGen;
            HydrophoneVoltage=Tension_Hydrophone;
            FunctionGenTimeVector = VecteurTemps_FunctionGen;
            DataFilename = listing2;
            clear Tension_FunctionGen
            clear Tension_Hydrophone
            clear VecteurTemps_FunctionGen
            clear listing2;
        else
            switch Params.VppFunGen
                case 0.6
                    load(Params.DataFilename{DfN},'Tension_Hydrophone_06Vpp_200C_300kHz','VecteurTemps_FunctionGen')
                case 1
                    switch Params.NumberOfCycles
                        case 5
                            load(Params.DataFilename{DfN},'Tension_Hydrophone_1Vpp_5C_300kHz','VecteurTemps_FunctionGen')
                        case 200
                            load(Params.DataFilename{DfN},'Tension_Hydrophone_1Vpp_200C_300kHz','VecteurTemps_FunctionGen')                            
                    end
            end
             
        end
    end

   
else
    if isempty(strfind(Params.DataFilename{DfN},'.mat')) % if reference to a folder that was not yet analyzed
        disp('Beginning to importa data from folder')
%         dir(strcat(Params.DataFilename{DfN},'.tdms'))
        cd(Params.DataFilename{DfN})
        DataFilesName = dir(Params.DataFilename{DfN});
        DataFilesName(1:2) = []; % delete . and .
        NameFile = {};
        for i=1:length(DataFilesName)
            filename = fullfile(Params.DataFilename{DfN},DataFilesName(i).name);
            NameFile{i,1} = filename;
        end;
        % Boucle pour trier par ordre numérique des différents "Steps" de mesure les fichiers contenus dans le dossier pointer par RootDir
        for ii=1:length(DataFilesName)
            st=NameFile{ii};
            idx=strfind(st,'Num_Step_')+9;
            idx2=strfind(st,'X_Coordinate')-1;
            stval(ii)=str2num(st(idx:idx2));
            [a,b]=sort(stval);
        end;
        NameFile2=NameFile(b);
        %Loop to import data
            for x=1:size(v,1)
                for y=1:size(v,2)
                    x;
                    y;
                    if Params.TDMSfile(DfN)
                        [finalOutput,metaStruct] = TDMS_readTDMSFile(NameFile2{v(x,y)});
                        FunctionGenVoltage(x,y,1:length(finalOutput.data{:,3})) = finalOutput.data{:,3};
                        HydrophoneVoltage(x,y,1:length(finalOutput.data{:,4})) = finalOutput.data{:,4};
                        DeltaT = finalOutput.propValues{1,3}{1,3};
                        FunctionGenTimeVector(x,y,1:length(finalOutput.data{:,3})) = (0:DeltaT(1):(length(FunctionGenVoltage(x,y,:))-1)*DeltaT(1));
                        FilenameMatrix{x,y,:}=NameFile2{v(x,y)};  
                    clear finalOutput
                    clear metaStruct
                    else
                        fid = fopen(NameFile2{v(x,y)});
                        content = fscanf(fid,'%c');
                            if Params.LV2015(DfN)
                                A = importfile_2columns_LV2015(NameFile2{v(x,y)});
                                DeltaT = str2num(content(strfind(content,'delta t')+7:strfind(content,'time')-1)) ;%% Recherche du delta T défini lors de l'acquisition de données 
                                 DeltaT=1/Params.SamplingFrequency(DfN);
                            else
                                A = importfile_2columns(NameFile2{v(x,y)});
                                DeltaT = str2num(content(strfind(content,'delta t')+7:strfind(content,'time')-1)) ;%% Recherche du delta T défini lors de l'acquisition de données 
                            end     
                        FunctionGenVoltage(x,y,1:length(A.Volt0)) = A.Volt0;
                        HydrophoneVoltage(x,y,1:length(A.Volt1)) = A.Volt1;
                        FunctionGenTimeVector(x,y,1:length(A.Volt0)) = (0:DeltaT(1):(length(FunctionGenVoltage(x,y,:))-1)*DeltaT(1));
                        FilenameMatrix{x,y,:}=NameFile2{v(x,y)};     
                        clear A
                        fclose(fid);
                    end
                end
            end
    else % condition for loading data from files that were already analyzed
        load(Params.DataFilename{DfN},'Tension_FunctionGen','Tension_Hydrophone','VecteurTemps_FunctionGen','MatrixNameFile_5Cycles') 
        FunctionGenVoltage=Tension_FunctionGen;
        HydrophoneVoltage=Tension_Hydrophone;
        FunctionGenTimeVector = VecteurTemps_FunctionGen;
        FilenameMatrix = MatrixNameFile_5Cycles;
        clear Tension_FunctionGen
        clear Tension_Hydrophone
        clear VecteurTemps_FunctionGen
        clear MatrixNameFile_5Cycles
    end
end

cd('D:\data\jlambert\TFUS_Mesures_Welcome\ResultsAnalysis');
disp('3 : Data imported')
%% 4 : Calcul afin de 1. Réajuster par rapport à l'offset, 2. déterminer le temps et la valeur des premiers pics émis par le générateur de fonctions et 3.déterminer le temps et la valeur des premiers picsreçus par l'hydrophone
% Filtrage des données
[B A] = butter(2,Params.CutOffFrequency(DfN)/(Params.SamplingFrequency(DfN)/2),'low');
% Détection des premiers pics sur base des valeurs filtrées
if Params.CalibrationPrototype(DfN)
    if Params.PXI(DfN)
        for j=1:size(HydrophoneVoltage,1)
                    %Calcul de l'offset pour les deux séries de valeurs
            FunctionGenOffset(j,:) = mean(FunctionGenVoltage(j,1:5000));
            HydrophoneOffset(j,:) = mean(HydrophoneVoltage(j,1:5000));
            %Correction de l'offset
            FunctionGenVoltage_Corr(j,:)= FunctionGenVoltage(j,:) - FunctionGenOffset(j,:);
            HydrophoneVoltage_Corr(j,:)= HydrophoneVoltage(j,:) - HydrophoneOffset(j,:);
            %Calculs pour le Generateur de fonctions
            FunctionGenVoltage_Corr_Filtered(j,:)= filtfilt(B, A,FunctionGenVoltage_Corr(j,:));
            HydrophoneVoltage_Corr_Filtered(j,:)= filtfilt(B, A,HydrophoneVoltage_Corr(j,:));
            FunctionGenVoltagevect = squeeze(FunctionGenVoltage_Corr_Filtered(j,10000:end));
            [ValPic, NumCycle] = findpeaks(FunctionGenVoltagevect,'MINPEAKHEIGHT',Params.Threshold_FuncGen(DfN));
            FunctionGenPeakValue(j,:) = ValPic(1);
            FunctionGenPeakCycle(j,:) = NumCycle(1)+9999;
            %Calculs pour l'hydrophone
            HydrophoneVoltagevect = squeeze(HydrophoneVoltage_Corr_Filtered(j,FunctionGenPeakCycle(j,:):end)); % .*1000000 pour obtenir des µV
            [ValPic2, NumCycle2] = findpeaks(HydrophoneVoltagevect,'MINPEAKHEIGHT',Params.Threshold_Hydrophone(DfN));
            HydrophonePeakValue(j,:) = ValPic2(1);
            HydrophonePeakCycle(j,:) = NumCycle2(1)+FunctionGenPeakCycle(j,:)-1;
            %Calculs du delta en nombre de cycles entre l'onde émise et reçue
            DeltaFunctionGenHydrophone(j,:) = HydrophonePeakCycle(j,:) - FunctionGenPeakCycle(j,:);
        end
    else    
        for i=1:size(HydrophoneVoltage,1)
                HydrophoneOffset(i,:) = mean(HydrophoneVoltage(i,2000:end));
                HydrophoneVoltage_Corr(i,:)= HydrophoneVoltage(i,:) - HydrophoneOffset(i,:);
                HydrophoneVoltage_Corr_Filtered(i,:)= filtfilt(B, A,HydrophoneVoltage_Corr(i,:));
    %             HydrophoneVoltagevect = squeeze(HydrophoneVoltage_Corr_Filtered(i,FunctionGenPeakCycle(i,:):end)); % .*1000000 pour obtenir des µV
                [ValPic2, NumCycle2] = findpeaks(squeeze(HydrophoneVoltage_Corr_Filtered(i,:)),'MINPEAKHEIGHT',Params.Threshold_Hydrophone(DfN));
                HydrophonePeakValue(i,:) = ValPic2(1);
    %             HydrophonePeakCycle(i,:) = NumCycle2(1)+FunctionGenPeakCycle(i,:)-1;
                HydrophonePeakCycle(i,:) = NumCycle2(1);
                %Calculs du delta en nombre de cycles entre l'onde émise et reçue
                %DeltaFunctionGenHydrophone(i,:) = HydrophonePeakCycle(i,:) - FunctionGenPeakCycle(i,:);
        end
    end
else
    for x=1:size(v,1)
        for y=1:size(v,2)
            %Calcul de l'offset pour les deux séries de valeurs
            FunctionGenOffset(x,y,:) = mean(FunctionGenVoltage(x,y,1:5000));
            HydrophoneOffset(x,y,:) = mean(HydrophoneVoltage(x,y,1:5000));
            %Correction de l'offset
            FunctionGenVoltage_Corr(x,y,:)= FunctionGenVoltage(x,y,:) - FunctionGenOffset(x,y,:);
            HydrophoneVoltage_Corr(x,y,:)= HydrophoneVoltage(x,y,:) - HydrophoneOffset(x,y,:);
            %Calculs pour le Generateur de fonctions
            FunctionGenVoltage_Corr_Filtered(x,y,:)= filtfilt(B, A,FunctionGenVoltage_Corr(x,y,:));
            HydrophoneVoltage_Corr_Filtered(x,y,:)= filtfilt(B, A,HydrophoneVoltage_Corr(x,y,:));
            FunctionGenVoltagevect = squeeze(FunctionGenVoltage_Corr_Filtered(x,y,10000:end));
            % Detection method 1
            [ValPic, NumCycle] = findpeaks(FunctionGenVoltagevect,'MINPEAKHEIGHT',Params.Threshold_FuncGen(DfN));
            FunctionGenPeakValue(x,y,:) = ValPic(1);
            FunctionGenPeakCycle(x,y,:) = NumCycle(1)+9999;
            %Calculs pour l'hydrophone
            HydrophoneVoltagevect = squeeze(HydrophoneVoltage_Corr_Filtered(x,y,FunctionGenPeakCycle(x,y,:):end)); % .*1000000 pour obtenir des µV
            [ValPic2, NumCycle2] = findpeaks(HydrophoneVoltagevect,'MINPEAKHEIGHT',Params.Threshold_Hydrophone(DfN));
            HydrophonePeakValue(x,y,:) = ValPic2(1);
            HydrophonePeakCycle(x,y,:) = NumCycle2(1)+FunctionGenPeakCycle(x,y,:)-1;
            %Calculs du delta en nombre de cycles entre l'onde émise et reçue
            DeltaFunctionGenHydrophone(x,y,:) = HydrophonePeakCycle(x,y,:) - FunctionGenPeakCycle(x,y,:);
            
%             %Detection method 2
%             [FunctionGenR,FunctionGenLT,FunctionGenUT,FunctionGenLL,FunctionGenUL] = risetime(squeeze(FunctionGenVoltage_Corr_Filtered(x,y,:)),squeeze(FunctionGenTimeVector(x,y,:)));%Params.SamplingFrequency(DfN)
%             [FunctionGenR2,FunctionGenLT2,FunctionGenUT2,FunctionGenLL2,FunctionGenUL2] = falltime(squeeze(FunctionGenVoltage_Corr_Filtered(x,y,:)),squeeze(FunctionGenTimeVector(x,y,:)));
%
% Second method aimed to detect precisely the onset and offset of the whole
% burst and not to cut the burst according to the stimulation paramters set
% on the function generator. So to be more close to ebaluate exposure indices 
% with the true burst generated and so sent to the targeted brain area. 
%!!! Unnecessary !!! Compuatation performed with all signal are lower than with burst which are lower than with Isppa effective             
        end
    end
figure
imagesc(HydrophonePeakCycle)
end

disp('4 : Data were filtered, offset corrected and peak of burst onset were detected')
%% 5 :FFT analysis
if ~Params.CalibrationPrototype(DfN)
    for x=1:size(v,1)
        for y=1:size(v,2)
            % Emis <=> T
            FunctionGenVoltageBurstCut(x,y,:) =  FunctionGenVoltage(x,y,(size(FunctionGenVoltage,3)-NSamples+1):end);% 3617 car on coupe les 3616 premiers échantillons car ce n'est que du
                % bruit et on s'arrange pour garder une puissance de 2 comme longueur de
                % vecteur!
            FunctionGenVoltageBurstCutvect = squeeze(FunctionGenVoltageBurstCut(x,y,:));
            % +/- Implémentation d'une transformée de Hilbert:
            FunctionGenVoltageBurstVect_FFT(x,y,:) = (fft(FunctionGenVoltageBurstCutvect.*Haar)).*2;
            FunctionGenVoltageBurstVect_FFT(x,y,1:(NSamples/2)+1)= FunctionGenVoltageBurstVect_FFT(x,y,1:(NSamples/2)+1).*0; % Partie freq neg = à 0

            FunctionGenVoltageBurstVect_Complex(x,y,:) = squeeze(ifft(FunctionGenVoltageBurstVect_FFT(x,y,:))).*Haar; % Vecteur imaginaire décalé dans le temps d'un quart de période = ok (cfr
    % sin et cos quadrature) = phaseur de T
            %FFT_Burst_Tension_FunGen_Amp_Freq_Intererst(x,y) = FFT_vecteur_Burst_Tension_FunGen(x,y,IndexFreqInterest);

            %Recu <=> S
            HydrophoneVoltageBurstCut(x,y,:) =  HydrophoneVoltage(x,y,(size(HydrophoneVoltage,3)-NSamples+1):end);% 3617 car on coupe les 3616 premiers échantillons car ce n'est que du
                % bruit et on s'arrange pour garder une puissance de 2 comme longueur de
                % vecteur!
            HydrophoneVoltageBurstCutvect = squeeze(HydrophoneVoltageBurstCut(x,y,:));
            % +/- Implémentation d'une transformée de Hilbert:
            HydrophoneVoltageBurstVect_FFT(x,y,:) = (fft(HydrophoneVoltageBurstCutvect.*Haar)).*2;
            HydrophoneVoltageBurstVect_FFT(x,y,1:(NSamples/2)+1)= HydrophoneVoltageBurstVect_FFT(x,y,1:(NSamples/2)+1).*0; % Partie freq neg = à 0 , permet signal analytique
            HydrophoneVoltageBurstVect_Complex(x,y,:) = squeeze(ifft(HydrophoneVoltageBurstVect_FFT(x,y,:))).*Haar; % Vecteur imaginaire décalé dans le temps d'un quart de période = ok (cfr
    % sin et cos quadrature) = Phaseur de S
            %FFT_Burst_Tension_Hydro_Amp_Freq_Intererst(x,y) = FFT_vecteur_Burst_Tension_Hydro(x,y,IndexFreqInterest);
        end
    end

    %Recherche frequence d'intéret afin de déterminer le déphasage
    Freq_Axis(IndexFreqInterest);
    HydrophoneVoltageBurstVect_FFT(x,y,IndexFreqInterest); % Amplitude et phase du signal à la freq voulue
    % Calculer rapport Recu/émis pour chaque point à sauvegarder
    % FFTPhaseshift = angle(HydrophoneVoltageBurstVect_Complex(:,:,IndexFreqInterest)./FunctionGenVoltageBurstVect_Complex(:,:,IndexFreqInterest)); %= dephasage entre émis et reçu cfr notes
    % FFTAmplitude =  abs(HydrophoneVoltageBurstVect_Complex(:,:,IndexFreqInterest)./FunctionGenVoltageBurstVect_Complex(:,:,IndexFreqInterest));

    % Should compute Received/emitted, A/B * e^j*(phi2-phi1)
    ComplexRatio = HydrophoneVoltageBurstVect_Complex./FunctionGenVoltageBurstVect_Complex;
end
if ~Params.CalibrationPrototype(DfN)
    filename = strcat('DataFFT_',Params.SessionName(DfN),'_',num2str(Params.NumberOfCycles(DfN)),'Cyc','_',num2str(Params.VppFunGen(DfN)*10),'Vpp','_',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz.mat');
    save(filename{1},'FunctionGenVoltageBurstCut','FunctionGenVoltageBurstVect_Complex','HydrophoneVoltageBurstCut','HydrophoneVoltageBurstVect_Complex',...
        'Freq_Axis','NSamples','ComplexRatio','FunctionGenVoltageBurstVect_FFT','HydrophoneVoltageBurstVect_FFT');
    clear FunctionGenVoltageBurstCut FunctionGenVoltageBurstVect_Complex HydrophoneVoltageBurstCut HydrophoneVoltageBurstVect_Complex Freq_Axis NSamples ComplexRatio FunctionGenVoltageBurstVect_FFT HydrophoneVoltageBurstVect_FFT
end
disp('5 : FFT analysis done, data saved')
%% 6 : Calcul des différents paramètres nécessaires pour la caractérisation d'un champs d'ultrasons
if Params.CalibrationPrototype(DfN)
    for j=1:size(HydrophoneVoltage,1)
        % Découpage du signal afin de ne garder que le Burst
        InitBurst = HydrophonePeakCycle(j,1);
        if InitBurst==0
            InitBurst=1;
        end
        EndBurst = HydrophonePeakCycle(j,1)+ceil((Params.NumberOfCycles(DfN)*UltrasoundBurstPeriod*Params.SamplingFrequency(DfN)));
        BurstHydrophone(j,:) = ((HydrophoneVoltage_Corr(j,InitBurst:EndBurst)).*1000000)./Params.HydrophoneSensitivity(DfN); %% Attention facteur d'échelle % * 1000000 pour passer en µV /0.99 pour avoir des Pa
        TimeVector_BurstHydrophone(j,:) = FunctionGenTimeVector(j,InitBurst:EndBurst);
        PeakPressure(j,:) = max(BurstHydrophone(j,end-200:end));
        PtPPressure(j,:) = max(BurstHydrophone(j,end-200:end))-min(BurstHydrophone(j,end-200:end));
        IpaEffective(j,:) = (PeakPressure(j,:)^2)/(2*Params.Density(DfN)*Params.SoundVelocity(DfN));
        MI1(j,1) = (PeakPressure(j,:).*1e-6)./sqrt(Params.UltrasoundBurstFrequency(DfN)*1e-6);
        %[Pi_Complet(x,y,:),Isppa_Complet(x,y,:),Ispta_Complet(x,y,:),mechanicalIndex_Complet(x,y,:)] = ultrasoundParameters((Tension_Hydrophone_Corr_Filtre_Rot15(x,y,:).*1000000)./0.99,VecteurTemps_FunctionGen_5Cycles_Rot15(x,y,:),Density,SoundVelocity,UltrasoundBurstFrequency,DutyCycle);  
        [PII(j,:),Ipa(j,:),Ita(j,:),MI(j,:), TI(j,:)] = ultrasoundParameters(BurstHydrophone(j,:),TimeVector_BurstHydrophone(j,:),Params.Density(DfN),Params.SoundVelocity(DfN),Params.UltrasoundBurstFrequency(DfN),DutyCycle,Params.SamplingFrequency(DfN),Params.SonicationDuration(DfN));
    end    
    IpaEffective = IpaEffective./10000;
    Ipa = Ipa./10000;
    Ita = Ita./10000;
    PeakPressureXcoord=0;
    PeakPressureYcoord=0;
    IsppaEffXcoord=0;
    IsppaEffYcoord=0;
    IsppaXcoord=0;
    IsppaYcoord=0;
    IsptaXcoord=0;
    IsptaYcoord=0;
    MIXcoord=0;
    MIYcoord=0;
    FocalPointX=0;
    FocalPointY=Params.DistanceHydroTr(DfN);
    FWHMWidth = 0;
    FWHMLength = 0;

else
    for x=1:size(v,1)
        for y=1:size(v,2)
            % Découpage du signal afin de ne garder que le Burst
            InitBurst = HydrophonePeakCycle(x,y,:)-ceil((0.5*UltrasoundBurstPeriod*Params.SamplingFrequency(DfN)));
            EndBurst = HydrophonePeakCycle(x,y,:)+ceil((Params.NumberOfCycles(DfN)*UltrasoundBurstPeriod*Params.SamplingFrequency(DfN)));
            A(x,y,:) = size([InitBurst:EndBurst],2);
            BurstHydrophone(x,y,:) = ((HydrophoneVoltage_Corr(x,y,InitBurst:EndBurst)).*1000000)./Params.HydrophoneSensitivity(DfN); %% Attention facteur d'échelle % * 1000000 pour passer en µV /0.99 pour avoir des Pa
            TimeVector_BurstHydrophone(x,y,:) = FunctionGenTimeVector(x,y,InitBurst:EndBurst);
            PeakPressure(x,y) = max(BurstHydrophone(x,y,round(length(BurstHydrophone(x,y,:))/2):end));
%             PtPPressure(x,y) = max(BurstHydrophone(x,y,round(length(BurstHydrophone(x,y,:))/2):end))-min(BurstHydrophone(x,y,round(length(BurstHydrophone(x,y,:))/2)));
            PtPPressure(x,y) = max(BurstHydrophone(x,y,round(length(BurstHydrophone(x,y,:))/2):end))-min(BurstHydrophone(x,y,round(length(BurstHydrophone(x,y,:))/2):end));
            IpaEffective(x,y) = (PeakPressure(x,y)^2)/(2*Params.Density(DfN)*Params.SoundVelocity(DfN));    
       %[Pi_Complet(x,y,:),Isppa_Complet(x,y,:),Ispta_Complet(x,y,:),mechanicalIndex_Complet(x,y,:)] = ultrasoundParameters((Tension_Hydrophone_Corr_Filtre_Rot15(x,y,:).*1000000)./0.99,VecteurTemps_FunctionGen_5Cycles_Rot15(x,y,:),Density,SoundVelocity,UltrasoundBurstFrequency,DutyCycle);  
            [PII(x,y,:),Ipa(x,y,:),Ita(x,y,:),MI(x,y,:), TI(x,y,:)] = ultrasoundParameters(BurstHydrophone(x,y,:),TimeVector_BurstHydrophone(x,y,:),Params.Density(DfN),Params.SoundVelocity(DfN),Params.UltrasoundBurstFrequency(DfN),DutyCycle,Params.SamplingFrequency(DfN),Params.SonicationDuration(DfN));
        end
    end
    if Params.SkullBone(DfN)
        IsppaEffective = max(max(IpaEffective(:,1:size(IpaEffective,2)-5)));
        IpaEffectiveNormalized = IpaEffective./IsppaEffective;
        PeakPressureNormalized = PeakPressure./max(max(PeakPressure(:,1:size(PeakPressure,2)-5)));
        [PeakPressureXcoord, PeakPressureYcoord] = find(PeakPressure==max(max(PeakPressure(:,1:end-5))));
        disp(['La valeur max du PeakPressure est de : ' num2str(max(max(PeakPressure(:,1:end-5)))) ' et est postionné au point : ' num2str(PeakPressureXcoord) ' ' num2str(PeakPressureYcoord)])
        [IsppaEffXcoord, IsppaEffYcoord] = find(IpaEffective==max(max(IpaEffective(:,1:end-5))));
        disp(['La valeur max de l Isppa effective est de : ' num2str(max(max(IpaEffective(:,1:end-5)))) ' et est postionné au point : ' num2str(IsppaEffXcoord) ' ' num2str(IsppaEffYcoord)])
        [IsppaXcoord, IsppaYcoord] = find(Ipa==max(max(Ipa(:,1:end-5))));
        disp(['La valeur max de l Isppa est de : ' num2str(max(max(Ipa(:,1:end-5)))) ' et est postionné au point : ' num2str(IsppaXcoord) ' ' num2str(IsppaYcoord)])
        [IsptaXcoord, IsptaYcoord] = find(Ita==max(max(Ita(:,1:end-5))));
        disp(['La valeur max de l Ispta est de : ' num2str(max(max(Ita(:,1:end-5)))) ' et est postionné au point : ' num2str(IsptaXcoord) ' ' num2str(IsptaYcoord)])
        [MIXcoord, MIYcoord] = find(MI==max(max(MI(:,1:end-5))));
        disp(['La valeur max du MI est de : ' num2str(max(max(MI(:,1:end-5)))) ' et est postionné au point : ' num2str(MIXcoord) ' ' num2str(MIYcoord)])
        [PIIXcoord, PIIYcoord] = find(PII==max(max(PII(:,1:end-5))));
        disp(['La valeur max du PII est de : ' num2str(max(max(PII(:,1:end-5)))) ' et est postionné au point : ' num2str(PIIXcoord) ' ' num2str(PIIYcoord)])
    else
        IsppaEffective = max(max(IpaEffective(:,1:size(IpaEffective,2)-10)));
        IpaEffectiveNormalized = IpaEffective./IsppaEffective;
        PeakPressureNormalized = PeakPressure./max(max(PeakPressure(:,1:size(PeakPressure,2)-10)));
        [PeakPressureXcoord, PeakPressureYcoord] = find(PeakPressure==max(max(PeakPressure(:,1:end-10))));
        disp(['La valeur max du PeakPressure est de : ' num2str(max(max(PeakPressure(:,1:end-10)))) ' et est postionné au point : ' num2str(PeakPressureXcoord) ' ' num2str(PeakPressureYcoord)])
        [IsppaEffXcoord, IsppaEffYcoord] = find(IpaEffective==max(max(IpaEffective(:,1:end-10))));
        disp(['La valeur max de l Isppa effective est de : ' num2str(max(max(IpaEffective(:,1:end-10)))) ' et est postionné au point : ' num2str(IsppaEffXcoord) ' ' num2str(IsppaEffYcoord)])
        [IsppaXcoord, IsppaYcoord] = find(Ipa==max(max(Ipa(:,1:end-10))));
        disp(['La valeur max de l Isppa est de : ' num2str(max(max(Ipa(:,1:end-10)))) ' et est postionné au point : ' num2str(IsppaXcoord) ' ' num2str(IsppaYcoord)])
        [IsptaXcoord, IsptaYcoord] = find(Ita==max(max(Ita(:,1:end-10))));
        disp(['La valeur max de l Ispta est de : ' num2str(max(max(Ita(:,1:end-10)))) ' et est postionné au point : ' num2str(IsptaXcoord) ' ' num2str(IsptaYcoord)])
        [MIXcoord, MIYcoord] = find(MI==max(max(MI(:,1:end-10))));
        disp(['La valeur max du MI est de : ' num2str(max(max(MI(:,1:end-10)))) ' et est postionné au point : ' num2str(MIXcoord) ' ' num2str(MIYcoord)])
        [PIIXcoord, PIIYcoord] = find(PII==max(max(PII(:,1:end-10))));
        disp(['La valeur max du PII est de : ' num2str(max(max(PII(:,1:end-10)))) ' et est postionné au point : ' num2str(PIIXcoord) ' ' num2str(PIIYcoord)])
    end
    [IpaEffectiveNormalizedXcoord, IpaEffectiveNormalizedYcoord] = find(IpaEffectiveNormalized==1);
    % Calcul de la position max pour chacun des paramètres afin de définir la
    % distance focale
    for x=1:size(v,1)
        for y=1:size(v,2)
           if PeakPressureNormalized(x,y) >= 0.5
               FWHM(x,y) = 1;
           else
               FWHM(x,y) = 0;
           end
        end
    end
%     for x= 1:size(v,1)
%         if cumsum(FWHM(x,:))==0
%             FWHMRow(x) = 0;
%         else
%             FWHMRow(x) = find(FWHM(x,:),1);
%         end
%     end
%     for y= 1:size(v,2)
%         if cumsum(FWHM(:,y))==0
%             FWHMCol(y) = 0;
%         else
%             FWHMCol(y) = find(FWHM(:,y),1);
%         end
%     end
%     FWHMWidth = find(FWHMRow>0,1,'last') - find(FWHMRow>0,1,'first') + 1;
%     FWHMLength = find(FWHMCol>0,1,'last') - find(FWHMCol>0,1,'first') + 1;
    FWHMWidth = sum(FWHM(:,PeakPressureYcoord));
    FWHMLength = sum(FWHM(PeakPressureXcoord,:));
 
    figure
    imagesc(FWHM)
    title(strcat('FWHM ',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz _',num2str(Params.VppFunGen(DfN)),'Vpp' ))
    fignameFWHM = strcat('FWHM_',Params.SessionName(DfN),'_',num2str(Params.NumberOfCycles(DfN)),'Cycles',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz');
    savefig(fignameFWHM{1})
    figure;
    imagesc(PII)
    title(strcat('PII ',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz _',num2str(Params.VppFunGen(DfN)),'Vpp' ))
    fignamePI = strcat('PII_',Params.SessionName(DfN),'_',num2str(Params.NumberOfCycles(DfN)),'Cycles',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz');
    savefig(fignamePI{1})
    figure;
    imagesc(IpaEffective)
    title(strcat('IpaEffective ',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz _',num2str(Params.VppFunGen(DfN)),'Vpp'))
    fignameIpaEff = strcat('IpaEffective_',Params.SessionName(DfN),'_',num2str(Params.NumberOfCycles(DfN)),'Cycles',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz');
    savefig(fignameIpaEff{1})
    figure;
    imagesc(Ipa)
    title(strcat('Ipa ',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz _',num2str(Params.VppFunGen(DfN)),'Vpp'))
    fignameIpa = strcat('Ipa_',Params.SessionName(DfN),'_',num2str(Params.NumberOfCycles(DfN)),'Cycles',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz');
    savefig(fignameIpa{1})
    figure;
    imagesc(Ita)
    title(strcat('Ita ',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz _',num2str(Params.VppFunGen(DfN)),'Vpp'))
    fignameIta = strcat('Ita_',Params.SessionName(DfN),'_',num2str(Params.NumberOfCycles(DfN)),'Cycles',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz');
    savefig(fignameIta{1})
    figure;
    imagesc(MI)
    title(strcat('MI ',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz _',num2str(Params.VppFunGen(DfN)),'Vpp'))
    fignameMI = strcat('MI_',Params.SessionName(DfN),'_',num2str(Params.NumberOfCycles(DfN)),'Cycles',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz');
    savefig(fignameMI{1})



    FocalPointX=Xvector(PeakPressureXcoord);
    FocalPointY=Params.Yend(DfN)-Yvector(PeakPressureYcoord)+Params.DistanceHydroTr(DfN);
    IpaEffective = IpaEffective/10000;
    Ipa = Ipa/10000; %Divided by 10000 to convert data from W/m² to W/cm²
    Ita = Ita/10000;
end
disp('6 : Computation of the exposure indices done')
%% 7 : Saving the data relative to the characterisation of the beam profile
[a,b,c]=xlsread('D:\data\jlambert\TFUS_Mesures_Welcome\AnalysisParameters.xlsx','Output');
if Params.CalibrationPrototype(DfN)
    for w=1:size(HydrophoneVoltage,1)
    Results={Params.DataFilename{DfN},PeakPressure(w),PeakPressureXcoord, PeakPressureYcoord,IpaEffective(w),...
        IsppaEffXcoord, IsppaEffYcoord,Ipa(w),IsppaXcoord, IsppaYcoord,Ita(w),IsptaXcoord, ...
        IsptaYcoord,MI((w)),MIXcoord, MIYcoord,FocalPointX,FocalPointY,FWHMWidth,FWHMLength};
    Range = ['A' num2str(size(c,1)+1+w-1)];
    xlswrite('D:\data\jlambert\TFUS_Mesures_Welcome\AnalysisParameters.xlsx',Results,'Output',Range)
    end
else
    if Params.SkullBone(DfN)
        Results={Params.DataFilename{DfN},max(max(PeakPressure(:,1:end-5))),PeakPressureXcoord, PeakPressureYcoord,max(max(IpaEffective(:,1:end-5))),...
            IsppaEffXcoord, IsppaEffYcoord,max(max(Ipa(:,1:end-5))),IsppaXcoord, IsppaYcoord,max(max(Ita(:,1:end-5))),IsptaXcoord, ...
            IsptaYcoord,max(max(MI(:,1:end-5))),MIXcoord, MIYcoord,FocalPointX,FocalPointY,FWHMWidth,FWHMLength};
        Range = ['A' num2str(size(c,1)+1)];
        xlswrite('D:\data\jlambert\TFUS_Mesures_Welcome\AnalysisParameters.xlsx',Results,'Output',Range)
    else
        Results={Params.DataFilename{DfN},max(max(PeakPressure(:,1:end-10))),PeakPressureXcoord, PeakPressureYcoord,max(max(IpaEffective(:,1:end-10))),...
            IsppaEffXcoord, IsppaEffYcoord,max(max(Ipa(:,1:end-10))),IsppaXcoord, IsppaYcoord,max(max(Ita(:,1:end-10))),IsptaXcoord, ...
            IsptaYcoord,max(max(MI(:,1:end-10))),MIXcoord, MIYcoord,FocalPointX,FocalPointY,FWHMWidth,FWHMLength};
        Range = ['A' num2str(size(c,1)+1)];
        xlswrite('D:\data\jlambert\TFUS_Mesures_Welcome\AnalysisParameters.xlsx',Results,'Output',Range)
    end
end
disp('7: Data saved in Excel file')

if Params.CalibrationPrototype(DfN)
       filename = strcat('DataCharacterisation_',Params.SessionName(DfN),'_',num2str(Params.NumberOfCycles(DfN)),'Cyc','_',num2str(Params.VppFunGen(DfN)),'Vpp','_',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz');
         save(filename{1},'FunctionGenVoltage','HydrophoneVoltage','FunctionGenTimeVector',...
        'BurstHydrophone','HydrophonePeakValue','HydrophonePeakCycle',...
        'PeakPressure','IpaEffective','Ipa','Ita','MI','TI','PII','Params',...
        'FocalPointX','FocalPointY','FWHMWidth','FWHMLength'); 
else
    filename = strcat('DataCharacterisation_',Params.SessionName(DfN),'_',num2str(Params.NumberOfCycles(DfN)),'Cyc','_',num2str(Params.VppFunGen(DfN)*10),'Vpp','_',num2str(Params.UltrasoundBurstFrequency(DfN)/1000),'kHz.mat');
    save(filename{1},'FunctionGenVoltage','HydrophoneVoltage','FunctionGenTimeVector',...
        'FilenameMatrix','BurstHydrophone','FunctionGenPeakValue',...
        'FunctionGenPeakCycle','HydrophonePeakValue','HydrophonePeakCycle',...
        'PeakPressure','IpaEffective','Ipa','Ita','MI','TI','PII','FWHM',...
        'Params','FocalPointX','FocalPointY','PeakPressureNormalized','FWHMWidth','FWHMLength');
end

disp('Data saved in mat file')

%%


%%


%%

%%
% figure
% subplot(2,1,1)
% plot(Freq_Axis,squeeze(abs(FunctionGenVoltageBurstVect_FFT(x,y,:))))
% 
% subplot(2,1,2)
% plot(T,squeeze(FunctionGenVoltageBurstCutvect))
% hold on
% plot(T,squeeze(real(FunctionGenVoltageBurstVect_Complex(x,y,:))),'r')
% plot(T,squeeze(imag(FunctionGenVoltageBurstVect_Complex(x,y,:))),'k')

figure
subplot(2,1,1)
plot(Freq_Axis,squeeze(abs(HydrophoneVoltageBurstVect_FFT(x,y,:))))

subplot(2,1,2)
plot(T,squeeze(FunctionGenVoltageBurstCutvect))
hold on
plot(T,squeeze(real(HydrophoneVoltageBurstVect_Complex(x,y,:))),'r')
plot(T,squeeze(imag(HydrophoneVoltageBurstVect_Complex(x,y,:))),'k')

%%
% tr_radius = 16;
% sound_velocity = 1500;
% fundamental_frequency=250000;
% lambda = (sound_velocity/fundamental_frequency)*1000;%to get mm
% last_maxima = (4*(tr_radius^2)-lambda^2)/(4*lambda)
