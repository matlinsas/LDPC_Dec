%generate random test matrix and input
R=8;
C=4;
D=8;

m=randi([-1 D],C,R);
v=randi([0 1],R*D,1);
f=repmat(zeros(D,D),C,R);

for i=1:C
    for j=1:R
        if m(i,j)~=-1
            f((i-1)*D+1:i*D,(j-1)*D+1:j*D) = circshift(eye(D),m(i,j),2);
        end
    end
end
s = f*v;

mtx = sprintf('8''d%.0f,', rot90(m',2));
mtx = mtx(1:end-1);
dec = sprintf('%.0f', flipud(v));
ss = sprintf('%.0f', flipud(s));
