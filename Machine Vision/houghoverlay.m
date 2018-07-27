%HOUGHOVERLAY	Overlay lines on image.
%
%	houghoverlay(p)
%	houghoverlay(p, ls)
%	handles = houghoverlay(p, ls)
%
%	Overlay lines, one per row of p, onto the current figure.  The row
%	is interpretted as offset and theta, the Hough transform line
%	representation.
%
%	The optional argument, ls, gives the line style in normal Matlab
%	format.
%
% SEE ALSO: ihough


%	Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab

% 2005 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/houghoverlay.m,v 1.1 2005/10/23 11:28:50 pic Exp $
% $Log: houghoverlay.m,v $
% Revision 1.1  2005/10/23 11:28:50  pic
% Suite of functions of displaying and processing Hough objects.
%

function handles = houghoverlay(p, ls)

	hold_status = ishold;
	hold on

	if nargin < 2,
		ls = 'b';
	end
	
	% figure the x-axis scaling
	scale = axis;
	x = [scale(1):scale(2)]';
	y = [scale(3):scale(4)]';

	% p = [d theta]

	% plot it
	for i=1:numrows(p),
		d = p(i,1);
		theta = p(i,2);

		fprintf('theta = %f, d = %f\n', theta, d);
		if abs(cos(theta)) > 0.5,
			% horizontalish lines
			hl(i) = plot(x, -x*tan(theta) + d/cos(theta), ls);
		else
			% verticalish lines
			hl(i) = plot( -y/tan(theta) + d/sin(theta), y, ls);
		end
	end

	if hold_status,
		hold on
	else
		hold off
	end

	if nargout > 0,
		handles = hl;
	end
