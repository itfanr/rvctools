%ISOBEL	Sobel edge detector
%
%	is = isobel(image)
%	is = isobel(image, Dx)
%	[ih,iv] = isobel(image)
%	[ih,iv] = isobel(image, Dx)
%
%	Applies the Sobel edge detector, which is the norm of the vertical
%	and horizontal gradients.  Tends to produce rather thick edges.
%	Returns either the magnitude image or horizontal and vertical 
%	components.
%
%	If Dx is specified this x-derivative kernel is used instead
%	of the default:
%			-1  0  1
%			-2  0  2
%			-1  0  1
%
%	The resulting image is the same size as the input image.
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/isobel.m,v 1.2 2005/10/20 11:17:13 pic Exp $
% $Log: isobel.m,v $
% Revision 1.2  2005/10/20 11:17:13  pic
% Doco tidyup, allow kernel to be passed in.
%
% Revision 1.1.1.1  2002/05/26 10:50:23  pic
% initial import
%


function [o1,o2] = isobel(i, Dx)

	if nargin < 2,
		sv = -[	-1 -2 -1
			0 0 0
			1 2 1];
		sh = sv';
	else
		% use a smoothing kernel if sigma specified
		sh = Dx;
		sv = Dx';
	end

	ih = conv2(i, sh, 'same');
	iv = conv2(i, sv, 'same');

	% return grandient components or magnitude
	if nargout == 1,
		o1 = sqrt(ih.^2 + iv.^2);
	else
		o1 = ih;
		o2 = iv;
	end
