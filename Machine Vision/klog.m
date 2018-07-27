%KLOG	Laplacian of Gaussian kernel
%
%	k = klog(w, sigma)
%
%	Return a Laplacian of Gaussian (LOG) kernel of width (2w+1) with
%	the specified sigma.
%
% SEE ALSO:	zcross
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% Peter Corke 1996
% $Header: /home/autom/pic/cvsroot/image-toolbox/klog.m,v 1.1 2005/10/23 11:29:41 pic Exp $
% $Log: klog.m,v $
% Revision 1.1  2005/10/23 11:29:41  pic
% Laplacian kernel.
%
% Revision 1.1.1.1  2002/05/26 10:50:22  pic
% initial import
%


function il = klog(sigma, w)

	if nargin == 1,
		w = 2*sigma;
	end

	[x,y] = meshgrid(-w:w, -w:w);

	il = -1/(2*pi*sigma^4) * (2 - (x.^2 + y.^2)/sigma^2) .*  ...
		exp(-(x.^2+y.^2)/(2*sigma^2));
