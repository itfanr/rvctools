%IHARRIS		Harris corner detector
%
%	P = iharris
%	F = iharris(im)
%	F = iharris(im, P)
%	[F,rawC] = iharris(im, P)
%
%	The return value is a vector of structures, each with the elements:
%		F.x	x-coordinate of feature
%		F.y	y-coordinate of feature
%		F.Ix	the smoothed x-gradient at the point
%		F.Iy	the smoothed y-gradient at the point
%		F.Ixy	the smoothed xy-gradient at the point
%		F.c	corner strength at the point
%
% The corners are processed in order from strongest to weakest.  The function
% stops when:
%	- the corner strength drops below P.cmin
%	- the corner strenght drops below P.cMinThresh * strongest corner
%	- the list of corners is exhausted
%
% PARAMETERS:
%
% This function has a number of parameters which are combined into a single
% structure (default values shown):
%
%	P.k = 0.04;		Harris parameter
%	P.cmin = 0;		Minimum corner strength
%	P.cMinThresh = 0.01;	Minimum relative corner strength
%	P.deriv = [-1 0 1; -1 0 1; -1 0 1] / 3;
%	P.sigma = 1;		Standard dev. for the smoothing step
%	P.edgegap = 2;		Corners this close to the border are ignored
%	P.nfeat = Inf;		Maximum number of features to return
%	P.harris = 1;		1 for Harris, 0 for inverse Noble detector
%	P.tiling = 0;		if set to N, evaluate corners in NxN tiles
%	P.distance = 0;		minimum distance between features
%
% The default parameter setting can be obtained with a call of the form:
%		P = iharris
%
% Passing in P will override those elements provided.
%
% In order to have good spatial layout of features set for example:
%
%	P.nfeat = 20;
%	P.tiling = 3;
%
% which will place 20 features in each of 9 tiles that cover the image in
% a 3x3 pattern.
%
%
% REF:	"A combined corner and edge detector", C.G. Harris and M.J. Stephens
%	Proc. Fourth Alvey Vision Conf., Manchester, pp 147-151, 1988.
%
% SEE ALSO:	showcorners
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


%	pic 10/96
% $Header: /home/autom/pic/cvsroot/image-toolbox/iharris.m,v 1.4 2005/10/30 02:49:57 pic Exp $
% $Log: iharris.m,v $
% Revision 1.4  2005/10/30 02:49:57  pic
% Track other changes, better allocation of features across tiles.
%
% Revision 1.3  2004/12/03 07:45:18  pic
% Support for tiling, different gradient operators, parameter control.
%
%

function [F,RawC] = iharris(im, p)

	default.k = 0.04;
	default.cmin = 0;
	default.cMinThresh = 0.01;
	default.deriv = [-1 0 1; -1 0 1; -1 0 1] / 3;
	default.sigma = 1;
	default.edgegap = 2;
	default.nfeat = Inf;
	default.harris = 1;
	default.tiling = 0;
	default.distance = 0;

	if nargin == 0,
		F = default;
		return
	elseif nargin == 1,
		p = default;
	elseif nargin == 2,
		for field = fieldnames(p)',
			default = setfield(default, field{1}, getfield(p, field{1}));
		end
		p = default;
	end
	p


	%gp.deriv = [1 2 1; 2 4 2;1 2 1]/4;

	if ndims(im) == 3,
		R = double(im(:,:,1));
		G = double(im(:,:,2));
		B = double(im(:,:,3));
		Rx = conv2(R, p.deriv, 'same');
		Ry = conv2(R, p.deriv', 'same');
		Gx = conv2(G, p.deriv, 'same');
		Gy = conv2(G, p.deriv', 'same');
		Bx = conv2(B, p.deriv, 'same');
		By = conv2(B, p.deriv', 'same');

		% smooth them
		if p.sigma > 0,
			smooth = kgauss(round(p.sigma*2), p.sigma);
			Ix = conv2(Rx.^2+Gx.^2+Bx.^2, smooth, 'same');
			Iy = conv2(Ry.^2+Gy.^2+By.^2, smooth, 'same');
			Ixy = conv2(Rx.*Ry+Gx.*Gy+Bx.*By, smooth, 'same');
		else
			Ix = Rx.^2+Gx.^2+Bx.^2;
			Iy = Ry.^2+Gy.^2+By.^2;
			Ixy = Rx.*Ry+Gx.*Gy+Bx.*By;
		end
	else
		% compute horizontal and vertical gradients
		ix = conv2(im, p.deriv, 'same');
		iy = conv2(im, p.deriv', 'same');
		% smooth them
		if p.sigma > 0,
			smooth = kgauss(round(p.sigma*2), p.sigma);
			Ix = conv2(ix.*ix, smooth, 'same');
			Iy = conv2(iy.*iy, smooth, 'same');
			Ixy = conv2(ix.*iy, smooth, 'same');
		else
			smooth = eye(7,7);
			Ix = conv2(ix.*ix, smooth, 'same');
			Iy = conv2(iy.*iy, smooth, 'same');
			Ixy = conv2(ix.*iy, smooth, 'same');
		end
	end

	[nr,nc] = size(Ix);

	if p.harris,
		% computer cornerness
		rawc = (Ix .* Iy - Ixy.^2) - p.k * (Ix + Iy).^2;
	else
		rawc = (Ix .* Iy - Ixy.^2) ./ (Ix + Iy);
	end

	% compute maximum value around each pixel
	cmax = imorph(rawc, [1 1 1;1 0 1;1 1 1], 'max');

	% if pixel equals minimum, its a local minima, find index
	cindex = find(rawc > cmax);

	% remove those near edges
	[y, x] = ind2sub(size(rawc), cindex);
	e = p.edgegap;
	sel = (x>e) & (y>e) & (x < (nc-e)) & (y < (nr-e));
	cindex = cindex(sel);

	p.npix = nr*nc;
	if p.tiling == 0,
		F = build_flist(p.nfeat, rawc, cindex, p, Ix, Iy, Ixy);
	else
		F = [];
		[y, x] = ind2sub(size(rawc), cindex);
		p.npix = p.npix / p.tiling^2;

		% do tiling
		for ty=1:p.tiling,
			ymax = nr*ty/p.tiling;
			ymin = ymax - nr/p.tiling + 1;
			for tx=1:p.tiling,
				xmax = nc*tx/p.tiling;
				xmin = xmax - nc/p.tiling + 1;

				sel = (x>=xmin) & (y>=ymin) & (x <= xmax) & (y <= ymax);
				fprintf('tile (%d,%d): ', ty, tx);
				cindext = cindex(sel);

				FF = build_flist(p.nfeat, rawc, cindext, p, Ix, Iy, Ixy);
				F = [F FF];
			end
		end
	end

	if nargout == 2,
		Rawc = rawc;
	end
	if nargout == 0,
		idisp(im);
		markfeatures(F, 100);

	end

function f = build_flist(N, rawc, cindex, p, Ix, Iy, Ixy)

	fprintf('%d minima found (%.1f%%), ', length(cindex), ...
		length(cindex)/p.npix*100);
	N = min(length(cindex), N);

	% sort into descending order
	cval = rawc(cindex);		% extract corner values
	[csort,k] = sort(-cval);	% sort into descending order
	cindex = cindex(k);
	cmax = rawc( cindex(1) );

	f = [];
	count = 1;
	for i=1:length(cindex),
		K = cindex(i);
		c = rawc(K);
		if c < p.cmin,
			break;
		end
		if c/cmax < p.cMinThresh,
			fprintf('break after %d minimas\n', i);
			break;
		end

		[y, x] = ind2sub(size(rawc), K);

		if (i>1) & (p.distance > 0),
			d = sqrt( ([f.y]'-y).^2 + ([f.x]'-x).^2 );
			if min(d) < p.distance,
				continue;
			end
		end

		f(count).x = x;
		f(count).y = y;
		f(count).c = c;
		f(count).grad = [Ix(K); Iy(K); Ixy(K)];
		count = count + 1;
		if count > N,
			break;
		end
	end
	fprintf(' %d added\n', count-1);
