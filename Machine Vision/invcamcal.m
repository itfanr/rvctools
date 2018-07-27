%INVCAMCAL	Inverse camera calibration
%
%	[Tcam, K, delta] = INVCAMCAL(C)
%
% 	Decompose, or invert, a camera calibration matrix C using the
%	method of Ganapathy, where
% 		C is a 3x4 camera calibration matrix
%		Tcam is the homog xform of the world origin wrt camera
%		K is a vector of estimated scale factors alphax*f, alphay*f
%		delta is an estimate of the `goodness' of the calibration matrix
%		       and is ideally 0.
%
% REF:	"Camera Location Determination Problem", Ganapathy,
%	Bell Labs Tech. Memo 11358-841102-20-TM, Nov 2 1984
%
% SEE ALSO: camcalp, camcald, camcalt, camera
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% Peter Corke 1993
% $Header: /home/autom/pic/cvsroot/image-toolbox/invcamcal.m,v 1.1 2002/05/26 10:50:22 pic Exp $
% $Log: invcamcal.m,v $
% Revision 1.1  2002/05/26 10:50:22  pic
% Initial revision
%


function [Tcam, K, uv0, delta] = invcamcal(T)
A = [T(1,1); T(1,2); T(1,3)];
B = [T(2,1); T(2,2); T(2,3)];
C = [T(3,1); T(3,2); T(3,3)];

% eq 4-12

rsq = 1 / dot(C, C);
r = sqrt(rsq);

% eq 4-13

u0 = rsq * dot(A,C);

% eq 4-14

v0 = rsq * dot(B,C);

uv0 = [u0; v0];

% eq 4-10

k1 = sqrt(rsq * dot(A,A) - u0^2 );
k2 = sqrt(rsq * dot(B,B) - v0^2 );

g = r * T(3,1);
h = r * T(3,2);
i = r * T(3,3);
a = (r*T(1,1) - u0*g)/k1;
b = (r*T(1,2) - u0*h)/k1;
c = (r*T(1,3) - u0*i)/k1;

d = (r*T(2,1) - v0*g)/k2;
e = (r*T(2,2) - v0*h)/k2;
f = (r*T(2,3) - v0*i)/k2;

dbar = h*c - b*i;
ebar = a*i - g*c;
fbar = g*b - a*h;

if abs(a*dbar + b*ebar + c*fbar) > 1e-10,
	disp('swapping sign of k2');
	k2 = - k2;
	d = -d;
	e = -e;
	f = -f;
end

p = r*(T(1,4) - u0) / k1;
q = r*(T(2,4) - v0) / k2;

x0 = -a*p - d*q - g*r;
y0 = -b*p - e*q - h*r;
z0 = -c*p - f*q - i*r;

delta = asin(a*d + b*e + c*f) * 180/pi;

% now we have the elements of the transform matrix  cam^T_0, the
% location of the world origin wrt the camera
%
R = [a b c;d e f; g h i];
P = [x0 y0 z0]';
Tcam = [R P; 0 0 0 1];
K = [k1; k2];
