function compressao_sinal(sinal, transformada, taxa_compressao)
tempo=10;
%carrega e normaliza o sinal:
x = load(sinal);
y=x.val/2000;
fs = 360;
%plot(y(1:fs*tempo,1)); %sinal original
sinal_fft = abs(fft(y(1,1:fs*tempo)));

%Aplica o filtro passa-baixa chebyshev tipo 2:
[b,a] = cheby2(8, 20, 0.333);
sinal_menos_ruido = filtfilt(b, a, y(1, 1:tempo*fs));

%Aplica o filtro passa-alta chebyshev tipo 2:
[b,a] = cheby2(4,20,0.65/(fs/2),'high');
sinal_processado = filtfilt(b, a, sinal_menos_ruido);

%Calcula a distancia/tempo entre cada pico do sinal e obtem a media:
[altura_y, posicao_x] = findpeaks(sinal_processado, 'MinPeakHeight',0.05, 'MinPeakProminence', 0.04);
%disp(posicao_x);
posicao_maior_energia = []; %coeficiente central entre um pico e outro
for i=2:length(posicao_x)
    posicao_maior_energia(i-1) = round((posicao_x(i) + posicao_x(i-1))/2);
end
distancia_ciclo = []; %calcula o tamanho de cada sinal
distancia_ciclo(1) = posicao_maior_energia(1);

%Faz a compressão em cada ciclo do sinal:
y = [];
switch transformada
    case 'cosseno'
        [y(1:posicao_maior_energia(1)), SNRdB] = compressao_dct(sinal_processado(1:posicao_maior_energia(1)), taxa_compressao);
        SNR=0;
        contador = 0;
        SNR = SNR + SNRdB;
        contador = contador + 1;
        for i=2:length(posicao_maior_energia)
            [y(posicao_maior_energia(i-1):posicao_maior_energia(i)), SNRdB] = compressao_dct(sinal_processado(posicao_maior_energia(i-1):posicao_maior_energia(i)), taxa_compressao);
            SNR = SNR + SNRdB;
            contador =contador + 1;
            if i == length(posicao_maior_energia)
                [y(posicao_maior_energia(i):fs*tempo), SNRdB] = compressao_dct(sinal_processado(posicao_maior_energia(i):fs*tempo), taxa_compressao);
                SNR = SNR + SNRdB;
                contador = contador + 1;
            end
        end
    case 'wavelet'
        [y(1:posicao_maior_energia(1)), SNRdB] = compressao_wavelets(sinal_processado(1:posicao_maior_energia(1)), taxa_compressao);
        SNR=0;
        contador = 0;
        SNR = SNR + SNRdB;
        contador = contador + 1;
        for i=2:length(posicao_maior_energia)
            [y(posicao_maior_energia(i-1):posicao_maior_energia(i)), SNRdB] = compressao_wavelets(sinal_processado(posicao_maior_energia(i-1):posicao_maior_energia(i)), taxa_compressao);
            SNR = SNR + SNRdB;
            contador =contador + 1;
            if i == length(posicao_maior_energia)
                [y(posicao_maior_energia(i):fs*tempo), SNRdB] = compressao_wavelets(sinal_processado(posicao_maior_energia(i):fs*tempo), taxa_compressao);
                SNR = SNR + SNRdB;
                contador = contador + 1;
            end
        end
end
snr_medio = SNR./contador;
plot(sinal_processado, 'g');
hold;
plot(y, 'b'); %sinal comprimido
titulo = sprintf('%s com %d%% de compressão', transformada, taxa_compressao*100);
title(titulo);