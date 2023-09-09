function [y,SNRdB] = compressao_dct(x,taxa)

% taxa: taxa (%) de compressão

X = dct(x);

Ns = (1-taxa)*length(X); % quantidade de amostras mantidas

absX = abs(X);

X1 = zeros(1,length(X));

for k=1:Ns
    i_max = find(absX == max(absX),1,'first');
    X1(i_max) = X(i_max);
    absX(i_max) = 0;
end

y = idct(X1);

dist = x-y;
E_dist = sum(dist.^2);

E_x = sum(x.^2);

SNR = E_x./E_dist;

SNRdB = 10*log10(SNR);