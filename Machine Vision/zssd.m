% $Header: /home/autom/pic/cvsroot/image-toolbox/zssd.m,v 1.1.1.1 2002/05/26 10:50:25 pic Exp $
% $Log: zssd.m,v $
% Revision 1.1.1.1  2002/05/26 10:50:25  pic
% initial import
%

function m = zssd(w1, w2)

	w1 = w1 - mean(w1(:));
	w2 = w2 - mean(w2(:));

	m = (w1-w2).^2;
	
	m = sqrt(sum(m(:)) / prod(size(w1)));
