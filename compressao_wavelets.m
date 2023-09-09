function [y,SNRdB] = compressao_wavelets(x,taxa,wavelet)
plot(x);
% taxa: taxa (%) de compressão

N = wmaxlev(length(x),wavelet);
[C,L] = wavedec(x,N,wavelet);

Ns = (1-taxa)*length(C); % quantidade de amostras mantidas

absC = abs(C);

C1 = zeros(1,length(C));

for k=1:Ns
    i_max = find(absC == max(absC),1,'first');
    C1(i_max) = C(i_max);
    absC(i_max) = 0;
end

y = waverec(C1,L,'db4');

dist = x-y;
E_dist = sum(dist.^2);

E_x = sum(x.^2);

SNR = E_x./E_dist;

SNRdB = 10*log10(SNR);
%disp(SNRdB);