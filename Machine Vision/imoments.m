%IMOMENTS	Compute image moments
%
%	F = imoments(image)
%
%	F = imoments(rows, cols)
%	F = imoments(rows, cols, w)
%
%	The first form computes the grey-scale moments of the image (non-zero 
%	elements) image.  The actual pixel values are used as pixel weights.
%	The return vector is a structs
%		F.area     is the number of pixels (for a binary image)
%		F.x        (x, y) is the centroid with respect 
%		F.y           to top-left point which is (1,1)
%		F.a        (a, b) are axis lengths of the "equivalent 
%		F.b           ellipse"
%		F.theta    the angle of the major ellipse axis to the 
%		                horizontal axis.
%
%	The raw moments are also returned:
%		F.m00
%		F.m10
%		F.m01
%		F.m20
%		F.m02
%		F.m11
%
%	The second form is used when the coordinates of the non-zero elements 
%	are known and V is a vector of the same length containing the weights
%	for pixel values.
%
% NOTE:	this function does not perform connectivity, if connected blobs
%	are required then the ILABEL function must be used first.
%
% SEE ALSO: ilabel
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% 1996 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/imoments.m,v 1.3 2005/10/30 02:24:27 pic Exp $
% $Log: imoments.m,v $
% Revision 1.3  2005/10/30 02:24:27  pic
% Merge fixup.
%
% Revision 1.2  2005/07/03 10:58:24  pic
% Deal gracefully with regions of zero area.
%
% Revision 1.1.1.1  2002/05/26 10:50:22  pic
% initial import
%


function F = imoments(a1, a2, a3)
	if nargin == 1,
		[i,j] = find(a1);
		w = a1(find(a1 > 0));
	else
		i = a1;
		j = a2;
		if nargin == 3,
			w = a3;
		else
			w = ones(size(i));
		end
	end

	% compute basic moments
	m00 = sum(w);
	m10 = sum(j.*w);
	m01 = sum(i.*w);
	m20 = sum((j.^2).*w);
	m02 = sum((i.^2).*w);
	m11 = sum((i.*j).*w);

	if m00 > 0,
		% figure some central moments
		u20 = m20 - m10^2/m00;
		u02 = m02 - m01^2/m00;
		u11 = m11 - m10*m01/m00;

		% figure the equivalent axis lengths, function of the principal axis lengths
		e = eig([u20 u11; u11 u02]);
		a = 2*sqrt(max(e)/m00);
		b = 2*sqrt(min(e)/m00);
		th = 0.5*atan2(2*u11, u20-u02);
	else
		u20 = NaN;
		u02 = NaN;
		u11 = NaN;

		a = NaN;
		b = NaN;
		th = NaN;
	end

	%F = [m00 m10/m00 m01/m00 a b th];
	F.area = m00;
	if m00 > 0,
		F.x = m10/m00;
		F.y = m01/m00;
	else
		F.x = NaN;
		F.y = NaN;
	end
	F.a = a;
	F.b = b;
	F.theta = th;
	F.m00 = m00;
	F.m01 = m01;
	F.m10 = m10;
	F.m02 = m02;
	F.m20 = m20;
	F.m11 = m11;
