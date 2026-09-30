%% ================================================================
% MATLAB SIMULATION AND PERFORMANCE ANALYSIS
% OF A SATELLITE COMMUNICATION LINK
%
% BPSK, QPSK AND 16-QAM OVER AWGN
% GEO SATELLITE LINK BUDGET
% BER ANALYSIS
% TRANSMIT POWER SENSITIVITY
% ADDITIONAL LOSS SENSITIVITY
% CONSTELLATION ANALYSIS
%
% Prepared by: Sanjida Alam
% Course: Satellite Communications-2
% ================================================================

clear;
clc;
close all;
rng(1);

%% 1. BASELINE SATELLITE COMMUNICATION PARAMETERS

f_GHz = 12;
d_km = 36000;
Pt_W = 10;
Gt_dBi = 40;
Gr_dBi = 45;
TxLoss_dB = 2;
RxLoss_dB = 2;
OtherLoss_dB = 2;
Tsys_K = 500;
Rb_bps = 10e6;

k_B = 1.380649e-23;

% The assignment does not specify a required Eb/N0.
% Therefore, 10 dB is used as a design-reference requirement.
Required_EbN0_dB = 10;

% BER reference for modulation/link-margin comparison
Target_BER = 1e-5;

%% 2. SATELLITE LINK BUDGET CALCULATIONS

Pt_dBW = 10*log10(Pt_W);

% FSPL(dB) = 92.45 + 20log10(f_GHz) + 20log10(d_km)
FSPL_dB = 92.45 ...
    + 20*log10(f_GHz) ...
    + 20*log10(d_km);

TotalLoss_dB = TxLoss_dB + RxLoss_dB + OtherLoss_dB;

EIRP_dBW = Pt_dBW + Gt_dBi - TxLoss_dB;

Pr_dBW = Pt_dBW ...
    + Gt_dBi ...
    + Gr_dBi ...
    - FSPL_dB ...
    - TotalLoss_dB;

Pr_W = 10^(Pr_dBW/10);

% Reference noise bandwidth is taken as the bit rate
Noise_W = k_B*Tsys_K*Rb_bps;
Noise_dBW = 10*log10(Noise_W);

CN_dB = Pr_dBW - Noise_dBW;

kT_dBW_Hz = 10*log10(k_B*Tsys_K);
CN0_dBHz = Pr_dBW - kT_dBW_Hz;

EbN0_dB = CN0_dBHz - 10*log10(Rb_bps);

LinkMargin_dB = EbN0_dB - Required_EbN0_dB;

%% 3. DISPLAY LINK BUDGET RESULTS

fprintf('\n');
fprintf('===============================================================\n');
fprintf(' SATELLITE LINK BUDGET RESULTS\n');
fprintf('===============================================================\n');
fprintf('Frequency = %.2f GHz\n',f_GHz);
fprintf('Satellite distance = %.0f km\n',d_km);
fprintf('Transmit power = %.2f W\n',Pt_W);
fprintf('Transmit power = %.3f dBW\n',Pt_dBW);
fprintf('Transmit antenna gain = %.2f dBi\n',Gt_dBi);
fprintf('Receive antenna gain = %.2f dBi\n',Gr_dBi);
fprintf('Transmitter loss = %.2f dB\n',TxLoss_dB);
fprintf('Receiver loss = %.2f dB\n',RxLoss_dB);
fprintf('Other loss = %.2f dB\n',OtherLoss_dB);
fprintf('System noise temperature = %.2f K\n',Tsys_K);
fprintf('Bit rate = %.2f Mbps\n',Rb_bps/1e6);
fprintf('\n');
fprintf('---------------- LINK CALCULATIONS ----------------\n');
fprintf('FSPL = %.3f dB\n',FSPL_dB);
fprintf('Total additional loss = %.3f dB\n',TotalLoss_dB);
fprintf('EIRP = %.3f dBW\n',EIRP_dBW);
fprintf('Received power = %.3f dBW\n',Pr_dBW);
fprintf('Received power = %.3e W\n',Pr_W);
fprintf('Noise power = %.3f dBW\n',Noise_dBW);
fprintf('C/N = %.3f dB\n',CN_dB);
fprintf('C/N0 = %.3f dB-Hz\n',CN0_dBHz);
fprintf('Eb/N0 = %.3f dB\n',EbN0_dB);
fprintf('Link margin @ 10 dB = %.3f dB\n',LinkMargin_dB);
fprintf('===============================================================\n');

%% 4. THEORETICAL BER CALCULATIONS

EbN0_range_dB = 0:0.5:20;
gamma = 10.^(EbN0_range_dB/10);

BER_BPSK_theory = 0.5*erfc(sqrt(gamma));
BER_QPSK_theory = 0.5*erfc(sqrt(gamma));
BER_16QAM_theory = 0.375*erfc(sqrt(0.4*gamma));

%% 5. MONTE-CARLO BER SIMULATION

Nbits = 200000;
EbN0_sim_dB = 0:2:20;

BER_BPSK_sim = zeros(size(EbN0_sim_dB));
BER_QPSK_sim = zeros(size(EbN0_sim_dB));
BER_16QAM_sim = zeros(size(EbN0_sim_dB));

fprintf('\n');
fprintf('===============================================================\n');
fprintf(' BER SIMULATION\n');
fprintf('===============================================================\n');
fprintf('Number of bits per BER point = %d\n',Nbits);
fprintf('Simulation is now running...\n\n');

for ii = 1:length(EbN0_sim_dB)

    EbN0_linear = 10^(EbN0_sim_dB(ii)/10);

    %% BPSK
    bits = randi([0 1],Nbits,1);
    tx = 1 - 2*bits;

    N0 = 1/EbN0_linear;
    noise = sqrt(N0/2)*randn(Nbits,1);
    rx = tx + noise;

    detected_bits = rx < 0;
    errors = sum(detected_bits ~= bits);
    BER_BPSK_sim(ii) = errors/Nbits;

    %% QPSK
    Nbits_QPSK = floor(Nbits/2)*2;
    bitsQ = randi([0 1],Nbits_QPSK,1);

    b1 = bitsQ(1:2:end);
    b2 = bitsQ(2:2:end);

    txQ = ((1-2*b1) + 1i*(1-2*b2))/sqrt(2);

    N0_QPSK = 1/(2*EbN0_linear);
    noiseQ = sqrt(N0_QPSK/2) * ...
        (randn(length(txQ),1) + 1i*randn(length(txQ),1));

    rxQ = txQ + noiseQ;

    detected_b1 = real(rxQ) < 0;
    detected_b2 = imag(rxQ) < 0;

    detected_bitsQ = zeros(Nbits_QPSK,1);
    detected_bitsQ(1:2:end) = detected_b1;
    detected_bitsQ(2:2:end) = detected_b2;

    errorsQ = sum(detected_bitsQ ~= bitsQ);
    BER_QPSK_sim(ii) = errorsQ/Nbits_QPSK;

    %% 16-QAM
    Nbits_QAM = floor(Nbits/4)*4;
    bitsM = randi([0 1],Nbits_QAM,1);

    bm = reshape(bitsM,4,[]).';

    decI = 2*bm(:,1) + bm(:,2);
    decQ = 2*bm(:,3) + bm(:,4);

    levelMap = [-3; -1; 3; 1];

    I = levelMap(decI + 1);
    Q = levelMap(decQ + 1);

    txM = (I + 1i*Q)/sqrt(10);

    N0_QAM = 1/(4*EbN0_linear);
    noiseM = sqrt(N0_QAM/2) * ...
        (randn(length(txM),1) + 1i*randn(length(txM),1));

    rxM = txM + noiseM;

    rI = real(rxM)*sqrt(10);
    rQ = imag(rxM)*sqrt(10);

    levels = [-3; -1; 3; 1];

    detectedDecI = zeros(length(rI),1);
    detectedDecQ = zeros(length(rQ),1);

    for jj = 1:length(rI)
        [~,indexI] = min(abs(rI(jj)-levels));
        [~,indexQ] = min(abs(rQ(jj)-levels));
        detectedDecI(jj) = indexI-1;
        detectedDecQ(jj) = indexQ-1;
    end

    detected_b1 = floor(detectedDecI/2);
    detected_b2 = mod(detectedDecI,2);
    detected_b3 = floor(detectedDecQ/2);
    detected_b4 = mod(detectedDecQ,2);

    detectedMatrix = [detected_b1 detected_b2 detected_b3 detected_b4];
    detected_bitsM = reshape(detectedMatrix.',[],1);

    errorsM = sum(detected_bitsM ~= bitsM);
    BER_16QAM_sim(ii) = errorsM/Nbits_QAM;

    fprintf(['Eb/N0 = %2d dB : ' ...
        'BPSK errors = %6d, ' ...
        'QPSK errors = %6d, ' ...
        '16-QAM errors = %6d\n'], ...
        EbN0_sim_dB(ii),errors,errorsQ,errorsM);
end

fprintf('\nBER simulation complete.\n');

%% 6. COMBINED BER COMPARISON GRAPH

figure('Name','BER Comparison','NumberTitle','off');

semilogy(EbN0_range_dB,BER_BPSK_theory,'LineWidth',2);
hold on;
semilogy(EbN0_range_dB,BER_QPSK_theory,'--','LineWidth',2);
semilogy(EbN0_range_dB,BER_16QAM_theory,'LineWidth',2);

plotB = BER_BPSK_sim;
plotQ = BER_QPSK_sim;
plotM = BER_16QAM_sim;

plotB(plotB == 0) = NaN;
plotQ(plotQ == 0) = NaN;
plotM(plotM == 0) = NaN;

semilogy(EbN0_sim_dB,plotB,'o','MarkerSize',6,'LineWidth',1.5);
semilogy(EbN0_sim_dB,plotQ,'s','MarkerSize',6,'LineWidth',1.5);
semilogy(EbN0_sim_dB,plotM,'d','MarkerSize',6,'LineWidth',1.5);

grid on;
xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate (BER)');
title('BER Performance of BPSK, QPSK and 16-QAM over AWGN');

legend('BPSK Theory','QPSK Theory','16-QAM Theory', ...
    'BPSK Simulation','QPSK Simulation','16-QAM Simulation', ...
    'Location','southwest');

ylim([1e-6 1]);
xlim([0 20]);

%% 7. BER AT BASELINE SATELLITE Eb/N0

baselineGamma = 10^(EbN0_dB/10);

Baseline_BER_BPSK = 0.5*erfc(sqrt(baselineGamma));
Baseline_BER_QPSK = 0.5*erfc(sqrt(baselineGamma));
Baseline_BER_16QAM = 0.375*erfc(sqrt(0.4*baselineGamma));

fprintf('\n');
fprintf('===============================================================\n');
fprintf(' BER AT BASELINE SATELLITE Eb/N0\n');
fprintf('===============================================================\n');
fprintf('Baseline Eb/N0 = %.3f dB\n',EbN0_dB);
fprintf('BPSK theoretical BER = %.4e\n',Baseline_BER_BPSK);
fprintf('QPSK theoretical BER = %.4e\n',Baseline_BER_QPSK);
fprintf('16-QAM theoretical BER = %.4e\n',Baseline_BER_16QAM);
fprintf('===============================================================\n');

%% 8. REQUIRED Eb/N0 FOR BER = 10^-5

fineEbN0 = 0:0.001:25;
fineGamma = 10.^(fineEbN0/10);

fineBER_BPSK = 0.5*erfc(sqrt(fineGamma));
fineBER_QPSK = 0.5*erfc(sqrt(fineGamma));
fineBER_16QAM = 0.375*erfc(sqrt(0.4*fineGamma));

idxB = find(fineBER_BPSK <= Target_BER,1,'first');
idxQ = find(fineBER_QPSK <= Target_BER,1,'first');
idxM = find(fineBER_16QAM <= Target_BER,1,'first');

Required_BPSK = fineEbN0(idxB);
Required_QPSK = fineEbN0(idxQ);
Required_16QAM = fineEbN0(idxM);

Margin_BPSK = EbN0_dB - Required_BPSK;
Margin_QPSK = EbN0_dB - Required_QPSK;
Margin_16QAM = EbN0_dB - Required_16QAM;

fprintf('\n');
fprintf('===============================================================\n');
fprintf(' LINK MARGIN USING BER = 10^-5 REFERENCE\n');
fprintf('===============================================================\n');
fprintf('Required BPSK Eb/N0 = %.3f dB\n',Required_BPSK);
fprintf('Required QPSK Eb/N0 = %.3f dB\n',Required_QPSK);
fprintf('Required 16-QAM Eb/N0 = %.3f dB\n',Required_16QAM);
fprintf('\n');
fprintf('BPSK link margin = %.3f dB\n',Margin_BPSK);
fprintf('QPSK link margin = %.3f dB\n',Margin_QPSK);
fprintf('16-QAM link margin = %.3f dB\n',Margin_16QAM);
fprintf('===============================================================\n');

%% 9. TRANSMIT POWER SENSITIVITY

Power_values = [2 5 10 20 40];

Power_EbN0_dB = zeros(size(Power_values));
Power_Pr_dBW = zeros(size(Power_values));

for ii = 1:length(Power_values)
    Power_EbN0_dB(ii) = EbN0_dB + ...
        10*log10(Power_values(ii)/Pt_W);

    Power_Pr_dBW(ii) = Pr_dBW + ...
        10*log10(Power_values(ii)/Pt_W);
end

fprintf('\n');
fprintf('===============================================================\n');
fprintf(' TRANSMIT POWER SENSITIVITY\n');
fprintf('===============================================================\n');
fprintf('%12s %20s %18s\n', ...
    'Power (W)','Received Power (dBW)','Eb/N0 (dB)');
fprintf('---------------------------------------------------------------\n');

for ii = 1:length(Power_values)
    fprintf('%12.1f %20.3f %18.3f\n', ...
        Power_values(ii),Power_Pr_dBW(ii),Power_EbN0_dB(ii));
end

fprintf('===============================================================\n');

figure('Name','Transmit Power Sensitivity','NumberTitle','off');

plot(Power_values,Power_EbN0_dB,'o-','LineWidth',2,'MarkerSize',7);

grid on;
xlabel('Transmit Power (W)');
ylabel('E_b/N_0 (dB)');
title('Transmit Power Sensitivity');
xlim([0 42]);

%% 10. ADDITIONAL LOSS SENSITIVITY

AdditionalLoss_values = [0 2 5 8 10 12 15];

Loss_EbN0_dB = zeros(size(AdditionalLoss_values));
Loss_Pr_dBW = zeros(size(AdditionalLoss_values));

for ii = 1:length(AdditionalLoss_values)

    Loss_Pr_dBW(ii) = Pr_dBW + ...
        (OtherLoss_dB - AdditionalLoss_values(ii));

    Loss_EbN0_dB(ii) = EbN0_dB + ...
        (OtherLoss_dB - AdditionalLoss_values(ii));
end

fprintf('\n');
fprintf('===============================================================\n');
fprintf(' ADDITIONAL LOSS SENSITIVITY\n');
fprintf('===============================================================\n');
fprintf('%18s %20s %18s\n', ...
    'Additional Loss (dB)','Received Power (dBW)','Eb/N0 (dB)');
fprintf('---------------------------------------------------------------\n');

for ii = 1:length(AdditionalLoss_values)
    fprintf('%18.1f %20.3f %18.3f\n', ...
        AdditionalLoss_values(ii), ...
        Loss_Pr_dBW(ii), ...
        Loss_EbN0_dB(ii));
end

fprintf('===============================================================\n');

figure('Name','Additional Loss Sensitivity','NumberTitle','off');

plot(AdditionalLoss_values,Loss_EbN0_dB,'s-','LineWidth',2,'MarkerSize',7);

grid on;
xlabel('Additional Loss (dB)');
ylabel('E_b/N_0 (dB)');
title('Additional Loss Sensitivity');

%% 11. EFFECT OF 3 dB ADDITIONAL LOSS

EbN0_after_3dB_loss = EbN0_dB - 3;
Loss_change = EbN0_after_3dB_loss - EbN0_dB;

fprintf('\n');
fprintf('===============================================================\n');
fprintf(' EFFECT OF 3 dB ADDITIONAL LOSS\n');
fprintf('===============================================================\n');
fprintf('Original Eb/N0 = %.3f dB\n',EbN0_dB);
fprintf('Eb/N0 after 3 dB loss = %.3f dB\n',EbN0_after_3dB_loss);
fprintf('Change in Eb/N0 = %.3f dB\n',Loss_change);
fprintf('===============================================================\n');

%% 12. EFFECT OF DOUBLING TRANSMIT POWER

Pt_double_W = 2*Pt_W;
EbN0_after_double = EbN0_dB + 10*log10(2);
Power_gain = EbN0_after_double - EbN0_dB;

fprintf('\n');
fprintf('===============================================================\n');
fprintf(' EFFECT OF DOUBLING TRANSMIT POWER\n');
fprintf('===============================================================\n');
fprintf('Original transmit power = %.2f W\n',Pt_W);
fprintf('Doubled transmit power = %.2f W\n',Pt_double_W);
fprintf('Original Eb/N0 = %.3f dB\n',EbN0_dB);
fprintf('Eb/N0 after doubling power = %.3f dB\n',EbN0_after_double);
fprintf('Increase in Eb/N0 = %.3f dB\n',Power_gain);
fprintf('===============================================================\n');

%% 13. CONSTELLATION ANALYSIS SETUP
%
% The following section creates three separate figures:
%   1. BPSK: Ideal / Light AWGN / Heavy AWGN
%   2. QPSK: Ideal / Light AWGN / Heavy AWGN
%   3. 16-QAM: Ideal / Light AWGN / Heavy AWGN
%
% Light AWGN uses the project's baseline Eb/N0.
% Heavy AWGN uses 6 dB as a visualization condition.

Nconst = 5000;

EbN0_light_dB = EbN0_dB;
EbN0_heavy_dB = 6;

gamma_light = 10^(EbN0_light_dB/10);
gamma_heavy = 10^(EbN0_heavy_dB/10);

%% BPSK symbols

bits_BPSK = randi([0 1],Nconst,1);

tx_BPSK = 1 - 2*bits_BPSK;

rx_BPSK_ideal = tx_BPSK;

N0_BPSK_light = 1/gamma_light;
noise_BPSK_light = sqrt(N0_BPSK_light/2)*randn(Nconst,1);
rx_BPSK_light = tx_BPSK + noise_BPSK_light;

N0_BPSK_heavy = 1/gamma_heavy;
noise_BPSK_heavy = sqrt(N0_BPSK_heavy/2)*randn(Nconst,1);
rx_BPSK_heavy = tx_BPSK + noise_BPSK_heavy;

%% QPSK symbols

bits_QPSK = randi([0 1],2*Nconst,1);

b1 = bits_QPSK(1:2:end);
b2 = bits_QPSK(2:2:end);

tx_QPSK = ((1-2*b1) + 1i*(1-2*b2))/sqrt(2);

rx_QPSK_ideal = tx_QPSK;

N0_QPSK_light = 1/(2*gamma_light);
noise_QPSK_light = sqrt(N0_QPSK_light/2) * ...
    (randn(Nconst,1) + 1i*randn(Nconst,1));
rx_QPSK_light = tx_QPSK + noise_QPSK_light;

N0_QPSK_heavy = 1/(2*gamma_heavy);
noise_QPSK_heavy = sqrt(N0_QPSK_heavy/2) * ...
    (randn(Nconst,1) + 1i*randn(Nconst,1));
rx_QPSK_heavy = tx_QPSK + noise_QPSK_heavy;

%% 16-QAM symbols

bits_16QAM = randi([0 1],4*Nconst,1);

bitGroups = reshape(bits_16QAM,4,[]).';

decimalI = 2*bitGroups(:,1) + bitGroups(:,2);
decimalQ = 2*bitGroups(:,3) + bitGroups(:,4);

levelMap = [-3 -1 3 1];

I = levelMap(decimalI + 1);
Q = levelMap(decimalQ + 1);

tx_16QAM = (I + 1i*Q)/sqrt(10);

rx_16QAM_ideal = tx_16QAM;

N0_16QAM_light = 1/(4*gamma_light);
noise_16QAM_light = sqrt(N0_16QAM_light/2) * ...
    (randn(Nconst,1) + 1i*randn(Nconst,1));
rx_16QAM_light = tx_16QAM + noise_16QAM_light;

N0_16QAM_heavy = 1/(4*gamma_heavy);
noise_16QAM_heavy = sqrt(N0_16QAM_heavy/2) * ...
    (randn(Nconst,1) + 1i*randn(Nconst,1));
rx_16QAM_heavy = tx_16QAM + noise_16QAM_heavy;

%% Ideal reference points

ideal_BPSK = [-1 1];

ideal_QPSK = [1+1i 1-1i -1+1i -1-1i]/sqrt(2);

levels = [-3 -1 1 3]/sqrt(10);
[Iideal,Qideal] = meshgrid(levels,levels);
ideal_16QAM = Iideal(:) + 1i*Qideal(:);

%% 14. BPSK CONSTELLATION FIGURE

figure('Name','BPSK Constellation Analysis', ...
    'NumberTitle','off','Position',[100 150 1200 450]);

subplot(1,3,1);

plot(real(rx_BPSK_ideal),imag(rx_BPSK_ideal),'.', ...
    'Color',[0 0.45 0.74],'MarkerSize',10);
hold on;

plot(real(ideal_BPSK),imag(ideal_BPSK),'kx', ...
    'MarkerSize',14,'LineWidth',2);

grid on;
axis equal;
xlim([-1.6 1.6]);
ylim([-1.6 1.6]);
xlabel('In-Phase');
ylabel('Quadrature');
title('BPSK - Ideal');
legend('Symbols','Ideal Points','Location','best');

subplot(1,3,2);

plot(real(rx_BPSK_light),imag(rx_BPSK_light),'.', ...
    'Color',[0.85 0.33 0.10],'MarkerSize',8);
hold on;

plot(real(ideal_BPSK),imag(ideal_BPSK),'kx', ...
    'MarkerSize',14,'LineWidth',2);

grid on;
axis equal;
xlim([-1.6 1.6]);
ylim([-1.6 1.6]);
xlabel('In-Phase');
ylabel('Quadrature');
title(sprintf('BPSK - Light AWGN\nE_b/N_0 = %.2f dB',EbN0_light_dB));
legend('Received Symbols','Ideal Points','Location','best');

subplot(1,3,3);

plot(real(rx_BPSK_heavy),imag(rx_BPSK_heavy),'.', ...
    'Color',[0.49 0.18 0.56],'MarkerSize',8);
hold on;

plot(real(ideal_BPSK),imag(ideal_BPSK),'kx', ...
    'MarkerSize',14,'LineWidth',2);

grid on;
axis equal;
xlim([-2.2 2.2]);
ylim([-2.2 2.2]);
xlabel('In-Phase');
ylabel('Quadrature');
title(sprintf('BPSK - Heavy AWGN\nE_b/N_0 = %.2f dB',EbN0_heavy_dB));
legend('Received Symbols','Ideal Points','Location','best');

sgtitle('BPSK Constellation Under Different Noise Conditions', ...
    'FontSize',14,'FontWeight','bold');

%% 15. QPSK CONSTELLATION FIGURE

figure('Name','QPSK Constellation Analysis', ...
    'NumberTitle','off','Position',[100 150 1200 450]);

subplot(1,3,1);

plot(real(rx_QPSK_ideal),imag(rx_QPSK_ideal),'.', ...
    'Color',[0 0.45 0.74],'MarkerSize',10);
hold on;

plot(real(ideal_QPSK),imag(ideal_QPSK),'kx', ...
    'MarkerSize',14,'LineWidth',2);

grid on;
axis equal;
xlim([-1.6 1.6]);
ylim([-1.6 1.6]);
xlabel('In-Phase');
ylabel('Quadrature');
title('QPSK - Ideal');
legend('Symbols','Ideal Points','Location','best');

subplot(1,3,2);

plot(real(rx_QPSK_light),imag(rx_QPSK_light),'.', ...
    'Color',[0.85 0.33 0.10],'MarkerSize',8);
hold on;

plot(real(ideal_QPSK),imag(ideal_QPSK),'kx', ...
    'MarkerSize',14,'LineWidth',2);

grid on;
axis equal;
xlim([-1.6 1.6]);
ylim([-1.6 1.6]);
xlabel('In-Phase');
ylabel('Quadrature');
title(sprintf('QPSK - Light AWGN\nE_b/N_0 = %.2f dB',EbN0_light_dB));
legend('Received Symbols','Ideal Points','Location','best');

subplot(1,3,3);

plot(real(rx_QPSK_heavy),imag(rx_QPSK_heavy),'.', ...
    'Color',[0.49 0.18 0.56],'MarkerSize',8);
hold on;

plot(real(ideal_QPSK),imag(ideal_QPSK),'kx', ...
    'MarkerSize',14,'LineWidth',2);

grid on;
axis equal;
xlim([-2.2 2.2]);
ylim([-2.2 2.2]);
xlabel('In-Phase');
ylabel('Quadrature');
title(sprintf('QPSK - Heavy AWGN\nE_b/N_0 = %.2f dB',EbN0_heavy_dB));
legend('Received Symbols','Ideal Points','Location','best');

sgtitle('QPSK Constellation Under Different Noise Conditions', ...
    'FontSize',14,'FontWeight','bold');

%% 16. 16-QAM CONSTELLATION FIGURE

figure('Name','16-QAM Constellation Analysis', ...
    'NumberTitle','off','Position',[100 150 1200 450]);

subplot(1,3,1);

plot(real(rx_16QAM_ideal),imag(rx_16QAM_ideal),'.', ...
    'Color',[0 0.45 0.74],'MarkerSize',10);
hold on;

plot(real(ideal_16QAM),imag(ideal_16QAM),'kx', ...
    'MarkerSize',12,'LineWidth',2);

grid on;
axis equal;
xlim([-1.2 1.2]);
ylim([-1.2 1.2]);
xlabel('In-Phase');
ylabel('Quadrature');
title('16-QAM - Ideal');
legend('Symbols','Ideal Points','Location','best');

subplot(1,3,2);

plot(real(rx_16QAM_light),imag(rx_16QAM_light),'.', ...
    'Color',[0.85 0.33 0.10],'MarkerSize',8);
hold on;

plot(real(ideal_16QAM),imag(ideal_16QAM),'kx', ...
    'MarkerSize',12,'LineWidth',2);

grid on;
axis equal;
xlim([-1.2 1.2]);
ylim([-1.2 1.2]);
xlabel('In-Phase');
ylabel('Quadrature');
title(sprintf('16-QAM - Light AWGN\nE_b/N_0 = %.2f dB',EbN0_light_dB));
legend('Received Symbols','Ideal Points','Location','best');

subplot(1,3,3);

plot(real(rx_16QAM_heavy),imag(rx_16QAM_heavy),'.', ...
    'Color',[0.49 0.18 0.56],'MarkerSize',8);
hold on;

plot(real(ideal_16QAM),imag(ideal_16QAM),'kx', ...
    'MarkerSize',12,'LineWidth',2);

grid on;
axis equal;
xlim([-1.5 1.5]);
ylim([-1.5 1.5]);
xlabel('In-Phase');
ylabel('Quadrature');
title(sprintf('16-QAM - Heavy AWGN\nE_b/N_0 = %.2f dB',EbN0_heavy_dB));
legend('Received Symbols','Ideal Points','Location','best');

sgtitle('16-QAM Constellation Under Different Noise Conditions', ...
    'FontSize',14,'FontWeight','bold');

%% 17. FINAL SUMMARY

fprintf('\n\n');
fprintf('################################################################\n');
fprintf('# FINAL PROJECT SUMMARY #\n');
fprintf('################################################################\n');
fprintf('\n');

fprintf('BASELINE LINK BUDGET\n');
fprintf('--------------------\n');
fprintf('FSPL = %.3f dB\n',FSPL_dB);
fprintf('Received power = %.3f dBW\n',Pr_dBW);
fprintf('C/N = %.3f dB\n',CN_dB);
fprintf('C/N0 = %.3f dB-Hz\n',CN0_dBHz);
fprintf('Eb/N0 = %.3f dB\n',EbN0_dB);
fprintf('Link margin @ 10 dB = %.3f dB\n',LinkMargin_dB);

fprintf('\n');
fprintf('BER REFERENCE = 10^-5\n');
fprintf('---------------------\n');
fprintf('BPSK required Eb/N0 = %.3f dB\n',Required_BPSK);
fprintf('QPSK required Eb/N0 = %.3f dB\n',Required_QPSK);
fprintf('16-QAM required Eb/N0 = %.3f dB\n',Required_16QAM);

fprintf('\n');
fprintf('BER-BASED LINK MARGINS\n');
fprintf('----------------------\n');
fprintf('BPSK margin = %.3f dB\n',Margin_BPSK);
fprintf('QPSK margin = %.3f dB\n',Margin_QPSK);
fprintf('16-QAM margin = %.3f dB\n',Margin_16QAM);

fprintf('\n');
fprintf('IMPORTANT OBSERVATIONS\n');
fprintf('----------------------\n');
fprintf('1. BPSK and QPSK have approximately the same BER in AWGN.\n');
fprintf('2. QPSK carries 2 bits per symbol, while BPSK carries 1 bit.\n');
fprintf('3. 16-QAM requires higher Eb/N0 for the same BER.\n');
fprintf('4. Doubling transmit power improves Eb/N0 by about 3 dB.\n');
fprintf('5. An additional 3 dB loss reduces Eb/N0 by 3 dB.\n');
fprintf('6. Higher transmit power improves the communication link.\n');
fprintf('7. Additional link loss reduces the communication margin.\n');

fprintf('\n');
fprintf('CONSTELLATION ANALYSIS\n');
fprintf('----------------------\n');
fprintf('Light AWGN Eb/N0 = %.2f dB\n',EbN0_light_dB);
fprintf('Heavy AWGN Eb/N0 = %.2f dB\n',EbN0_heavy_dB);
fprintf('Three separate constellation figures were generated.\n');
fprintf('Each figure contains Ideal, Light AWGN, and Heavy AWGN plots.\n');

fprintf('\n');
fprintf('################################################################\n');
fprintf('# SIMULATION COMPLETE #\n');
fprintf('################################################################\n');
