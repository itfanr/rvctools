%MARKFEATURES	Overlay corner features on image
%
%	markfeatures(xy)
%	markfeatures(xy, N)
%	markfeatures(xy, N, marker)
%	markfeatures(xy, N, marker, label)
%
%	Mark specified points in current image with a blue square 
%	xy can be an n x 2 matrix or a feature structure vector with 
%	elements x and y.
%
%	If N is specified it limits the number of points plotted.  If N = 0
%	then all points are plotted.
%
%	The third form allows the marker shape/color to be specified using
%	a standard plot() type string, eg. 'sb', or 'xw'.
%
%	Fourth form uses cell array label to control labelling of each
%	mark, label at font size label{1} and color label{2}.
%
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/markfeatures.m,v 1.2 2005/10/20 11:22:58 pic Exp $
% $Log: markfeatures.m,v $
% Revision 1.2  2005/10/20 11:22:58  pic
% Support .x and .y elements in structure array argument, extra arg to specify
% number of features to plot, can specify label color.
%
% Revision 1.1.1.1  2002/05/26 10:50:23  pic
% initial import
%


function markfeatures(p, N, marker, label)

	if isstruct(p),
		r = [p.y]';
		c = [p.x]';
	else
		r = p(:,2);
		c = p(:,1);
	end
	if nargin > 1,
		if N == 0,
			N = length(r);
		end
		r = r(1:N);
		c = c(1:N);
	end
	if nargin < 3,
		marker = 'sb';
	end
	hold on
	for i=1:length(r),
		plot(c(i), r(i), marker);
		if nargin == 4,
			text(c(i)+6, r(i)+1, num2str(i), ...
				'FontUnits', 'pixels', ...
				'FontSize', label{1}, ...
				'Color', label{2});

		end
	end
	hold off
