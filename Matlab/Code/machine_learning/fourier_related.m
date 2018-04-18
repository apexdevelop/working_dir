m = 4;
n = 2^m -1;
x = gf(randi([0 2^m-1],n,1),m); % Random vector
y = fft(x); %Transfrom of x
z = ifft(y); % Inverse transform of y
ck = isequal(z,x); % Checks that ifft(fft(x)) recovers x.