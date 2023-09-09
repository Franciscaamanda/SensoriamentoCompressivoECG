function desempenho_medio_sinais(sinais)
tempo = 10;
%sinais = ["100m.mat" "101m.mat" "102m.mat" "103m.mat" "104m.mat" "105m.mat"];
soma_snr_dwt = [];
soma_snr_dct = [];
for n=1:length(sinais)
    %carrega e normaliza o sinal:
    x = load(sinais(n));
    y=x.val/2000;
    fs = 360;
    sinal_fft = abs(fft(y(1,1:fs*tempo)));
   
    %Aplica o filtro passa-baixa chebyshev tipo 2:
    [b,a] = cheby2(8, 20, 0.333);
    sinal_menos_ruido = filtfilt(b, a, y(1, 1:tempo*fs));
   
    %Aplica o filtro passa-alta chebyshev tipo 2:
    [b,a] = cheby2(4,20,0.65/(fs/2),'high');
    sinal_processado = filtfilt(b, a, sinal_menos_ruido);
   
    %Calcula a distancia/tempo entre cada pico do sinal e obtem a media:
    [altura_y, posicao_x] = findpeaks(sinal_processado, 'MinPeakHeight',0.05, 'MinPeakProminence', 0.04);
    posicao_maior_energia = []; %coeficiente central entre um pico e outro
    for i=2:length(posicao_x)
        posicao_maior_energia(i-1) = round((posicao_x(i) + posicao_x(i-1))/2);
    end
    distancia_ciclo = []; %calcula o tamanho de cada sinal
    distancia_ciclo(1) = posicao_maior_energia(1);
   
    %Compara o desempenho da dct com a dwt:
    %Calcula a média do snr de cada ciclo do sinal:
    k=0;
    vetor_snr_dwt = [];
    vetor_snr_dct = [];
    for taxa=0.05:0.05:0.95
        k = k+1;
        [y,SNRdB_dct(k)] = compressao_dct(sinal_processado(1:posicao_maior_energia(1)),taxa);
        [y,SNRdB_wavelet(k)] = compressao_wavelets(sinal_processado(1:posicao_maior_energia(1)),taxa);
        SNR_dwt=0;
        SNR_dct = 0;
        contador = 0;
        SNR_dwt = SNR_dwt + SNRdB_wavelet(k);
        SNR_dct = SNR_dct + SNRdB_dct(k);
        contador = contador + 1;
        for i=2:length(posicao_maior_energia)
            [y,SNRdB_dct(k)] = compressao_dct(sinal_processado(posicao_maior_energia(i-1):posicao_maior_energia(i)),taxa);
            [y,SNRdB_wavelet(k)] = compressao_wavelets(sinal_processado(posicao_maior_energia(i-1):posicao_maior_energia(i)),taxa);
            SNR_dwt = SNR_dwt + SNRdB_wavelet(k);
            SNR_dct = SNR_dct + SNRdB_dct(k);
            contador =contador + 1;
            if i == length(posicao_maior_energia)
                [y,SNRdB_dct(k)] = compressao_dct(sinal_processado(posicao_maior_energia(i):fs*tempo),taxa);
                [y,SNRdB_wavelet(k)] = compressao_wavelets(sinal_processado(posicao_maior_energia(i):fs*tempo),taxa);
                SNR_dwt = SNR_dwt + SNRdB_wavelet(k);
                SNR_dct = SNR_dct + SNRdB_dct(k);
                contador = contador + 1;
            end
        end
        snr_medio_dwt = SNR_dwt./contador;
        snr_medio_dct = SNR_dct./contador;
        vetor_snr_dwt(k) = snr_medio_dwt;
        vetor_snr_dct(k) = snr_medio_dct;
    end
    %Calcula a média do snr de todos os sinais:
    if n == 1
        soma_snr_dwt = vetor_snr_dwt;
        soma_snr_dct = vetor_snr_dct;
    end
    if n>1
        soma_snr_dwt = soma_snr_dwt + vetor_snr_dwt;
        soma_snr_dct = soma_snr_dct + vetor_snr_dct;
    end
end
snr_dwt_sinais = soma_snr_dwt./length(sinais);
snr_dct_sinais = soma_snr_dct./length(sinais);
taxa=0.05:0.05:0.95;
plot(taxa,snr_dct_sinais);
hold;
plot(taxa,snr_dwt_sinais,'g');
legend('DCT', 'DWT');
title('SNR X Taxa de Compressão');