
%   Creating McEliece System with default parameters
mc_mdpc = mceliece();

%   Parameters
[k n] = mc_mdpc.get_params();

%   Generating random message-vector
m=randi(2,1,k)-1;
disp(sprintf('m = %s\n', dec2bin(m)'));

%   Message encryption
x = mc_mdpc.encrypt(m);
disp(sprintf('x = %s\n', dec2bin(x)'));

%   Message Decryption
y = mc_mdpc.decrypt(x);
disp(sprintf('y = %s\n', dec2bin(y)'));
