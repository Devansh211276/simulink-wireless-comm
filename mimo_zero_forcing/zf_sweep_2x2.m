function error = zf_sweep_2x2(N, snrdb)
%#codegen
% Original script calculation; N and snrdb are Constant block inputs.
snrlinear = 10.^(snrdb/10);
nsd = 1 ./ sqrt(snrlinear);
error = zeros(size(snrdb));
for j = 1:length(snrdb)
    x11 = randi(2,1,N)-1;
    x1 = 2*x11-1;
    x22 = randi(2,1,N)-1;
    x2 = 2*x22-1;
    X = [x1;x2];
    h11 = (1/sqrt(2))*complex(randn(1,N),randn(1,N));
    h22 = (1/sqrt(2))*complex(randn(1,N),randn(1,N));
    h12 = (1/sqrt(2))*complex(randn(1,N),randn(1,N));
    h21 = (1/sqrt(2))*complex(randn(1,N),randn(1,N));
    n1 = complex(randn(1,N),randn(1,N))/sqrt(2);
    n2 = complex(randn(1,N),randn(1,N))/sqrt(2);
    y1 = h11.*x1+h12.*x2+n1*nsd(j);
    y2 = h21.*x1+h22.*x2+n2*nsd(j);
    % Explicit complex allocation for MATLAB Function code generation.
    xest = complex(zeros(2,N));
    for i = 1:N
        H = [h11(i),h12(i);h21(i),h22(i)];
        xest(:,i) = H\[y1(i);y2(i)];
    end
    x_detected = 2*(real(xest)>0)-1;
    error(j) = sum(sum(X~=x_detected))/(2*N);
end
end
