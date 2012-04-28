%% Main

close all; clear all; clc;

%%  Parámetros por defecto


NombreDirectorio = input('Escribir dirección absoluta a la carpeta con imágenes: ');
N = 5;  % Grado del polinomio
NumPatches = 50; % Pixeles a muestrear
SizePatches = 4;
R = []; % Ratios definidos por usuario
cn = [];

%%  Obtener Nombres y propiedades

addpath(NombreDirectorio);
ImNombres = dir(strcat((NombreDirectorio),'/*.jpg'));
Q = length(ImNombres);  % Cantidad de imágenes
if Q<2
	ImNombres = dir(strcat((NombreDirectorio),'/*.JPG'));
	Q = length(ImNombres);  % Cantidad de imágenes
	if Q<2    	
	error('No hay suficientes imágenes en el directorio')
	else
	    [m,n,d] = size(imread(ImNombres(1).name));		
	end	
else
    [m,n,d] = size(imread(ImNombres(1).name));
end


%%  MENU
while 1
    choice = menu('WYSiHDR | Imagen HDR mediante múltiples exposiciones',...
                  'Ingresar parámetros',...
                  'Calibrar respuesta radiométrica',...
                   'Fusion a HDR',...
                   'Guardar HDR',...
                   'Salir');
    switch choice
        case 1
%% Ingresar parámetros

choice4 = menu('WYSiHDR | Parámetros',...
                'Nombre del directorio con imágenes',...
                'Grado máximo del polinomio',...
                'Patches de muestreo',...
                'Volver');

switch choice4
    case 1
        NombreDirectorio = input('Ingrese camino absoluto al directorio con imágenes:');
    case 2
        N = input('Ingrese grado máximo del polinomio (5): ');
    case 3
        NumPatches = input('Ingrese cantidad de patches (50): ');
        SizePatches = input('Ingrese tamaño de de patches (5): ');
    otherwise
end

        case 2
%% Calibrar Curvas de respues Radiometrica

display('Calibrando curvas...')
[cn,MSE,N,M1,M2,R] = calibrarHDR(ImNombres,N,NumPatches,SizePatches,R,Q);
display('Finalizado.')

figure
f = @(x) (x.^(0:N))*cn(:,1);
fplot(f,[0 1],'r');
hold on
if d==3
    f = @(x) (x.^(0:N))*cn(:,2);
    fplot(f,[0 1],'g');
    hold on
    f = @(x) (x.^(0:N))*cn(:,3);
    fplot(f,[0 1],'b');
end
title('Curvas de respuesta radiométrica'); ylabel('I = f(M)'); xlabel('M');
hold off


subchoice = menu('WYSiHDR | Calibrar curvas de respuesta radiométrica',...
                 'Guardar coeficientes de la curva',...
                 'Volver');
switch subchoice
    case 1 
        save('Coeficientes.mat','cn');
        display('Archivo guardado.')
        display(pwd)
        disp('Coeficientes.mat')
end

% %  Mostrar Curvas
% figure; plot(M1(:,:,1),M2(:,:,1),'*')
% ylabel('M(p,q+1)'); xlabel('M(p,q)')
% figure; plot(M1(:,:,2),M2(:,:,2),'*')
% ylabel('M(p,q+1)'); xlabel('M(p,q)')
% figure; plot(M1(:,:,3),M2(:,:,3),'*')
% ylabel('M(p,q+1)'); xlabel('M(p,q)')

% %  Mostrar Curvas
% c = flipud(cn);
% figure; plot(polyval(c(:,1),M2(:,:,1)),polyval(c(:,1),M1(:,:,1)),'+');
% hold on; fplot(@(x) x/2,[0 1])
% figure; plot(polyval(c(:,2),M2(:,:,2)),polyval(c(:,2),M1(:,:,2)),'+');
% hold on; fplot(@(x) x/2,[0 1])
% figure; plot(polyval(c(:,3),M2(:,:,3)),polyval(c(:,3),M1(:,:,3)),'+');
% hold on; fplot(@(x) x/2,[0 1])


        case 3
%% Fusionar HDR

display('Fusionando HDR...')
imHDR = armarHDR(ImNombres, cn);
display('Finalizado.')

% Mostrar HDR
figure; imshow(imHDR)

% Guardar
choice3 = menu('WYSiHDR | Fusiónar HDR',...
                'Guardar HDR',...
                'Volver');
switch choice3
    case 1    
        nombre = input('Nombre del archivo: ','s');
        nombre = strcat(nombre,'.hdr');
        imHDR(isnan(imHDR)) = 0;
        hdrwrite(imHDR,nombre);
        display('Archivo guardado.')
        display(pwd)
        disp(nombre)
end


% imHDRtuned(:,:,1) = histeq(imHDR(:,:,1));
% imHDRtuned(:,:,2) = histeq(imHDR(:,:,2));
% imHDRtuned(:,:,3) = histeq(imHDR(:,:,3));
% 
% % 
% figure;
% imshow(imHDRtuned-0.5);
% % % 
% r = imHDR(:,:,1); %./max(max(imHDR(:,:,1)));
% g = imHDR(:,:,2); %./max(max(imHDR(:,:,2)));
% b = imHDR(:,:,3); %./max(max(imHDR(:,:,3)));
% figure
% subplot(311); hist(r(:),1000);
% subplot(312); hist(g(:),1000);
% subplot(313); hist(b(:),1000);


        otherwise
            break;
    end
end

