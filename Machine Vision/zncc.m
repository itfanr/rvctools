%ZNCC  Normalized cross correlation
%
%	m = zncc(w1, w2)
%
% Compute the zero-mean normalized cross-correlation between the two
% equally sized image patches w1 and w2.  Result is in the range -1 to 1, with
% 1 indicating identical pixel patterns.
%
% SEE ALSO:	isimilarity
%
%	Copyright (c) Peter Corke, 2002  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/zncc.m,v 1.2 2005/10/23 11:08:21 pic Exp $
% $Log: zncc.m,v $
% Revision 1.2  2005/10/23 11:08:21  pic
% Added doco.
%
% Revision 1.1.1.1  2002/05/26 10:50:25  pic
% initial import
%

function m = zncc(w1, w2)

	w1 = w1 - mean(w1(:));
	w2 = w2 - mean(w2(:));

	denom = sqrt( sum(sum(w1.^2))*sum(sum(w2.^2)) );

	if denom < 1e-10,
		m = 0;
	else
		m = sum(sum((w1.*w2))) / denom;
	end
