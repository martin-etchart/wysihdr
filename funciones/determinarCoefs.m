function cn = determinarCoefs(M1,M2,R,N)
%DETERMINARCN Obtener coeficientes del polinomio I = f(M)
%   cn = determinarCn(M,R,N)
%  
%   Parámetros
%   M1 : Vector {Px(Q-1)} que contiene P píxeles muestrados en imagen q
%   M2 : Vector {Px(Q-1)} que contiene P píxeles muestrados en imagen q+1
%   R : Vector {(Q-1)x1} con los ratios de exposición en la imagen q y q+1.
%   N : Grado del polinomio I = f(M).

% Definiciones
[P,Q] = size(M1);      % Cantidad de píxeles e imágenes
Q = Q+1;

A = zeros(N,N);     % Espacio en memoria para A
b = zeros(N,1);     % Espacio en memoria para b
Imax = 1;

for q=1:Q-1
for p=1:P
    % Fijado p y q, aN es un factor multiplicativo fijo
    aN = (M1(p,q)^N - R(q)*M2(p,q)^N);
    for i=0:N-1
        % En la fila i de A
        ai = (M1(p,q)^i - R(q)*M2(p,q)^i);
        % Para cada entrada en la fila i de A
        an = (M1(p,q).^(0:N-1) - R(q)*M2(p,q).^(0:N-1));
        
        % Acumulo en la matriz
        A(i+1,:) = A(i+1,:) + (ai-aN)*(an-aN);
        % Acumulo en el vector
        b(i+1) = b(i+1) -Imax*aN*(ai-aN);
    end
end
end

% Solución por mínimos cuadrados (inestable)
% cn = A\b;
% cn(1) = max(cn(1),0);

% Solución de coeficientes no negativos.
cn = lsqnonneg(A,b);

% Se agrega último término
cn = [cn;Imax-sum(cn)];
end
