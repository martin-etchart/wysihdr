close all
clear all
clc

%% Generar imágenes sintéticas

% Parámetros
NombreDirectorio = '/home/roho/Dropbox/Timag-HDR/Programas/sinte/';
N = 4;     % Grado del polinomio
Q = 10;      % Cantidad de imágenes
P = 50;     % Pixeles a muestrear
Imax = 1;

m = 400;    % Heigth
n = 600;    % Width

% Ratios de exposición R = 0.5
R = 0.5*ones(Q-1,1);

% Radiancia aleatoria
% I = R(1)^(Q-1)*(rand(m,n));

% Radiancia constante
I = R(1)^(Q-1)*ones(m,n);

% % Radiancia degradé
% I = log(linspace(0,1,n)+1);
% I = repmat(I,m,1);

% Sorteo función de respuesta
cn = zeros(N+1,1);
cn(2) = 1;
% cn(1:N+1) = rand(N+1,1);    % Coefs positivos
% cn(2:2:N+1) = 0;            % Coef pares nulos para asegurar monotonia
% cn = (Imax/sum(cn))*cn;     % Normalizo respuesta


figure; imshow(I)
f = @(x) (x.^(0:N))*cn;
figure; fplot(f,[0 1]);

%% Genero imágenes sinteticas a partir de R, cn e I.

Imgs = zeros(m,n,Q);
for i=0:Q-1
    Imgs(:,:,i+1) = (1/R(1))^i.*I;
    for j=1:m
    for k=1:n
        Imgs(j,k,i+1) = Imgs(j,k,i+1).^(0:N)*cn ;
    end
    end
%     Imgs(:,:,i+1) = Imgs(:,:,i+1)./(max(max(Imgs(:,:,i+1))));
    Imgs(:,:,i+1) = Imgs(:,:,i+1)+sqrt(0.005)*randn(m,n);
    figure
    imshow(Imgs(:,:,i+1))
    imwrite(Imgs(:,:,i+1),strcat(NombreDirectorio,strcat(num2str(i),'.jpg')),'JPG')
end

