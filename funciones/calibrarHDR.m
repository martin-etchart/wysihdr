function[cn,MSE,N,M1,M2,R] = calibrarHDR( ImNombres, N, NumPatches , SizePatches , R ,Q )
%CALIBRARHDR Calibrar respuesta radiometrica
%   [cn,MSE,N,M1,M2,R] = calibrarHDR( ImNombres, N, NumPatches ,
%   SizePatches , R ,Q )
%   Mediante fotos de una misma escena tomadas con diferentes exposiciones 
%   se calcúla la inversa de la función de respuesta radiométrica I = f(M) 
%   mediante el ajuste por un polinomio genérico.
%   
%   Parmámetros:
%   ImNombres: {Qx1} of Strings, conteniendo los Nombres de las imágenes.
%   N: Grado del polinomio
%   NumPatches: Número de patches por imágen para muestrear.
%   SizePatches: Tamaño de patches
%   R: Estimación inicial de los ratios de exposición.

Imax = 1;
%  Obtener Ratios
R = getRatios(ImNombres,R);

%  Obtener Muestras
display('--> Muestreando...')
[M1,M2] = getSamples(ImNombres,NumPatches,SizePatches);

display('--> Calibrando...')
% Cantidad de canales a calibrar
d = size(M1,3);
e = zeros(N+1,d);
% Iterar para encontrar N que da menor error
for j = 1:N
    %  Calibrar curva por canal
    for i=1:d
        c = determinarCoefs(M1(:,:,i),M2(:,:,i),R,j);
        e(j,i) = funcionError(c(1:end-1),M1(:,:,i),M2(:,:,i),R,NumPatches*SizePatches^2,Q,j,Imax);
    end
end

MSE = mean(e(1:end-1,:).^2,2);
[MSEmin,N] = min(MSE);


% Obtener cn final
cn = zeros(N+1,d);
for i=1:d
    cn(:,i) = determinarCoefs(M1(:,:,i),M2(:,:,i),R,N);
end

% MSE = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function R = getRatios(ImNombres,R) 

Q = length(ImNombres);

% Ratios
try
    for i=1:Q-1
        ImInfo1 = imfinfo(ImNombres(i).name);
        ImInfo2 = imfinfo(ImNombres(i+1).name);
        R(i) = ImInfo1.DigitalCamera.ExposureTime/...
               ImInfo2.DigitalCamera.ExposureTime;
    end
catch
    display('No se pudo leer tiempo de exposición en las imágenes.')
    display('Se utilzarán ratios definidos por usuario o por defecto.')
    if isempty(R)
        R = 0.5*ones(Q-1,1);    % Ratios por defecto
    end
end
end


