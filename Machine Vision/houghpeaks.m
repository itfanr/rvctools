%HOUGHPEAKS   Find Hough accumulator peaks.
%
%	p = houghpeaks(H, N, hp)
%
%  Returns the coordinates of N peaks from the Hough
%  accumulator.  The highest peak is found, refined to subpixel precision,
%  then hp.radius radius around that point is zeroed so as to eliminate
%  multiple close minima.  The process is repeated for all N peaks.
%  p is an n x 3 matrix where each row is the offset, theta and
%  relative peak strength (range 0 to 1).
%
%  The peak detection loop breaks early if the remaining peak has a relative 
%  strength less than hp.houghThresh.
%  The peak is refined by a weighted mean over a w x w region around
%  the peak where w = hp.interpWidth.
%
% Parameters affecting operation are:
%
%	hp.houghThresh	threshold on relative peak strength (default 0.4)
%	hp.radius       radius of accumulator cells cleared around peak 
%                                 (default 5)
%	hp.interpWidth  width of region used for peak interpolation
%                                 (default 5)
%
% SEE ALSO: ihough


%	Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab

% 2005 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/houghpeaks.m,v 1.1 2005/10/23 11:28:50 pic Exp $
% $Log: houghpeaks.m,v $
% Revision 1.1  2005/10/23 11:28:50  pic
% Suite of functions of displaying and processing Hough objects.
%

function p = houghpeaks(H, N, params)
		% for houghpeaks
		%default.houghThresh = 0.40;
		%default.radius = 5;
		%default.interpWidth = 5;

	if nargin < 3,
		params.houghThresh = 0.40;
		params.radius = 5;
		params.interpWidth = 5;
	end
	if nargin < 2,
		N = 5;
	end

	nr = numrows(H.h);
	nc = numcols(H.h);
	[x,y] = meshgrid(1:nr, 1:nc);

	nw2= floor((params.interpWidth-1)/2);
	[Wx,Wy] = meshgrid(-nw2:nw2,-nw2:nw2);
	globalMax = max(max(H.h));
	for i=1:N,
		% find the current peak
		[mx,where] = max(H.h(:));
		if mx < (globalMax*params.houghThresh),
			break;
		end
		[r,c] = ind2sub(size(H.h), where);
		% refine the peak to subelement accuracy
		try,
			Wh = H.h(r-nw2:r+nw2,c-nw2:c+nw2);
			rr = (Wy+r) .* Wh;
			cc = (Wx+c) .* Wh;
			r = sum(sum(rr))/sum(Wh(:));
			c = sum(sum(cc))/sum(Wh(:));
			%fprintf('refined %f %f\n', r, c);
		catch,
			%fprintf('window at edge\n');
			%[r c]
		end
		% interpolate the line parameter values
		d = interp1(H.d, r);
		theta = interp1(H.theta, c);
		p(i,:) = [d theta mx/globalMax];

		r = round(r);
		c = round(c);

		% remove the region around the peak
		k = (x(:)-c).^2 + (y(:)-r).^2 < params.radius^2;
		H.h(k) = 0;
	end
