function reduz_ruido(sinal, opcao)
%carrega e normaliza o sinal:
x = load(sinal);
y=x.val/2000;
fs = 360;
sinal_fft = abs(fft(y(1,1:fs*10)));
%plot(sinal_fft); %sinal transformado

%Aplica o filtro passa-baixa chebyshev tipo 2:
[b,a] = cheby2(8, 20, 0.333);
sinal_menos_ruido = filtfilt(b, a, y(1, 1:10*fs));
switch opcao
    case 1
        plot(y(1,1:fs*10)); %sinal original
        title('Sinal Original');
    case 2
        plot(sinal_menos_ruido);
        title('Sinal com ruído reduzido');
end