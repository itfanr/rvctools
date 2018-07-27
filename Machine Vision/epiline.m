%EPILINE Draw epipolar lines
%
%	h = epiline(F, p)
%	h = epiline(F, p, ls)
%
% Draw epipolar lines in current figure based on points specified
% rowwise in p and on the fundamental matrix F.  Optionally specify
% the line style.
%
% The return argument is a vector of graphics handles for the lines.
%
% SEE ALSO:	fmatrix epidist
%
%	Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab


% Peter Corke 2005
% $Header: /home/autom/pic/cvsroot/image-toolbox/epiline.m,v 1.2 2005/10/23 11:10:07 pic Exp $
% $Log: epiline.m,v $
% Revision 1.2  2005/10/23 11:10:07  pic
% Added doco, linestyle argument, return graphics handles.
%
% $Header: /home/autom/pic/cvsroot/image-toolbox/epiline.m,v 1.2 2005/10/23 11:10:07 pic Exp $
% $Log: epiline.m,v $
% Revision 1.2  2005/10/23 11:10:07  pic
% Added doco, linestyle argument, return graphics handles.
%
% Revision 1.1.1.1  2002/05/26 10:50:20  pic
% initial import
%

function handles = epiline(F, p, ls)

	% get plot limits from current graph
	xlim = get(gca, 'XLim');
	xmin = xlim(1);
	xmax = xlim(2);

	if nargin < 3,
		ls = 'r';
	end
	h = [];
	% for all input points
	for i=1:numrows(p),
		l = F*[p(i,:) 1]';
		y = (-l(3) - l(1)*xlim) / l(2);
		hold on
		hh = plot(xlim, y, ls);
		h = [h; hh];
		hold off
	end

	if nargout > 0,
		handles = h;
	end
