%IBLOBS	Compute blob features
%
%	F = iblobs(image)
%	F = iblobs(image, args)
%
%	Arguments are provided pairwise with a string followed by a value:
%
%		'aspect'	set pixel aspect ratio, default 1.0
%		'connect'	set connectivity, 4 (default) or 8
%		'greyscale'	compute greyscale moments 0 (default) or 1
%
%	and some arguments act as filters on the blob's whose features will
%	be returned:
%
%		'area', [min max] acceptable size range
%		'shape', [min max] acceptable shape range
%		'touch'		ignore blobs that touch the edge
%
%	The return is a vector of structures with elements:
%
%		area	 is the number of pixels (for a binary image)
%		(x, y)   is the centroid with respect to top-left point which
%			 is (1,1)
%		(a, b)   are axis lengths of the "equivalent ellipse"
%		theta    the angle of the major ellipse axis to the 
%		         horizontal axis.
%		m00		zeroth moment
%		m01, m10	first order moments
%		m02, m11, m20	second order moments
%		shape	 shape factor, b/a
%		minx
%		maxx
%		miny
%		maxy
%
% SEE ALSO: ilabel imoments
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% 1996 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/iblobs.m,v 1.4 2005/10/30 02:36:13 pic Exp $
% $Log: iblobs.m,v $
% Revision 1.4  2005/10/30 02:36:13  pic
% Added option for greyscale moments, binary by default.
%
% Revision 1.3  2005/07/03 10:46:08  pic
% Minor tidyup including doco.  Add support for 4/8 way connectivity.
%
% Revision 1.2  2004/12/03 07:28:58  pic
% Fix bug for single pixel regions.
%
% Revision 1.1.1.1  2002/05/26 10:50:21  pic
% initial import
%


function F = iblobs(im, varargin)
	
	[nr,nc] = size(im);


	i = 1;
	area_max = Inf;
	area_min = 0;
	shape_max = Inf;
	shape_min = 0;
	touch = NaN;
	aspect = 1.0;
	connect = 4;
	greyscale = 0;

	while i <= length(varargin),
		%disp(varargin{i})
		switch varargin{i},
		case 'area',	area_filt = varargin{i+1};
				area_max = area_filt(2);
				area_min = area_filt(1);
				i = i+1;
		case 'shape',	shape_filt = varargin{i+1};
				shape_max = shape_filt(2);
				shape_min = shape_filt(1);
				i = i+1;
		case 'touch', 	touch = varargin{i+1}; i = i+1;
		case 'aspect', 	aspect = varargin{i+1}; i = i+1;
		case 'connect',	connect = varargin{i+1}; i = i+1;
		case 'greyscale',	greyscale = varargin{i+1}; i = i+1;
		end
		i = i+ 1;
	end

	[li,nl] = ilabel(im, connect);

	count = 0;
	for i=1:nl,
		binimage = (li == i);

		% determine the blob extent and touch status
		[y,x] = find(binimage);

		minx = min(x); maxx = max(x);
		miny = min(y); maxy = max(y);
		t = (minx == 1) | (miny == 1) | (maxx == nc) | (maxy == nr);

		if greyscale,
			% compute greyscale moments
			mf = imoments(binimage .* im);
		else
			mf = imoments(binimage);
		end
		if mf. a == 0,
			shape = NaN;
		else
			shape = mf.b / mf.a;
		end

		% apply various filters
		if 	((t == touch) | isnan(touch)) & ...
			(mf.area >= area_min) & ...
			(mf.area <= area_max) & ...
			(					...
				isnan(shape) |			...
				(	~isnan(shape) &		...
					(shape >= shape_min) &	...
					(shape <= shape_max)	...
				)				...
			),

			ff = mf;
			ff.minx = minx;
			ff.maxx = maxx;
			ff.miny = miny;
			ff.maxy = maxy;
			ff.touch = t;
			ff.shape = shape;
			count = count+1;
			F(count) = ff;
		end
	end
	fprintf('%d blobs in image, %d after filtering\n', nl, count);
