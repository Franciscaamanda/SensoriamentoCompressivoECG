function centraliza_sinal(sinal, opcao)
%carrega e normaliza o sinal:
x = load(sinal);
y=x.val/2000;
fs = 360;

sinal_fft = abs(fft(y(1,1:fs*60)));
%plot(sinal_fft); %sinal transformado

%Aplica o filtro passa-alta chebyshev tipo 2:
[b,a] = cheby2(4,20,0.65/(fs/2),'high');
%freqz(b,a,[],fs);
sinal_processado = filtfilt(b, a, y(1, 1:60*fs));

switch opcao
    case 1
        plot(y(1,1:fs*60)); %sinal original
        title('Sinal Original');
    case 2
        plot(sinal_processado);
        title('Sinal Centralizado');
end