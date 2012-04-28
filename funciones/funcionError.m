function e = funcionError(c,M1,M2,R,P,Q,N,Imax)

% OJO: c = c0 c1 c2 ... cN-1
e = 0;

for q=1:Q-1
for p=1:P
    an = M1(p,q).^(0:N-1)-R(q)*M2(p,q).^(0:N-1);
    aN = M1(p,q).^N-R(q)*M2(p,q).^N;
    
    e = e + ((an-aN)*c+Imax*aN)^2;
end
end