%CCDRESPONSE	CCD spectral response
%
% 	r = CCDRESPONSE(lam)
%
%  	Return a vector of CCD response (0-1) for given lambda value.  
%	Lambda may be a vector.
%
% REF:  Data taken from a Fairchild data book (no IR filter fitted)
%
% SEE ALSO:	rluminos
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/ccdresponse.m,v 1.1 2002/05/26 10:50:20 pic Exp $
% $Log: ccdresponse.m,v $
% Revision 1.1  2002/05/26 10:50:20  pic
% Initial revision
%


function cc = ccdresponse(lam)
	tab = [300 0
	350 0
	400 5
	500 30
	600 60
	700 85
	800 100
	900 85
	1000 50
	];
	cc = spline(tab(:,1)*1e-9,tab(:,2),lam)/100;
