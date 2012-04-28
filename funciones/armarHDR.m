function I = armarHDR(ImNombres , poli )
%I = armarHDR(ImNombres , poli )
%   Dadas las fotos y el polinomio respuesta generamos la imagen HDR.
%   imagenes es estructura, poli es un vector de los coefcientes del polinomio
%   de menor a mayor y R son las radianzas.

Q = length(ImNombres);
t = getTiempos(ImNombres);
N = length(poli)-1;

r = t./mean(t);

[m,n,d] = size(imread(ImNombres(1).name));

I = zeros(m,n,d);

d_poli = zeros(N,d);
% Por Canal
for i=1:d
	% Derivada del polinomio
	dx =  (1:N)';
	d_poli(:,i) = poli(2:N+1,i).*dx;
    
    % Ordenar Coeficientes
	d_poli(:,i) = flipud(d_poli(:,i));
	poli(:,i) = flipud(poli(:,i));
            
	% Reset Acumulador
	num =zeros(m,n);
	den =zeros(m,n);
                
    % Por Imagen
    for q=1:Q
        
        % M (en un canal)
        imagen.M = getCanalFoto(ImNombres,q,i);
        % f(M(q))
        imagen.f = polyval(poli(:,i),imagen.M);
        % I = f(M(q))/e
        imagen.I = imagen.f/r(q);
        % w = f/f'
        imagen.w = (imagen.f)./polyval(d_poli(:,i),imagen.M);
        imagen.w(isnan(imagen.w)) = 0;
        imagen.w(imagen.w<0) = 0;
        
        %numerador
        num = num + (1-(2*imagen.w-1).^12).*(imagen.I);
        %denominador
        den = den + (1-(2*imagen.w-1).^12);
        
    end
    I(:,:,i) = num./den;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function M = getCanalFoto(ImNombres,numFoto,numCanal)

M = im2double(imread(ImNombres(numFoto).name));
M = M(:,:,numCanal);
    
end

function t = getTiempos(ImNombres)

Q = length(ImNombres);
t = zeros(Q,1);

for q=1:Q
    fotoInfo = imfinfo(ImNombres(q).name);
    t(q) = fotoInfo.DigitalCamera.ExposureTime;
end
    
end