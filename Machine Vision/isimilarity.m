%ISIMILARITY	Image similarity measure
%
%	m = isimilarity(im1, im2, c1, c2, w)
%
% return similarity of windows in IM1 and IM2.  Window centres are
% C1 and C2 and of side length 2W+1
% Uses the zero-mean normalized cross-correlation between the two
% equally sized image patches w1 and w2.  Result is in the range -1 to 1, with
% 1 indicating identical pixel patterns.
%
%
% SEE ALSO:	zncc
%
%	Copyright (c) Peter Corke, 2002  Machine Vision Toolbox for Matlab


% $Header: /home/autom/pic/cvsroot/image-toolbox/isimilarity.m,v 1.1 2005/10/30 03:26:51 pic Exp $
% $Log: isimilarity.m,v $
% Revision 1.1  2005/10/30 03:26:51  pic
% Find similar regions in image pair.
%
% Revision 1.1.1.1  2002/05/26 10:50:25  pic
% initial import
%

function m = isimilarity(im1, im2, c1, c2, w)

	[nr,nc] = size(im1);

	if (c1(1)+w>nc) | (c2(1)+w>nc) | (c1(1)-w<1) | (c2(1)-w<1) ...
		| (c1(2)+w>nr) | (c2(2)+w>nr) | (c1(2)-w<1) | (c2(2)-w<1),
			m = 0;
	else

		m = zncc(im1(c1(2)-w:c1(2)+w,c1(1)-w:c1(1)+w), ...
			im2(c2(2)-w:c2(2)+w,c2(1)-w:c2(1)+w));
	end
