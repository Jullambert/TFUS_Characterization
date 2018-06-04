%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyse des données des acquises lors des mesures réalisées en WELCOME
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ! Tous les fichiers à analyser doivent se trouver dans un dossier qui lui même se trouve dans le dossier Tests_Setup_Welcome à l'emplacement E: 
% Ce script réalise les opérations uivantes :
%           1. Création de constantes et préallocations mémoire de
%           variables
%           2. Import et remise dans l'ordre de la liste des fichiers existant dans le dossier
%           pointer lors de l'apparition de la fenêtre prévue à cet effet.
% 
% 
% 19/10/2016 - JL --> Version with computation of the dimensions of the FWHM
% 15/03/17 --> adding folder 300,400,450 kHz + switches related to those
%possibilities for case 1Vpp
% 7/04/2017 --> sort files according to frequency and number of cycles
% 16/01/2018 - JL --> Adding the new sensitivity coefficient ( one variable
% for switching between previous and new coefficient according to the date
% of calibration
% 26/3/2018 --> Changes in the computation of the DutyCycle
% 61/4/2018 --> adding case switch for new calibration file (calibration
% for hydrophone 2)
clc
clear all
%% 1: Initialisation de constantes et paramètres
%Parametres liés au fichier "table" utilisé lors des mesures
XTableInit = -17;
XTableEnd = 17;
XStep = 1;

YTableInit = 0;
YTableEnd = 60;
YStep = 1;
YTableLentgth = YTableEnd-YTableInit;

Yvector = YTableInit:YStep:YTableEnd ; %linspace(YTableInit,YTableEnd,YTableEnd+1); % table mesure de 0 à 100 compris
Xvector = XTableInit:XStep:XTableEnd ;   %linspace(XTableEnd,XTableInit,(2*XTableEnd)+1);
%Parametres liés à 1) l'enregistrement des données et 2) aux stimulations apr US réalisées 
SamplingFrequency = 10000000;%pour 200 cycles %60000000; %pour 5 cycles
CutoffFrequency = 1000000;
NumberOfCycles = 200; % 5
SonicationDuration = 0.3 ;% time in second
NumberSamplesRecorded =  30000;%20000; %pour 5 cycles

%Vpp 
% VoltagePP =  2.6;%[Vpp]
%  VoltagePP =  2;%[Vpp]
%  VoltagePP = 1.8 ;%[Vpp]
%  VoltagePP = 1.6 ;%[Vpp]
%  VoltagePP = 1.4 ;%[Vpp]
%  VoltagePP = 1.3 ;%[Vpp]
%  VoltagePP = 1.2 ;%[Vpp]
  VoltagePP = 1 ;%[Vpp]
%    VoltagePP = 0.8 ;%[Vpp]
%   VoltagePP = 0.6 ;%[Vpp]

Density = 1028;
SoundVelocity = 1515;
UltrasoundBurstFrequency = 300000;
UltrasoundBurstPeriod = 1/UltrasoundBurstFrequency;
PulseRepetitonFrequency = 1000; %[Hz]
ToneBurstDuration = NumberOfCycles * UltrasoundBurstPeriod ;% [s]
DutyCycle = ToneBurstDuration * PulseRepetitonFrequency;
AttenuationCoefficient = 0.3 ; % [dB/(cm*MHz)]

CalibrationVersion = 3; % 1 for the original calibration performed when 
% the hydrophone was bought , 2 for the second calibration performed in October/November 2017
%3 for the second hydrophone
DataRecordedBtwJulyNov2017 = 0; % CFR email David from Precision Acoustic.

switch VoltagePP
    case 2.6
        DistanceTransducteurHydrophone = 5.7; %[mm]
        switch UltrasoundBurstFrequency 
            case 250000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.84;
                        PeakThreshold_Hydrophone = 4000/1000000; %3700 ;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7863; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.754;
                        PeakThreshold_Hydrophone = 4000/1000000; 
                        FactorOfCorrection = 0.8;
                end
            case 350000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.99;
                        PeakThreshold_Hydrophone = 4500/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7865; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.847;
                        PeakThreshold_Hydrophone = 4500/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 500000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.22;
                        PeakThreshold_Hydrophone = 4100/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7863; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 1.017;
                        PeakThreshold_Hydrophone = 4100/1000000;
                        FactorOfCorrection = 0.8;
                end %
        end
    case 2
        DistanceTransducteurHydrophone = 5.4;%5.7; %[mm]
        switch UltrasoundBurstFrequency 
            case 250000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.84;
                        PeakThreshold_Hydrophone = 4000/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7767; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.754;
                        PeakThreshold_Hydrophone = 4000/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 350000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.99;
                        PeakThreshold_Hydrophone = 4000/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7865; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.847;
                        PeakThreshold_Hydrophone = 4000/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 500000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.22;
                        PeakThreshold_Hydrophone = 4400/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8018; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 1.017;
                        PeakThreshold_Hydrophone = 4100/1000000;
                        FactorOfCorrection = 0.8;
                end
        end
        case 1.8
        DistanceTransducteurHydrophone = 5.4;%5.24; %5.92; %[mm]
        switch UltrasoundBurstFrequency 
            case 250000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.84;
                        PeakThreshold_Hydrophone = 3900/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7767; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.754;
                        PeakThreshold_Hydrophone = 2500/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 350000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.99;
                        PeakThreshold_Hydrophone = 4000/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7865; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.847;
                        PeakThreshold_Hydrophone = 4000/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 500000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.22;
                        PeakThreshold_Hydrophone = 4200/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8018; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 1.017;
                        PeakThreshold_Hydrophone = 2300/1000000;
                        FactorOfCorrection = 0.8;
                end
        end
        case 1.6
        DistanceTransducteurHydrophone = 5.4;%5.24; %5.92; %[mm]
        switch UltrasoundBurstFrequency 
            case 250000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.84;
                        PeakThreshold_Hydrophone = 3900/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7767; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.754;
                        PeakThreshold_Hydrophone = 2500/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 350000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.99;
                        PeakThreshold_Hydrophone = 4000/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7865; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.847;
                        PeakThreshold_Hydrophone = 4000/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 500000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.22;
                        PeakThreshold_Hydrophone = 4000/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8018; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 1.017;
                        PeakThreshold_Hydrophone = 2300/1000000;
                        FactorOfCorrection = 0.8;
                end
        end
    case 1.4
        DistanceTransducteurHydrophone = 5.4; %5.92; %[mm]
        switch UltrasoundBurstFrequency 
            case 250000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.84;
                        PeakThreshold_Hydrophone = 3900/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7767; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.754;
                        PeakThreshold_Hydrophone = 4000/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 350000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.99;
                        PeakThreshold_Hydrophone = 4000/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7865; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.847;
                        PeakThreshold_Hydrophone = 4000/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 500000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.22;
                        PeakThreshold_Hydrophone = 3900/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8018; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 1.017;
                        PeakThreshold_Hydrophone = 2300/1000000;
                        FactorOfCorrection = 0.8;
                end
        end
    case 1.3
        DistanceTransducteurHydrophone = 5.24; %6; %[mm]close all
        switch UltrasoundBurstFrequency 
            case 250000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.84;
                        PeakThreshold_Hydrophone = 2400/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7767; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.754;
                        PeakThreshold_Hydrophone = 2400/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 350000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.99;
                        PeakThreshold_Hydrophone = 2350/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7865; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.847;
                        PeakThreshold_Hydrophone = 2350/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 500000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.22;
                        PeakThreshold_Hydrophone = 2250/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8018; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 1.017;
                        PeakThreshold_Hydrophone = 2250/1000000;
                        FactorOfCorrection = 0.8;
                end
        end
        
    case 1.2
        DistanceTransducteurHydrophone = 5.4;%5.24; %5.92; %[mm]
        switch UltrasoundBurstFrequency 
            case 250000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.84;
                        PeakThreshold_Hydrophone = 3900/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7767; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.754;
                        PeakThreshold_Hydrophone = 2500/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 350000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.99;
                        PeakThreshold_Hydrophone = 4000/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7865; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.847;
                        PeakThreshold_Hydrophone = 4000/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 500000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.22;
                        PeakThreshold_Hydrophone = 4200/1000000; %
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8018; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 1.017;
                        PeakThreshold_Hydrophone = 2300/1000000;
                        FactorOfCorrection = 0.8;
                end
        end 
    
    case 1
        DistanceTransducteurHydrophone = 5.4;%5.6;%5.7;%(juillet roations moins 30)%5.6;%(juillet rotation +15 bis)%5.5;%(juillet rotations +15)%5.6; % (juillet Zero_Ref) %5.4 ; %(session juillet multiple voltage) %6.34;%(SessionAttenuation 20 cycles_1)%5.3; % ( SessionAttenuation 5)% 5.2;%(SessionAttenuation4 SansCrane)%5.74; %(SessionAttenuation3 SansCrane) 5.1; %(SessionAttenuation2 SansCrane)%5.6; %(SessionAttenuation1 SansCrane) %5.7; %(proto_Zero_Protection %10.6; %(protoMoinsDix)%5.4;%(pour proto Zero)%5.5 ;%(pour proto hors)%5.6;%(pour 20 Deg)%5.54; %%(pour10Deg)%5.6; %(pour5Deg);%5.3; %(pour-10)%5.24;%(pour0Deg) ;%5.28;%(pour -5deg)%5.54; %%(pour10Deg) %4.64; %5.4; %[mm] 5.6 pour nouvelle pièce d'alignement
        switch UltrasoundBurstFrequency 
            case 250000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.84;
                        PeakThreshold_Hydrophone = 3800/1000000; %2700/1000000; %50/1000000;3300/1000000;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8; % sqrt(mean([4.36 4.29 3.96 3.68 3.52 3.29])/mean([5.58 6.26 6.37 6.43 6.5])) cfr JMP
                        end
                    case 2
                        HydrophoneSensitivity = 0.754;
                        PeakThreshold_Hydrophone = 4000/1000000;
                        FactorOfCorrection = 0.8;
                    case 3
                        HydrophoneSensitivity = 0.695;
                        PeakThreshold_Hydrophone = 4200/1000000;
                        
                end
            case 300000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.91;
                        PeakThreshold_Hydrophone = 3500/1000000;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8;
                        end
                    case 2
                        HydrophoneSensitivity = 0.799;
                        PeakThreshold_Hydrophone = 3100/1000000;
                        FactorOfCorrection = 0.8;
                    case 3
                        HydrophoneSensitivity = 0.750;
                        PeakThreshold_Hydrophone = 3200/1000000;%3200/1000000;
                        
                end
            case 350000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.99;
                        PeakThreshold_Hydrophone = 4100/1000000;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.;
                        end
                    case 2
                        HydrophoneSensitivity = 0.847;
                        PeakThreshold_Hydrophone = 4000/1000000;
                        FactorOfCorrection = 0.8;
                    case 3
                        HydrophoneSensitivity = 0.811;
                        PeakThreshold_Hydrophone = 4000/1000000;
                end
            case 400000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.07;
                        PeakThreshold_Hydrophone = 4200/1000000;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8;
                        end
                    case 2
                        HydrophoneSensitivity = 0.897;
                        PeakThreshold_Hydrophone = 4200/1000000;
                        FactorOfCorrection = 0.8;
                    case 3
                        HydrophoneSensitivity = 0.872695;
                        PeakThreshold_Hydrophone = 4200/1000000;
                end
            case 450000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.14;
                        PeakThreshold_Hydrophone = 3750/1000000;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8;
                        end
                    case 2
                        HydrophoneSensitivity = 0.947;
                        PeakThreshold_Hydrophone = 3750/1000000;
                        FactorOfCorrection = 0.8;
                    case 3
                        HydrophoneSensitivity = 0.935;
                        PeakThreshold_Hydrophone = 4000/1000000;
                end
            case 500000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.22;
                        PeakThreshold_Hydrophone = 3100/1000000; % 3500/1000000;2300 pour 5 cycles
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8;
                        end
                    case 2
                        HydrophoneSensitivity = 1.017;
                        PeakThreshold_Hydrophone = 3050/1000000;
                        FactorOfCorrection = 0.8;
                    case 3
                        HydrophoneSensitivity = 1.008;
                        PeakThreshold_Hydrophone = 4000/1000000;
                end
        end
    case 0.8
        DistanceTransducteurHydrophone = 5.24; %5.2; %[mm]
        switch UltrasoundBurstFrequency 
            case 250000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.84;
                        PeakThreshold_Hydrophone = 2300/1000000;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7767;
                        end
                    case 2
                        HydrophoneSensitivity = 0.754;
                        PeakThreshold_Hydrophone = 2300/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 350000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.99;
                        PeakThreshold_Hydrophone = 2400/1000000;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7865;
                        end
                    case 2
                        HydrophoneSensitivity = 0.847;
                        PeakThreshold_Hydrophone = 2400/1000000;
                        FactorOfCorrection = 0.8;
                end
            case 500000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.12;
                        PeakThreshold_Hydrophone = 2300/1000000;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8018;
                        end
                    case 2
                        HydrophoneSensitivity = 1.017;
                        PeakThreshold_Hydrophone = 2300/1000000;
                        FactorOfCorrection = 0.8;
                end
        end
        
    case 0.6
        DistanceTransducteurHydrophone = 5.24; %5; %[mm]
        switch UltrasoundBurstFrequency 
            case 250000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.84;
                        PeakThreshold_Hydrophone = 2100/1000000; %2200 ou 2300
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7767;
                        end
                    case 2
                        HydrophoneSensitivity = 0.754;
                        PeakThreshold_Hydrophone = 2100/1000000;
                        FactorOfCorrection = 0.8;
                    case 3
                        HydrophoneSensitivity = 0.695;
                        PeakThreshold_Hydrophone = 2100/1000000;
                end
            case 300000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.91;
                        PeakThreshold_Hydrophone = 2200/1000000;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8;
                        end
                    case 2
                        HydrophoneSensitivity = 0.799;
                        PeakThreshold_Hydrophone = 2200/1000000;
                        FactorOfCorrection = 0.8;
                    case 3
                        HydrophoneSensitivity = 0.750;
                        PeakThreshold_Hydrophone = 2200/1000000;
                        
                end
            case 350000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 0.99;
                        PeakThreshold_Hydrophone = 2200/1000000; %2200 ou 2300
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.7865;
                        end
                    case 2
                        HydrophoneSensitivity = 0.847;
                        PeakThreshold_Hydrophone = 2200/1000000;
                        FactorOfCorrection = 0.8;
                    case 3
                        HydrophoneSensitivity = 0.695;
                        PeakThreshold_Hydrophone = 2200/1000000;
                end
            case 400000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.07;
                        PeakThreshold_Hydrophone = 2200/1000000;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8;
                        end
                    case 2
                        HydrophoneSensitivity = 0.897;
                        PeakThreshold_Hydrophone = 2200/1000000;
                        FactorOfCorrection = 0.8;
                    case 3
                        HydrophoneSensitivity = 0.872695;
                        PeakThreshold_Hydrophone = 2200/1000000;
                end
            case 450000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.14;
                        PeakThreshold_Hydrophone = 2200/1000000;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8;
                        end
                    case 2
                        HydrophoneSensitivity = 0.947;
                        PeakThreshold_Hydrophone = 2200/1000000;
                        FactorOfCorrection = 0.8;
                    case 3
                        HydrophoneSensitivity = 0.935;
                        PeakThreshold_Hydrophone = 2200/1000000;
                end
            case 500000
                switch CalibrationVersion
                    case 1
                        HydrophoneSensitivity = 1.22;
                        PeakThreshold_Hydrophone = 2200/1000000;
                        if DataRecordedBtwJulyNov2017
                            FactorOfCorrection = 0.8018;
                        end
                    case 2
                        HydrophoneSensitivity = 1.017;
                        PeakThreshold_Hydrophone = 2200/1000000;
                        FactorOfCorrection = 0.8;
                    case 3
                        HydrophoneSensitivity = 1.008;
                        PeakThreshold_Hydrophone = 2200/1000000;
                end
        end
end

%Params pour détection de pics
PeakThreshold_FunctionGen = 0.1;
% PeakThreshold_Hydrophone = 0.0025; % 0.006 pour 1Vpp 0.003 pour 0.6Vpp

% Params FFT
NSamples = 2^14;
T= [0:(NSamples-1)]/SamplingFrequency;
Freq_Axis = (-SamplingFrequency/2)+[0:NSamples-1]/NSamples*SamplingFrequency; % Permet de créer un vecteur qui va de -fs/2 à 1 echnatillon avant Fs/2
Haar = (-1).^([0:NSamples-1]); % permet de recentrer les données en 0
Haar = Haar';
Index_Freq_Interest = round(UltrasoundBurstFrequency/SamplingFrequency*NSamples+NSamples/2+1);


% Params liés au type de fichier à traiter
TDMS = 1;
LV2015 = 0; % Param necessaire car suite au changement de fonctions forcé pour LabView 2015, la structure des fichiers est modifiée...
PlotData = 0;

% Création d'une matrice contenant les index liés aux steps réalisés lors des mesures via la table X-Y. Pour rappel, elle se déplace "en snake". 
s=1;
v=zeros(length(Xvector),length(Yvector));
for y=1:length(Yvector)
    for x=1:length(Xvector)
        v(x,y)=s;
        s=s+1;
    end;
end;
% Initialisation des matrices de données
Tension_FunctionGen = zeros(length(Xvector),length(Yvector),NumberSamplesRecorded);
Tension_Hydrophone = zeros(length(Xvector),length(Yvector),NumberSamplesRecorded);
VecteurTemps_FunctionGen = zeros(length(Xvector),length(Yvector),NumberSamplesRecorded);

Offset_FunctionGen(x,y,:) = mean(Tension_FunctionGen(x,y,1:5000));
Offset_Hydrophone(x,y,:) = mean(Tension_Hydrophone(x,y,1:5000));
Tension_FunctionGen_Corr = zeros(length(Xvector),length(Yvector),NumberSamplesRecorded);
Tension_Hydrophone_Corr = zeros(length(Xvector),length(Yvector),NumberSamplesRecorded);

Tension_FunctionGen_Corr_Filtre = zeros(length(Xvector),length(Yvector),NumberSamplesRecorded);
Tension_Hydrophone_Corr_Filtre = zeros(length(Xvector),length(Yvector),NumberSamplesRecorded);

PeakValue_FunctionGen = zeros(length(Xvector),length(Yvector));
NumCycle_FunctionGen = zeros(length(Xvector),length(Yvector));
PeakValue_Hydrophone = zeros(length(Xvector),length(Yvector));
NumCycle_Hydrophone = zeros(length(Xvector),length(Yvector));
Delta_Hydrophone_FunctionGen = zeros(length(Xvector),length(Yvector));

Pi = zeros(length(Xvector),length(Yvector));
Isppa = zeros(length(Xvector),length(Yvector));
Ispta = zeros(length(Xvector),length(Yvector));
MI = zeros(length(Xvector),length(Yvector));
TI = zeros(length(Xvector),length(Yvector));

DistanceX_Isppa = zeros(length(Xvector),length(Yvector));% Distance en [mm]
DistanceY_Isppa = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
DistanceDerating_Isppa = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
IsppaDerated = zeros(length(Xvector),length(Yvector));
LinearAttenuationCoeff = zeros(length(Xvector),length(Yvector));

% Calcul Ispta derated
DistanceX_Ispta = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
DistanceY_Ispta = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
DistanceDerating_Ispta = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
IsptaDerated = zeros(length(Xvector),length(Yvector));

% Calcul Ispta derated
DistanceX_MI = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
DistanceY_MI = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
DistanceDerating_MI = zeros(length(Xvector),length(Yvector)); % Distance en [mm]
MIDerated = zeros(length(Xvector),length(Yvector));

FWHM_Matrix = zeros(length(Xvector),length(Yvector)); 
Row_FWHM = zeros(length(Xvector));
Col_FWHM = zeros(length(Yvector));

Burst_Tension_FunGen_Resampled = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
Burst_Tension_Hydro_Resampled = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
FFT_vecteur_Burst_Tension_FunGen = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
FFT_Burst_Tension_FunGen_Amp_Freq_Intererst = zeros(length(Xvector),length(Yvector));
FFT_Burst_Tension_Hydro_Amp_Freq_Intererst = zeros(length(Xvector),length(Yvector));
FFT_Dephasage = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
FFT_Amplitude = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
FFT_vecteur_Burst_Tension_Hydro = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
vecteur_Burst_Tension_FunGen_Complex = zeros(length(Xvector),length(Yvector),length(Freq_Axis));
vecteur_Burst_Tension_Hydro_Complex = zeros(length(Xvector),length(Yvector),length(Freq_Axis));

disp('1 : Initialisation finie')
%% 2:  Import du nom de l'ensemble des fichiers contenu dans le dossier sélectionné
RootDir = uigetdir;
DataFilesName = dir(RootDir);
DataFilesName(1:2) = []; % delete . and .
cd(RootDir)
NameFile = {};

% Boucle utilisée afin de respecter le schema de déplacement "en snake" de la table
% x-y
for y=2:2:length(Yvector)%YTableEnd;
    v(:,y)=flip(v(:,y));
end;
% imagesc(v)

% Boucle pour trier par ordre numérique des différents "Steps" de mesure les fichiers contenus dans le dossier pointer par RootDir
for i=1:length(DataFilesName)
    filename = fullfile(RootDir,DataFilesName(i).name);
    NameFile{i,1} = filename;
end;

for ii=1:length(DataFilesName)
    st=NameFile{ii};
    idx=strfind(st,'Num_Step_')+9;
    idx2=strfind(st,'X_Coordinate')-1;
    stval(ii)=str2num(st(idx:idx2));
    [a,b]=sort(stval);
end;
NameFile2=NameFile(b);
disp('2 : Reorganisation des noms de fichiers finie')
%% Classement en  dossier
for iii=1:length(NameFile2)
    st=NameFile2{iii};
    idx_2=strfind(st,'Freq_')+5;
    idx2_2=strfind(st,'.tdms')-1;
    stval_2(iii)=str2num(st(idx_2(2):idx2_2));
    [a_2,b_2]=sort(stval_2);

        if stval_2(iii) == 250000
            if mod(iii,2)
                movefile(NameFile2{iii},'D:\data\jlambert\TFUS_Mesures_Welcome\SessionHauteur\SansCrane\250kHz')                
            else
                movefile(NameFile2{iii},'D:\data\jlambert\TFUS_Mesures_Welcome\SessionHauteur\SansCrane\250kHz_index')
            end
        elseif stval_2(iii) == 300000            
            if mod(iii,2)
                movefile(NameFile2{iii},'D:\data\jlambert\TFUS_Mesures_Welcome\SessionHauteur\SansCrane\300kHz')                
            else
                movefile(NameFile2{iii},'D:\data\jlambert\TFUS_Mesures_Welcome\SessionHauteur\SansCrane\300kHz_index')
            end
        elseif stval_2(iii) == 350000            
            if mod(iii,2)
                movefile(NameFile2{iii},'D:\data\jlambert\TFUS_Mesures_Welcome\SessionHauteur\SansCrane\350kHz')                
            else
                movefile(NameFile2{iii},'D:\data\jlambert\TFUS_Mesures_Welcome\SessionHauteur\SansCrane\350kHz_index')
            end
        elseif stval_2(iii) == 400000            
            if mod(iii,2)
                movefile(NameFile2{iii},'D:\data\jlambert\TFUS_Mesures_Welcome\SessionHauteur\SansCrane\400kHz')                
            else
                movefile(NameFile2{iii},'D:\data\jlambert\TFUS_Mesures_Welcome\SessionHauteur\SansCrane\400kHz_index')
            end
        elseif stval_2(iii) == 450000            
            if mod(iii,2)
                movefile(NameFile2{iii},'D:\data\jlambert\TFUS_Mesures_Welcome\SessionHauteur\SansCrane\450kHz')                
            else
                movefile(NameFile2{iii},'D:\data\jlambert\TFUS_Mesures_Welcome\SessionHauteur\SansCrane\450kHz_index')
            end
        else        
            if mod(iii,2)
                movefile(NameFile2{iii},'D:\data\jlambert\TFUS_Mesures_Welcome\SessionHauteur\SansCrane\500kHz')                
            else
                movefile(NameFile2{iii},'D:\data\jlambert\TFUS_Mesures_Welcome\SessionHauteur\SansCrane\500kHz_index')
            end
        end
end

disp('Classement fait!!!!!!')
%% 3 : Preparing the name in order to save variables in different .mat files
NameData= NameFile2{1};%DataFilesName(1).folder;
idx_session=strfind(st,'_Welcome\')+9;
idx2_session=strfind(st,'_1Vpp200')-1;
% idx2_session=strfind(st,'Ancienne')-2;
session = NameData(idx_session:idx2_session);

idx_type=strfind(st,'_300kHz_')+8;
idx2_type=strfind(st,'_Num_')-3;
type = NameData(idx_type:idx2_type);

idx_fichier=strfind(st,'e\Hydro1_1')+9;
idx2_fichier=strfind(st,'Data')-2;
fichier = NameData(idx_fichier:idx2_fichier);

idx_freq=strfind(st,'200C')+4;
idx2_freq=strfind(st,'kHz')+2;
freq = NameData(idx_freq:idx2_freq);

disp('3 : Preparation des variables pour les différents noms de fichier à sauvegarder finie ')
%% 4 : Boucle permettant l'import des données dans une matrice
figure
hold on
for x=1:size(v,1)
    for y=1:size(v,2)
        x;
        y;
        if TDMS
            [finalOutput,metaStruct] = TDMS_readTDMSFile(NameFile2{v(x,y)});
%             plot(finalOutput.data{:,3}) % genfunction
            Tension_FunctionGen(x,y,1:length(finalOutput.data{:,3})) = finalOutput.data{:,3};
            Tension_Hydrophone(x,y,1:length(finalOutput.data{:,4})) = finalOutput.data{:,4};
            DeltaT = finalOutput.propValues{1,3}{1,3};
            VecteurTemps_FunctionGen(x,y,1:length(finalOutput.data{:,3})) = (0:DeltaT(1):(length(Tension_FunctionGen(x,y,:))-1)*DeltaT(1));
            MatrixNameFile_5Cycles{x,y,:}=NameFile2{v(x,y)};  
        
        clear finalOutput
        clear metaStruct
        else
            fid = fopen(NameFile2{v(x,y)});
            content = fscanf(fid,'%c');
                if LV2015
                    A = importfile_2columns_LV2015(NameFile2{v(x,y)});
                    DeltaT = str2num(content(strfind(content,'delta t')+7:strfind(content,'time')-1)) ;%% Recherche du delta T défini lors de l'acquisition de données 
                     DeltaT=1/SamplingFrequency;
                else
                    A = importfile_2columns(NameFile2{v(x,y)});
                    DeltaT = str2num(content(strfind(content,'delta t')+7:strfind(content,'time')-1)) ;%% Recherche du delta T défini lors de l'acquisition de données 
                    
                end     
            Tension_FunctionGen(x,y,1:length(A.Volt0)) = A.Volt0;
            Tension_Hydrophone(x,y,1:length(A.Volt1)) = A.Volt1;
            VecteurTemps_FunctionGen(x,y,1:length(A.Volt0)) = (0:DeltaT(1):(length(Tension_FunctionGen(x,y,:))-1)*DeltaT(1));
            MatrixNameFile_5Cycles{x,y,:}=NameFile2{v(x,y)};     
            clear A
            fclose(fid);
        end
%     MatrixNameFile_5Cycles{x,y,:}=NameFile2{v(x,y)};
    end;
end;
plot(squeeze(Tension_Hydrophone(1,1,:)),'r')
plot(squeeze(Tension_FunctionGen(1,1,:)))

disp('4 : Import des données fini')
%% 5 : Calcul afin de 1. Réajuster par rapport à l'offset, 2. déterminer le temps et la valeur des premiers pics émis par le générateur de fonctions et 3.déterminer le temps et la valeur des premiers picsreçus par l'hydrophone
% Calcul de l'offset existant pour chaque burst enregistré
for x=1:size(v,1)
    for y=1:size(v,2)
        %Calcul de l'offset pour les deux séries de valeurs
        Offset_FunctionGen(x,y,:) = mean(Tension_FunctionGen(x,y,1:5000));
        Offset_Hydrophone(x,y,:) = mean(Tension_Hydrophone(x,y,1:5000));

        %Correction de l'offset
        Tension_FunctionGen_Corr(x,y,:)= Tension_FunctionGen(x,y,:) - Offset_FunctionGen(x,y,:);
        Tension_Hydrophone_Corr(x,y,:)= Tension_Hydrophone(x,y,:) - Offset_Hydrophone(x,y,:);
    end;
end;

% Filtrage des données
[B A] = butter(2,CutoffFrequency/(SamplingFrequency/2),'low');

for x=1:size(v,1)
    for y=1:size(v,2)
        Tension_FunctionGen_Corr_Filtre(x,y,:)= filtfilt(B, A,Tension_FunctionGen_Corr(x,y,:));
        Tension_Hydrophone_Corr_Filtre(x,y,:)= filtfilt(B, A,Tension_Hydrophone_Corr(x,y,:));
    end;
end;

% figure;
% plot(squeeze(VecteurTemps_FunctionGen(12,43,:)),squeeze(Tension_Hydrophone_Corr(12,43,:)))
% hold on
% plot(squeeze(VecteurTemps_FunctionGen(12,43,:)),squeeze(Tension_Hydrophone_Corr_Filtre(12,43,:)),'r')
% 
% figure;
% plot(squeeze(VecteurTemps_FunctionGen(12,43,:)),squeeze(Tension_FunctionGen_Corr(12,43,:)))
% hold on
% plot(squeeze(VecteurTemps_FunctionGen(12,43,:)),squeeze(Tension_FunctionGen_Corr_Filtre(12,43,:)),'r')

% Détection des premiers pics sur base des valeurs filtrées
for x=1:size(v,1);
    for y=1:size(v,2);
        %Calculs pour le Generateur de fonctions
        Vecteur_Tension_FunctionGen = squeeze(Tension_FunctionGen_Corr_Filtre(x,y,10000:end));
        [ValPic, NumCycle] = findpeaks(Vecteur_Tension_FunctionGen,'MINPEAKHEIGHT',PeakThreshold_FunctionGen);
        PeakValue_FunctionGen(x,y,:) = ValPic(1);
        NumCycle_FunctionGen(x,y,:) = NumCycle(1)+9999;

        %Calculs pour l'hydrophone
        Vecteur_Tension_Hydrophone = squeeze(Tension_Hydrophone_Corr_Filtre(x,y,NumCycle_FunctionGen(x,y,:):end)); % .*1000000 pour obtenir des µV
        [ValPic2, NumCycle2] = findpeaks(Vecteur_Tension_Hydrophone,'MINPEAKHEIGHT',PeakThreshold_Hydrophone);
        PeakValue_Hydrophone(x,y,:) = ValPic2(1);
        NumCycle_Hydrophone(x,y,:) = NumCycle2(1)+NumCycle_FunctionGen(x,y,:)-1;
%         Vecteur_Tension_Hydrophone = squeeze(Tension_Hydrophone(x,y,NumCycle_FunctionGen(x,y,:):end)); % .*1000000 pour obtenir des µV
%         [ValPic2, NumCycle2] = findpeaks(Vecteur_Tension_Hydrophone,'MINPEAKHEIGHT',PeakThreshold_Hydrophone+Offset_Hydrophone(x,y,:));
%         PeakValue_Hydrophone(x,y,:) = ValPic2(1);
%         NumCycle_Hydrophone(x,y,:) = NumCycle2(1)+NumCycle_FunctionGen(x,y,:)-1;

        %Calculs du delta en nombre de cycles entre l'onde émise et reçue
        Delta_Hydrophone_FunctionGen(x,y,:) = NumCycle_Hydrophone(x,y,:) - NumCycle_FunctionGen(x,y,:);
    end;
end;

figure
imagesc(NumCycle_Hydrophone)
disp('5 : Correction des valeurs en fonction de leur offset, filtrage des données et détection des premiers pics finis')

%% 6 : Calcul des différents paramètres nécessaires pour la caractérisation d'un champs d'ultrasons

for x=1:size(v,1)
    for y=1:size(v,2)
        % Découpage du signal afin de ne garder que le Burst
        InitBurst = NumCycle_Hydrophone(x,y,:)-ceil((0.5*UltrasoundBurstPeriod*SamplingFrequency));
        EndBurst = NumCycle_Hydrophone(x,y,:)+ceil((NumberOfCycles*UltrasoundBurstPeriod*SamplingFrequency));
        A(x,y,:) = size([InitBurst:EndBurst],2);
        BurstHydrophone(x,y,:) = ((Tension_Hydrophone_Corr(x,y,InitBurst:EndBurst)).*1000000)./HydrophoneSensitivity; %% Attention facteur d'échelle % * 1000000 pour passer en µV /0.99 pour avoir des Pa
        switch CalibrationVersion
            case 1
                if DataRecordedBtwJulyNov2017
                    BurstHydrophone(x,y,:) = BurstHydrophone(x,y,:)./FactorOfCorrection;
                end
            case 2
                BurstHydrophone(x,y,:) = BurstHydrophone(x,y,:)./FactorOfCorrection;
            case 3
                BurstHydrophone(x,y,:) = BurstHydrophone(x,y,:);
        end
        TimeVector_BurstHydrophone(x,y,:) = VecteurTemps_FunctionGen(x,y,InitBurst:EndBurst);
        PeakPressure(x,y,:) = max(BurstHydrophone(x,y,2500:end));
        PtPPressure(x,y,:) = max(BurstHydrophone(x,y,2500:end))-min(BurstHydrophone(x,y,2500:end));
        Isppa1(x,y,:) = (PeakPressure(x,y,:)^2)/(2*Density*SoundVelocity);    
   
        %[Pi_Complet(x,y,:),Isppa_Complet(x,y,:),Ispta_Complet(x,y,:),mechanicalIndex_Complet(x,y,:)] = ultrasoundParameters((Tension_Hydrophone_Corr_Filtre_Rot15(x,y,:).*1000000)./0.99,VecteurTemps_FunctionGen_5Cycles_Rot15(x,y,:),Density,SoundVelocity,UltrasoundBurstFrequency,DutyCycle);  
        [Pi(x,y,:),Isppa(x,y,:),Ispta(x,y,:),MI(x,y,:), TI(x,y,:)] = ultrasoundParameters(BurstHydrophone(x,y,:),TimeVector_BurstHydrophone(x,y,:),Density,SoundVelocity,UltrasoundBurstFrequency,DutyCycle,SamplingFrequency,SonicationDuration);
    end
end

figure;
imagesc(Pi)
title(strcat('Pi AF',num2str(UltrasoundBurstFrequency/1000),'_kHz'))
fignamePI = ['PI_' session '_' fichier '_' freq];
savefig(fignamePI)

figure;
imagesc(Isppa)
title(strcat('Isppa AF',num2str(UltrasoundBurstFrequency/1000),'_kHz'))
fignameIsppa = ['Isppa_' session '_' fichier '_' freq];
savefig(fignameIsppa)

figure;
imagesc(Ispta)
title(strcat('Ispta AF',num2str(UltrasoundBurstFrequency/1000),'_kHz'))
fignameIspta = ['Ispta_' session '_' fichier '_' freq];
savefig(fignameIspta)

figure;
imagesc(MI)
title(strcat('MI AF',num2str(UltrasoundBurstFrequency/1000),'_kHz'))
fignameMI = ['MI_' session '_' fichier '_' freq];
savefig(fignameMI)


% Calcul de la position max pour chacun des paramètres afin de définir la
% distance focale
if UltrasoundBurstFrequency == 250000
    [PositionX_maxIsppa, PositionY_maxIsppa] = find(Isppa==max(max(Isppa(:,1:end-10))));
    disp(['La valeur max de l Isppa est de : ' num2str(max(max(Isppa(:,1:end-10)))) ' et est postionné au point : ' num2str(PositionX_maxIsppa) ' ' num2str(PositionY_maxIsppa)])
    [PositionX_maxIspta, PositionY_maxIspta] = find(Ispta==max(max(Ispta(:,1:end-10))));
    disp(['La valeur max de l Ispta est de : ' num2str(max(max(Ispta(:,1:end-10)))) ' et est postionné au point : ' num2str(PositionX_maxIspta) ' ' num2str(PositionY_maxIspta)])
    [PositionX_maxMI, PositionY_maxMI] = find(MI==max(max(MI(:,1:end-10))));
    disp(['La valeur max du MI est de : ' num2str(max(max(MI(:,1:end-10)))) ' et est postionné au point : ' num2str(PositionX_maxMI) ' ' num2str(PositionY_maxMI)])
    [PositionX_maxPi, PositionY_maxPi] = find(Pi==max(max(Pi(:,1:end-10))));
    disp(['La valeur max du Pi est de : ' num2str(max(max(Pi(:,1:end-10)))) ' et est postionné au point : ' num2str(PositionX_maxPi) ' ' num2str(PositionY_maxPi)])
    
else
    [PositionX_maxIsppa, PositionY_maxIsppa] = find(Isppa==max(max(Isppa(:,1:end-10))));
    disp(['La valeur max de l Isppa est de : ' num2str(max(max(Isppa(:,1:end-10)))) ' et est postionné au point : ' num2str(PositionX_maxIsppa) ' ' num2str(PositionY_maxIsppa)])
    [PositionX_maxIspta, PositionY_maxIspta] = find(Ispta==max(max(Ispta(:,1:end-10))));
    disp(['La valeur max de l Ispta est de : ' num2str(max(max(Ispta(:,1:end-10)))) ' et est postionné au point : ' num2str(PositionX_maxIspta) ' ' num2str(PositionY_maxIspta)])
    [PositionX_maxPi, PositionY_maxPi] = find(Pi==max(max(Pi(:,1:end-10))));
    disp(['La valeur max du Pi est de : ' num2str(max(max(Pi(:,1:end-10)))) ' et est postionné au point : ' num2str(PositionX_maxPi) ' ' num2str(PositionY_maxPi)])
    [PositionX_maxMI, PositionY_maxMI] = find(MI==max(max(MI(:,1:end-10))));
    disp(['La valeur max du MI est de : ' num2str(max(max(MI(:,1:end-10)))) ' et est postionné au point : ' num2str(PositionX_maxMI) ' ' num2str(PositionY_maxMI)])
end
[PositionX_maxIsppa, PositionY_maxIsppa] = find(Isppa==max(max(Isppa(:,1:end))));
    disp(['La valeur max de l Isppa est de : ' num2str(max(max(Isppa(:,1:end)))) ' et est postionné au point : ' num2str(PositionX_maxIsppa) ' ' num2str(PositionY_maxIsppa)])
   

disp('6 : Calcul des parametres du champs d ultrasons fini')

%     [PositionX_maxIsppa1, PositionY_maxIsppa1] = find(Isppa1==max(max(Isppa1(:,1:end-10))));
%     disp(['La valeur max de l Isppa1 est de : ' num2str(max(max(Isppa1(:,1:end-10)))) ' et est postionné au point : ' num2str(PositionX_maxIsppa) ' ' num2str(PositionY_maxIsppa)])
    
% for x=1:size(v,1)
%     for y=1:size(v,2)
% 
%         MaxBurst(x,y) = max(BurstHydrophone(x,y,:));
% end
% end
figure
for w=1:10
    hold on
    plot(Tension_Hydrophone(w,:))
end

%% 7 : Calcul des différents paramètres "derated" nécessaires pour la caractérisation d'un champs d'ultrasons
% Calcul de la distance entre transducteur et hydrophone en fonction du
% déplacement dans l'eau
for x=1:size(v,1)
    for y=1:size(v,2)
        % Calcul Isppa Derated
        DistanceX_Isppa(x,y) = XStep*abs(PositionX_maxIsppa-x); % Distance en [mm]
        DistanceY_Isppa(x,y) = YStep*(max(size(v,2))-y) + DistanceTransducteurHydrophone; % Distance en [mm]
        DistanceDerating_Isppa(x,y) = sqrt((DistanceX_Isppa(x,y))^2 + (DistanceY_Isppa(x,y))^2); % Distance en [mm]
        [IsppaDerated(x,y), LinearAttenuationCoeff(x,y)] = deratedValue(Isppa(x,y),AttenuationCoefficient,DistanceDerating_Isppa(x,y)/10,UltrasoundBurstFrequency/1000000);
    
        % Calcul Ispta derated
        DistanceX_Ispta(x,y) = XStep*abs(PositionX_maxIspta-x); % Distance en [mm]
        DistanceY_Ispta(x,y) = YStep*(max(size(v,2))-y) + DistanceTransducteurHydrophone; % Distance en [mm]
        DistanceDerating_Ispta(x,y) = sqrt((DistanceX_Ispta(x,y))^2 + (DistanceY_Ispta(x,y))^2); % Distance en [mm]
        [IsptaDerated(x,y), LinearAttenuationCoeff(x,y)] = deratedValue(Ispta(x,y),AttenuationCoefficient,DistanceDerating_Ispta(x,y)/10,UltrasoundBurstFrequency/1000000);
        
        % Calcul Ispta derated
        DistanceX_MI(x,y) = XStep*abs(PositionX_maxMI-x); % Distance en [mm]
        DistanceY_MI(x,y) = YStep*(max(size(v,2))-y) + DistanceTransducteurHydrophone; % Distance en [mm]
        DistanceDerating_MI(x,y) = sqrt((DistanceX_MI(x,y))^2 + (DistanceY_MI(x,y))^2); % Distance en [mm]
        [MIDerated(x,y), LinearAttenuationCoeff(x,y)] = deratedValue(MI(x,y),AttenuationCoefficient,DistanceDerating_MI(x,y)/10,UltrasoundBurstFrequency/1000000);
        
    end
end

disp('7 : Calcul des parametres "derated" du champs d ultrasons fini')

%% 8 : Calcul de la Full width half maximum area

% if UltrasoundBurstFrequency == 250000
    Max_Isppa = max(max(Isppa(:,1:size(Isppa,2)-10)));
    Isppa_Normalisee = Isppa./Max_Isppa;
% else
%     Max_Isppa = max(max(Isppa));
%     Isppa_Normalisee = Isppa./Max_Isppa;
% end
[PositionX_maxIsppa_Normalisee, PositionY_maxIsppa_Normalisee] = find(Isppa_Normalisee==1);
 
for x=1:size(v,1)
    for y=1:size(v,2)
       if Isppa_Normalisee(x,y) >= 0.5
            FWHM_Matrix(x,y) = 1;
       end
    end
end

for x=1:size(Isppa_Attenuation_1Vpp_300kHz_Normalisee,1)
    for y=1:size(Isppa_Attenuation_1Vpp_300kHz_Normalisee,2)
       if Isppa_Attenuation_1Vpp_300kHz_Normalisee(x,y) >= 0.5
            FWHM_Matrix2(x,y) = 1;
       else
           FWHM_Matrix2(x,y) = 0;
       end
    end
end

for x= 1:size(v,1)
    if cumsum(FWHM_Matrix(x,:))==0
        Row_FWHM(x) = 0;
    else
        Row_FWHM(x) = find(FWHM_Matrix(x,:),1);
    end
end

for y= 1:size(v,2)
    if cumsum(FWHM_Matrix(:,y))==0
        Col_FWHM(y) = 0;
    else
        Col_FWHM(y) = find(FWHM_Matrix(:,y),1);
    end
end

Width_FWHM = find(Row_FWHM>0,1,'last') - find(Row_FWHM>0,1,'first') + 1;
Length_FWHM = find(Col_FWHM>0,1,'last') - find(Col_FWHM>0,1,'first') + 1;


figure
imagesc(FWHM_Matrix)
fignameFWHM = ['FWHM_' session '_' fichier '_' freq];
savefig(fignameFWHM)
% 
% figure
% imagesc(FWHM_Matrix_2)
disp('8 : Calcul FWHM fini')
% 
% FWHM_Matrix_All = FWHM_Matrix;
% 
% for x=1:size(v,1)
%     for y=1:size(v,2)
%        if FWHM_Matrix_2(x,y)~=0
%             FWHM_Matrix_All(x,y) = FWHM_Matrix(x,y) + FWHM_Matrix_2(x,y);
%        end
%     end
% end
% figure
% imagesc(FWHM_Matrix_All)
% 
% FWHM_1 = bwlabel(FWHM_Matrix,4);
% FWHM_2 = bwlabel(FWHM_Matrix_2,8); 
% FWHM_3 = bwlabel(FWHM_Matrix_All,4);
% 
% figure
% imagesc(FWHM_1)



%% 9 : Storing some variables into .mat files in order to free some RAM memory before the FFT analysis
filename1=['ParamAnalysis_' session '_' type '_' fichier '_' freq '.mat'];
save(filename1,'XTableInit','XTableEnd','XStep','YTableInit','YTableEnd',... 
'YStep','NumberOfCycles','SonicationDuration','VoltagePP',...
'UltrasoundBurstFrequency','PulseRepetitonFrequency','DistanceTransducteurHydrophone',...
'PeakThreshold_FunctionGen','PeakThreshold_Hydrophone','SamplingFrequency', 'HydrophoneSensitivity',...
'session','type','fichier','freq','CalibrationVersion','DataRecordedBtwJulyNov2017')
clear XTableInit XTableEnd XStep YTableInit YTableEnd YStep NumberOfCycles SonicationDuration VoltagePP UltrasoundBurstFrequency PulseRepetitonFrequency DistanceTransducteurHydrophone PeakThreshold_FunctionGen PeakThreshold_Hydrophone SamplingFrequency HydrophoneSensitivity

filename3=['UltrasoundParameters_' session '_' type '_' fichier '_' freq '.mat'];
save(filename3,'InitBurst','EndBurst','BurstHydrophone',...
    'TimeVector_BurstHydrophone','Pi','MI','TI','Isppa','Isppa1','Ispta','FWHM_Matrix')
clear InitBurst EndBurst BurstHydrophone TimeVector_BurstHydrophone Pi MI TI Isppa Ispta FWHM_Matrix

filename4 =['DeratedUltrasoundParameters_' session '_' type '_' fichier '_' freq '.mat']; 
save(filename4, 'DistanceDerating_Isppa','IsppaDerated', 'LinearAttenuationCoeff',...
    'DistanceDerating_Ispta','IsptaDerated', 'LinearAttenuationCoeff',...
    'DistanceDerating_MI','MIDerated', 'LinearAttenuationCoeff');
clear DistanceDerating_Isppa DistanceDerating_Ispta DistanceDerating_MI IsppaDerated LinearAttenuationCoeff DistanceDerating_Ispta IsptaDerated LinearAttenuationCoeff DistanceDerating_MI MIDerated LinearAttenuationCoeff


clear Tension_FunctionGen_Corr Tension_FunctionGen_Corr_Filtre Tension_Hydrophone_Corr Tension_Hydrophone_Corr_Filtre



disp('9 : Sauvegarde partielle finie')


%% 10 Analyse fréquentielle des données. 
% Modif le 30/5/2016 --> Mise au propre de l'analyse frequentielle 
% Params FFT

%nextpow2

for x=1:size(v,1)
    for y=1:size(v,2)
        % Emis <=> T
        Burst_Tension_FunGen_Resampled(x,y,:) =  Tension_FunctionGen(x,y,(size(Tension_FunctionGen,3)-NSamples+1):end);% 3617 car on coupe les 3616 premiers échantillons car ce n'est que du
            % bruit et on s'arrange pour garder une puissance de 2 comme longueur de
            % vecteur!
        vecteur_Burst_Tension_FunGen_Resampled = squeeze(Burst_Tension_FunGen_Resampled(x,y,:));
        
        % +/- Implémentation d'une transformée de Hilbert:
        FFT_vecteur_Burst_Tension_FunGen(x,y,:) = (fft(vecteur_Burst_Tension_FunGen_Resampled.*Haar)).*2;
        FFT_vecteur_Burst_Tension_FunGen(x,y,1:(NSamples/2)+1)= FFT_vecteur_Burst_Tension_FunGen(x,y,1:(NSamples/2)+1).*0; % Partie freq neg = à 0
        
        vecteur_Burst_Tension_FunGen_Complex(x,y,:) = squeeze(ifft(FFT_vecteur_Burst_Tension_FunGen(x,y,:))).*Haar; % Vecteur imaginaire décalé dans le temps d'un quart de période = ok (cfr
% sin et cos quadrature) = phaseur de T
        %FFT_Burst_Tension_FunGen_Amp_Freq_Intererst(x,y) = FFT_vecteur_Burst_Tension_FunGen(x,y,Index_Freq_Interest);
    
        %Recu <=> S
        Burst_Tension_Hydro_Resampled(x,y,:) =  Tension_Hydrophone(x,y,(size(Tension_Hydrophone,3)-NSamples+1):end);% 3617 car on coupe les 3616 premiers échantillons car ce n'est que du
            % bruit et on s'arrange pour garder une puissance de 2 comme longueur de
            % vecteur!
        vecteur_Burst_Tension_Hydro_Resampled = squeeze(Burst_Tension_Hydro_Resampled(x,y,:));

        % +/- Implémentation d'une transformée de Hilbert:
        FFT_vecteur_Burst_Tension_Hydro(x,y,:) = (fft(vecteur_Burst_Tension_Hydro_Resampled.*Haar)).*2;
        FFT_vecteur_Burst_Tension_Hydro(x,y,1:(NSamples/2)+1)= FFT_vecteur_Burst_Tension_Hydro(x,y,1:(NSamples/2)+1).*0; % Partie freq neg = à 0 , permet signal analytique

        vecteur_Burst_Tension_Hydro_Complex(x,y,:) = squeeze(ifft(FFT_vecteur_Burst_Tension_Hydro(x,y,:))).*Haar; % Vecteur imaginaire décalé dans le temps d'un quart de période = ok (cfr
% sin et cos quadrature) = Phaseur de S
        %FFT_Burst_Tension_Hydro_Amp_Freq_Intererst(x,y) = FFT_vecteur_Burst_Tension_Hydro(x,y,Index_Freq_Interest);
    end
end

%Recherche frequence d'intéret afin de déterminer le déphasage
Freq_Axis(Index_Freq_Interest);
FFT_vecteur_Burst_Tension_Hydro(x,y,Index_Freq_Interest); % Amplitude et phase du signal à la freq voulue

% Calculer rapport Recu/émis pour chaque point à sauvegarder
FFT_Dephasage = angle(vecteur_Burst_Tension_Hydro_Complex(:,:,Index_Freq_Interest)./vecteur_Burst_Tension_FunGen_Complex(:,:,Index_Freq_Interest)); %= dephasage entre émis et reçu cfr notes
FFT_Amplitude =  abs(vecteur_Burst_Tension_Hydro_Complex(:,:,Index_Freq_Interest)./vecteur_Burst_Tension_FunGen_Complex(:,:,Index_Freq_Interest));

disp('10 : Analyse FFT finie')

%% 11 : Saving the imported data and the FFT analysis into separate .mat files
filename2=['RawData_' session '_' type '_' fichier '_' freq '.mat'];
save(filename2,'MatrixNameFile_5Cycles','Tension_FunctionGen',...
    'Tension_Hydrophone','DeltaT','VecteurTemps_FunctionGen')
clear MatrixNameFile_5Cycles Tension_FunctionGen Tension_Hydrophone DeltaT VecteurTemps_FunctionGen


filename5=['FFTAnalysis_' session '_' type '_' fichier '_' freq '.mat'];
save(filename5,'NSamples','Freq_Axis','FFT_vecteur_Burst_Tension_FunGen',...
    'vecteur_Burst_Tension_FunGen_Complex','FFT_vecteur_Burst_Tension_Hydro',...
    'vecteur_Burst_Tension_Hydro_Complex','FFT_Dephasage','FFT_Amplitude')
clear NSamples Freq_Axis FFT_vecteur_Burst_Tension_FunGen vecteur_Burst_Tension_FunGen_Complex FFT_vecteur_Burst_Tension_Hydro vecteur_Burst_Tension_Hydro_Complex FFT_Dephasage FFT_Amplitude

disp('11 : Sauvegardes des données brutes et des résultats l analyse FFT finies')

%% Affichage pour check detection pic

figure
x=1
y=49
VecteurTemps_FunctionGen(x,y,NumCycle_Hydrophone(x,y))
plot(squeeze(VecteurTemps_FunctionGen(x,y,:)),squeeze(Tension_Hydrophone_Corr_Filtre(x,y,:)))
hold on
plot(squeeze(VecteurTemps_FunctionGen(x,y,NumCycle_Hydrophone(x,y))),squeeze(Tension_Hydrophone_Corr_Filtre(x,y,NumCycle_Hydrophone(x,y))),'*r')


for x=1:size(v,1)
figure
imagesc(NumCycle_Hydrophone(x,:))
end


for x=1:size(v,1)
    for y = 2:size(v,2)-1
        if NumCycle_Hydrophone(x,y)> (NumCycle_FunctionGen(x,y)+ ((((YTableLentgth/1000)-(y-1)*YStep/1000)+(DistanceTransducteurHydrophone/1000))/SoundVelocity)*SamplingFrequency) + 20
           NumCycle_Hydrophone_corr(x,y) =  mean([NumCycle_Hydrophone(x,y-1) NumCycle_Hydrophone(x,y+1)]);
            
        else
            NumCycle_Hydrophone_corr(x,y) = NumCycle_Hydrophone(x,y);
        end
        Delta_Hydrophone_FunctionGen_corr(x,y) = NumCycle_Hydrophone_corr(x,y,:) - NumCycle_FunctionGen(x,y,:);
    end
end
NumCycle_Hydrophone_corr(:,1)= NumCycle_Hydrophone(:,1);
Delta_Hydrophone_FunctionGen_corr(:,1) = Delta_Hydrophone_FunctionGen(:,1);
NumCycle_Hydrophone_corr(:,end+1)= NumCycle_Hydrophone(:,end);
Delta_Hydrophone_FunctionGen_corr(:,end+1) = Delta_Hydrophone_FunctionGen(:,end);



for x=1:size(v,1)
figure
subplot(2,1,1)
imagesc(NumCycle_Hydrophone(x,:))
subplot(2,1,2)
imagesc(NumCycle_Hydrophone_corr(x,:))
end

figure
imagesc(NumCycle_Hydrophone)

figure
imagesc(NumCycle_Hydrophone_corr)

figure; imagesc(Delta_Hydrophone_FunctionGen)
figure; imagesc(Delta_Hydrophone_FunctionGen_corr)


x=14

for y = 1:size(v,2)
%     VecteurTemps_FunctionGen(x,y,NumCycle_Hydrophone(x,y))
    figure
    plot(squeeze(VecteurTemps_FunctionGen(x,y,:)),squeeze(Tension_Hydrophone_Corr_Filtre(x,y,:)))
    hold on
    plot(squeeze(VecteurTemps_FunctionGen(x,y,:)),squeeze(Tension_FunctionGen_Corr_Filtre(x,y,:)))
 
    plot(squeeze(VecteurTemps_FunctionGen(x,y,NumCycle_Hydrophone(x,y))),squeeze(Tension_Hydrophone_Corr_Filtre(x,y,NumCycle_Hydrophone(x,y))),'*r')
%     plot(squeeze(VecteurTemps_FunctionGen(x,y,latencies(x,y))),squeeze(Tension_Hydrophone_Corr_Filtre(x,y,latencies(x,y))),'*c')
    ylim([-0.6 0.6])
end

x=14
for y = 1:size(v,2)
%     VecteurTemps_FunctionGen(x,y,NumCycle_Hydrophone(x,y))
    figure
    plot(squeeze(TimeVector_BurstHydrophone(x,y,:)),squeeze(BurstHydrophone(x,y,:)))
    hold on
  
%     plot(squeeze(VecteurTemps_FunctionGen(x,y,NumCycle_Hydrophone(x,y))),squeeze(Tension_Hydrophone_Corr_Filtre(x,y,NumCycle_Hydrophone(x,y))),'*r')
%     plot(squeeze(VecteurTemps_FunctionGen(x,y,latencies(x,y))),squeeze(Tension_Hydrophone_Corr_Filtre(x,y,latencies(x,y))),'*c')
%     ylim([-0.6 0.6])
end

y=20
for x = 1:size(v,1)
    figure
    plot(squeeze(VecteurTemps_FunctionGen(x,y,:)),squeeze(Tension_Hydrophone_Corr_Filtre(x,y,:)))
    hold on
    plot(squeeze(VecteurTemps_FunctionGen(x,y,NumCycle_Hydrophone(x,y))),squeeze(Tension_Hydrophone_Corr_Filtre(x,y,NumCycle_Hydrophone(x,y))),'*r')
    ylim([-0.5 0.5]) 
end


% figure;
% plot(reshape(SquaredBurstPressureWaveformCumsum(x,y,:),1,length(SquaredBurstPressureWaveformCumsum(x,y,:))))
% 
% 
% plot(reshape(VecteurTemps_FunctionGen(x,y,:),1,length(VecteurTemps_FunctionGen(x,y,:))),reshape(Tension_Hydrophone_Corr(x,y,:),1,length(Tension_Hydrophone_Corr(x,y,:))))
% hold on
% plot(reshape(VecteurTemps_FunctionGen(x,y,:),1,length(VecteurTemps_FunctionGen(x,y,:))),reshape(Tension_Hydrophone_Corr_Filtre(x,y,:),1,length(Tension_Hydrophone_Corr_Filtre(x,y,:))),'r')
% plot(reshape(TimeVector_BurstHydrophone(x,y,:),1,length(TimeVector_BurstHydrophone(x,y,:))),reshape(BurstHydrophone(x,y,:),1,length(BurstHydrophone(x,y,:))),'c')
% 
% 
% plot(VecteurTemps_FunctionGen(x,y,NumCycle_Hydrophone(x,y,:)),Tension_Hydrophone_Corr(x,y,NumCycle_Hydrophone(x,y,:)),'*k')





%% Affichage des données après analyse

%Modif le 30/5/2016
% Plot des données
% if PlotData
%     for w = 1: length(NameFile2)
%         figure(w)
%         subplot(2,2,1)
%         plot(VecteurTemps_FunctionGen(w,:),Tension_FunctionGen(w,:))
%         title('Recordings from the function generator')
%         xlabel('Time [ms]')
%         ylabel('Tension from the function generator [V]')
% 
%         subplot(2,2,2)
%         plot(FFT_Frequence_FunctionGen(w,:),2*abs(FFT_Amplitude_FunctionGen(w,1:NFFT/2+1)))
%         title('Frequency analysis - FFT')
%         xlabel('Frequency [Hz]')
%         ylabel('Amplitude')    
% 
%         subplot(2,2,3)
%         plot(VecteurTemps_Hydrophone(w,:),Tension_Hydrophone(w,:))
%         title('Recordings from the hydrophone')
%         xlabel('Time [ms]')
%         ylabel('Tension from the hydrophone [V]')
% 
%         subplot(2,2,4)
%         plot(FFT_Frequence_Hydrophone(w,:),2*abs(FFT_Amplitude_Hydrophone(w,1:NFFT2/2+1)))
%         title('Frequency analysis - FFT')
%         xlabel('Frequency [Hz]')
%         ylabel('Amplitude')  
% 
%         pause(1)
%     end 
%     disp('Tracé des données fini')
% end


if PlotData
    for x=1:size(v,1);
        for y=1:size(v,2); 
            figure(v(x,y))
            subplot(2,1,1)
            plot(Freq_Axis,squeeze(abs(FFT_vecteur_Burst_Tension_Hydro(x,y,:))))

            subplot(2,1,2)
            plot(T,squeeze(Burst_Tension_Hydro_Resampled(x,y,:)))
            hold on
            plot(T,squeeze(real(vecteur_Burst_Tension_Hydro_Complex(x,y,:))),'r')
            plot(T,squeeze(imag(vecteur_Burst_Tension_Hydro_Complex(x,y,:))),'k')

        end
    end

figure
imagesc(FFT_Dephasage)

%%
xmin = 0;
xmax = 30000;
ymin = -0.2;
ymax=0.2;    
xindex = 17;
xstep = 1;

figure;
g(1)=subplot(5,1,1);
h(1)=plot(squeeze(Tension_Hydrophone(xindex-(2*xstep),61,:)),'k');
YLabel1 = get(g(1),'YLabel');
xlim([xmin xmax]);
ylim([ymin ymax]);
g(2)=subplot(5,1,2);
h(2)=plot(squeeze(Tension_Hydrophone(xindex-xstep,61,:)),'k');
YLabel2 = get(g(2),'YLabel');
xlim([xmin xmax]);
ylim([ymin ymax]);
g(3)=subplot(5,1,3);
h(3)=plot(squeeze(Tension_Hydrophone(xindex,61,:)),'k');
YLabel3 = get(g(3),'YLabel');
xlim([xmin xmax]);
ylim([ymin ymax]);
g(4)=subplot(5,1,4);
h(4)=plot(squeeze(Tension_Hydrophone(xindex+xstep,61,:)),'k');
YLabel4 = get(g(4),'YLabel');
xlim([xmin xmax]);
ylim([ymin ymax]);
g(5)=subplot(5,1,5);
h(5)=plot(squeeze(Tension_Hydrophone(xindex+2*xstep,61,:)),'k');
YLabel5 = get(g(5),'YLabel');
xlim([xmin xmax]);
ylim([ymin ymax]);
for i=61:-1:1;
    title(g(1),strcat('NumStep :',num2str(i)))
    set(h(1),'YData',squeeze(Tension_Hydrophone(xindex-(2*xstep),i,:)));
    set(YLabel1,'String',strcat('PtP: ',num2str(max(Tension_Hydrophone(xindex-(2*xstep),i,:))-min(Tension_Hydrophone(xindex-(2*xstep),i,:)))));
    
    set(h(2),'YData',squeeze(Tension_Hydrophone(xindex-xstep,i,:)));
    set(YLabel2,'String',strcat('PtP: ',num2str(max(Tension_Hydrophone(xindex-xstep,i,:))-min(Tension_Hydrophone(xindex-xstep,i,:)))));
    
    set(h(3),'YData',squeeze(Tension_Hydrophone(xindex,i,:)));
    set(YLabel3,'String',strcat('PtP: ',num2str(max(Tension_Hydrophone(xindex,i,:))-min(Tension_Hydrophone(xindex,i,:)))));
    
    set(h(4),'YData',squeeze(Tension_Hydrophone(xindex+xstep,i,:)));
    set(YLabel4,'String',strcat('PtP: ',num2str(max(Tension_Hydrophone(xindex+xstep,i,:))-min(Tension_Hydrophone(xindex+xstep,i,:)))));
    
    set(h(5),'YData',squeeze(Tension_Hydrophone(xindex+2*xstep,i,:)));
    set(YLabel5,'String',strcat('PtP: ',num2str(max(Tension_Hydrophone(xindex+(2*xstep),i,:))-min(Tension_Hydrophone(xindex-(2*xstep),i,:)))));
    pause(4);
end;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmin = 14000;
xmax = 24000;
ymin = -0.6;
ymax=0.6;    
xindex = 26;
xstep = 1;
yindex = 99;
ystep = 1;
figure
subplot(5,1,1);
h1=plot(squeeze(Tension_Hydrophone(xindex,yindex+2*ystep,:)),'k');
xlim([xmin xmax]);
ylim([ymin ymax]);
title (['Evolution Hydrophone measures 200 cycles from ' num2str(yindex+2*ystep) ' to ' num2str(yindex-2*ystep) ' 500kHz'])
subplot(5,1,2);
h2=plot(squeeze(Tension_Hydrophone(xindex,yindex+ystep,:)),'k');
xlim([xmin xmax]);
ylim([ymin ymax]);
subplot(5,1,3);
h3=plot(squeeze(Tension_Hydrophone(xindex,yindex,:)),'k');
xlim([xmin xmax]);
ylim([ymin ymax]);
subplot(5,1,4);
h4=plot(squeeze(Tension_Hydrophone(xindex,yindex-ystep,:)),'k');
xlim([xmin xmax]);
ylim([ymin ymax]);
subplot(5,1,5);
h5=plot(squeeze(Tension_Hydrophone(xindex,yindex-2*ystep,:)),'k');
xlim([xmin xmax]);
ylim([ymin ymax]);

fignamecontrol = ['Evolution Hydrophone measures 200 cycles from ' num2str(yindex+2*ystep) ' to ' num2str(yindex-2*ystep) ' 500kHz - session 3'];
savefig(fignamecontrol)
saveas(gcf,fignamecontrol,'epsc')


figure
subplot(2,1,2);
h2=plot(squeeze(TensionHydrophone_200cy(xindex,98,:)),'k');
xlim([14000 23000]);
ylim([ymin ymax]);

for i=101:-1:1;
    set(h1,'YData',squeeze(TensionHydrophone_5cy(xindex,i,:)));
    set(h2,'YData',squeeze(TensionHydrophone_200cy(xindex,i,:)));
    pause(0.25);
end;

% 
% 
%     set(h1,'YData',squeeze(Tension_Hydrophone(24,85,:)));
%     set(h2,'YData',squeeze(Tension_Hydrophone(27,85,:)));
%     set(h3,'YData',squeeze(Tension_Hydrophone(30,85,:)));
    
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %% Analyse fréquentielle des données. 
% 
% % 
% 
% NSamples = 2^14;
% T= [0:(NSamples-1)]/SamplingFrequency;
% Freq_Axis = (-SamplingFrequency/2)+[0:NSamples-1]/NSamples*SamplingFrequency; % Permet de créer un vecteur qui va de -fs/2 à 1 echnatillon avant Fs/2
% Haar = (-1).^([0:NSamples-1]); % permet de recentrer les données en 0
% Haar = Haar';
% 
% for x=1:size(v,1)
%     for y=1:size(v,2)
%         Burst_Tension_Resampled(11,20,:) =  Tension_Hydrophone_5Cycles_250_Rot15_Crane(x,y,3617:end);% 3617 car on coupe les 3616 premiers échantillons car ce n'est que du
%             % BRUIT ET ON S4ARRANGE pour garder une puissance de 2 comme longueuer de
%             % vecteur!
%         
%         
%     end
% end
% x=11
% y=20
% 
% 
% Burst_Tension_Resampled(11,20,:) =  Tension_Hydrophone_5Cycles_250_Rot15_Crane(x,y,3617:end);% 3617 car on coupe les 3616 premiers échantillons car ce n'est que du
% % BRUIT ET ON S4ARRANGE pour garder une puissance de 2 comme longueuer de
% % vecteur!
% vecteur_Burst_Tension_Resampled = squeeze(Burst_Tension_Resampled(11,20,:));
% FFT_vecteur_Burst = (fft(vecteur_Burst_Tension_Resampled.*Haar)).*2;
% 
% FFT_vecteur_Burst(1:(NSamples/2)+1)= FFT_vecteur_Burst(1:(NSamples/2)+1).*0; % Partie freq neg = à 0
% vecteur_Burst_Complex = (ifft(FFT_vecteur_Burst)).*Haar;
% % Vecteur imaginaire décalé dans le temps d'un quart de période = ok (cfr
% % sin et cos quadrature)
% 
% 
% %Recherche frequence d'intéret afin de déterminer le déphasage
% Index_Freq_Interest = round(UltrasoundBurstFrequency/SamplingFrequency*NSamples+NSamples/2+1)
% 
% Freq_Axis(Index_Freq_Interest)
% FFT_vecteur_Burst(Index_Freq_Interest) % Amplitude et phase du signal à la freq voulue
% 
% 
% % Calculer rapport Recu/émis pour chaque point à sauvegarder
% % angle(S/T) %= dephasage entre émis et reçu cfr notes
% % abs(S/T)
% 
% figure;
% plot(Freq_Axis,abs(FFT_vecteur_Burst))
% 
% figure;
% plot(T,vecteur_Burst_Tension_Resampled)
% hold on
% plot(T,real(vecteur_Burst_Complex),'r')
% plot(T,imag(vecteur_Burst_Complex),'k')

% %% xcorr pour detecter latence des pics
% for x=1:size(v,1);
%     for y=1:size(v,2);
%         sigx=squeeze(Tension_FunctionGen(x,y,:));
%         sigy=squeeze(Tension_Hydrophone_Corr_Filtre(x,y,:));
%         [c,lag]=xcorr(sigx,sigy');
%         [a,b]=max(c);
%         maxlag(x,y)=lag(b);
%         maxcoeff(x,y)=a;
%         latencies(x,y)=NumCycle_FunctionGen(x,y)-maxlag(x,y);
%     end;
% end;
% 
% 
% figure;imagesc(latencies);
