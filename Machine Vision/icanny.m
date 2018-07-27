%ICANNY	Edge detection.
%	E = canny(I) finds the edges in a gray scaled image I using the Canny
%	method, and returns an image E where the edges of I are marked by 
%	non-zero intensity values.
%
%	E = canny(I, SD) uses SD as the standard deviation for the gaussian 
%	filtering phase. Default is 1 pixel.
%
%	E = canny(I, SD, TH1) uses TH1 for the higher hysteresis threshold.
%	Default is 0.5 times the strongest edge. Setting TH1 to zero will 
%	avoid the (sometimes time consuming) hysteresis.
%
%	E = canny(I, SD, TH1, TH0) uses TH1 for the lower hysteresis threshold.
%	Default is 0.1 times the strongest edge.
%
%	See also EDGE (in the Image Processing toolbox).
%
%	Oded Comay, Feb 23, 1996 - Original version.
%	Tel Aviv University
%
%	Oded Comay, Feb 27, 1997 - Hysteresis added.

% $Header: /home/autom/pic/cvsroot/image-toolbox/icanny.m,v 1.1 2005/10/30 03:25:46 pic Exp $
% $Log: icanny.m,v $
% Revision 1.1  2005/10/30 03:25:46  pic
% Canny edge operator.
%
%

function E = icanny(I, sd, th1, th0);

if nargin<2 sd=   1; end; if isempty(sd),  sd=   1; end;
if nargin<3 th1= .5; end; if isempty(th1), th1= .5; end;
if nargin<4 th0= .1; end; if isempty(th0), th0= .1; end;

x= -5*sd:sd*5; 
g= exp(-0.5/sd^2*x.^2); 		% Create a normalized Gaussian
g= g(g>max(g)*.005); g= g/sum(g(:));
dg= diff(g);				% Gaussian first derivative

dx= abs(conv2(I, dg, 'same'));		% X/Y edges
dy= abs(conv2(I, dg', 'same'));

[ny, nx]= size(I);
					% Find maxima 
dy0= [dy(2:ny,:); dy(ny,:)]; dy2= [dy(1,:); dy(1:ny-1,:)];
dx0= [dx(:, 2:nx) dx(:,nx)]; dx2= [dx(:,1) dx(:,1:nx-1)];
peaks= find((dy>dy0 & dy>dy2) | (dx>dx0 & dx>dx2));
e= zeros(size(I));
e(peaks)= sqrt(dx(peaks).^2 + dy(peaks).^2); 

e(:,2)   = zeros(ny,1);    e(2,:)= zeros(1,nx);	% Remove artificial edges
e(:,nx-2)= zeros(ny,1); e(ny-2,:)= zeros(1,nx);
e(:,1)   = zeros(ny,1);    e(1,:)= zeros(1,nx);
e(:,nx)  = zeros(ny,1);   e(ny,:)= zeros(1,nx);
e(:,nx-1)= zeros(ny,1); e(ny-1,:)= zeros(1,nx);
e= e/max(e(:));

if th1 == 0, E= e; return; end			 % Perform hysteresis
E(ny,nx)= 0;

p= find(e >= th1);
while length(p) 
  E(p)= e(p);
  e(p)= zeros(size(p));
  n= [p+1 p-1 p+ny p-ny p-ny-1 p-ny+1 p+ny-1 p+ny+1]; % direct neighbors
  On= zeros(ny,nx); On(n)= n;
  p= find(e > th0 & On);
end
