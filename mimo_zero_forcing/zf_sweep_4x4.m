function error = zf_sweep_4x4(N, snrdb)
%#codegen
% Original script calculation; N and snrdb are Constant block inputs.
Nt = 4;
Nr = 4;
snrlinear = 10.^(snrdb/10);
nsd = 1 ./ sqrt(snrlinear);
error = zeros(size(snrdb));
for j = 1:length(snrdb)
    x11 = randi([0 1],Nt,N);
    X = 2*x11-1;
    H = (randn(Nr,Nt,N)+1j*randn(Nr,Nt,N))/sqrt(2);
    noise = (randn(Nr,N)+1j*randn(Nr,N))/sqrt(2);
    % Explicit complex allocation for MATLAB Function code generation.
    Y = complex(zeros(Nr,N));
    xest = complex(zeros(Nt,N));
    for i = 1:N
        Y(:,i) = H(:,:,i)*X(:,i)+noise(:,i)*nsd(j);
        xest(:,i) = H(:,:,i)\Y(:,i);
    end
    x_detected = 2*(real(xest)>0)-1;
    error(j) = sum(X(:)~=x_detected(:))/(Nt*N);
end
end
