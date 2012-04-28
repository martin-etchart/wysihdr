function [M1,M2] = getSamples(ImNombres,NumPatches,SizePatches)
%[M1,M2] = GETSAMPLES(IMNOMBRES,NumPatches,SizePatches)
%   Función que muestrea de las imágenes píxeles de forma controlada para
%   acelerar procesamiento y estabilizar resultados.
%
%   Parámetros:
%   ImNombres : Estructura con nombres de imágenes a muestrear ordenadas.
%   NumPatches: Número de patches por imágen para muestrear.
%   SizePatches: Tamaño de patches.

Q = length(ImNombres);
[m,n,d] = size(imread(ImNombres(1).name));

% Sorteo Ubicación de Patches iniciales
Ind = ceil([(rand(NumPatches,1))*(m-SizePatches) ...
            (rand(NumPatches,1))*(n-SizePatches)]);

% Espacio en memoria
M1 = zeros(NumPatches*SizePatches^2,Q-1,d);
M2 = zeros(NumPatches*SizePatches^2,Q-1,d);

q = Q;
while q>1            

    I2 = im2double(imread(ImNombres(q).name));      % Imagen q
    I1 = im2double(imread(ImNombres(q-1).name));    % Imagen q-1
    if d==3
    Y2 = 0.2126*I2(:,:,1) + 0.7152*I2(:,:,2) + 0.0722*I2(:,:,3);    % Luminancia q
    Y1 = 0.2126*I1(:,:,1) + 0.7152*I1(:,:,2) + 0.0722*I1(:,:,3);    % Luminancia q-1
    else
        Y2 = I2;
        Y1 = I1;
    end
    y1 = mean(mean(Y1));
    y2 = mean(mean(Y2));

    for i=1:NumPatches
        k = 1;  % Reset contador
        while 1
            ind = Ind(i,:); % Tomo ubicación anterior o sorteada
            p2 = Y2(ind(1):ind(1)+SizePatches-1,ind(2):ind(2)+SizePatches-1,:);
            p1 = Y1(ind(1):ind(1)+SizePatches-1,ind(2):ind(2)+SizePatches-1,:);
            if var(p2(:))<0.001 && var(p2(:))<0.001 && max(p2(:))<0.99 ... 
                    && min(p2(:))>max(p1(:)) || k>100 ...
                    && min(p2(:))> y2-3/Q && max(p2(:)) < (y2+3/Q) ...
                    && min(p1(:))> y1-3/Q && max(p1(:)) < (y1+3/Q)
                for j=1:d
                   m2 = I2(ind(1):ind(1)+SizePatches-1,ind(2):ind(2)+SizePatches-1,j);
                   m1 = I1(ind(1):ind(1)+SizePatches-1,ind(2):ind(2)+SizePatches-1,j);
                   M2((i-1)*SizePatches^2+1:i*SizePatches^2,q-1,j) = m2(:);
                   M1((i-1)*SizePatches^2+1:i*SizePatches^2,q-1,j) = m1(:);
                end
                break;
            else
                Ind(i,:) = ceil([rand*(m-SizePatches) rand*(n-SizePatches)]);   % Sorteo índices
                k = k+1;    % Aumento contador
            end
        end
    end
    q=q-1;
end

end