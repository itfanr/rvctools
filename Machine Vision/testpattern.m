%TESTPATTERN  create some standard test images
%
%	im = testpattern(type, w, args)
%
% Create a test pattern image of size w, where w is a 2 vector or scalar for
% a square image.
%
%	type		comment			optional args
%	-----------------------------------------------------------
%	rampx, rampy	ramp from 0 to 1	number of cycles
%	sinx, siny	sinusoid from -1 to 1	number of cycles
%	dots		binary dot pattern	pitch, diameter
%	squares		binary square pattern	pitch, side length
%	line		line			theta (rad), intercept	
%	
%
% With no output argument the testpattern in displayed using idisp
%
% SEE ALSO: idisp
%
% Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/testpattern.m,v 1.4 2005/10/23 11:33:30 pic Exp $
% $Log: testpattern.m,v $
% Revision 1.4  2005/10/23 11:33:30  pic
% Added copyright line.
%
% Revision 1.3  2005/10/20 11:21:45  pic
% Generate many different types of testpattern as specified.
%
% Revision 1.2  2003/09/30 18:52:09  pic
% First cut of unified testpattern generation function.
%
% Revision 1.1.1.1  2002/05/26 10:50:25  pic
% initial import
%

function Z = testpattern(type, w, varargin)

	z = zeros(w);
	switch type,
	case {'sinx'},
		if nargin > 2,
			ncycles = varargin{1};
		else
			ncycles = 1;
		end
		for i=1:numcols(z),
			z(:,i) = sin(i/numcols(z)*ncycles*2*pi);
		end
	case {'siny'},
		if nargin > 2,
			ncycles = varargin{1};
		else
			ncycles = 1;
		end
		for i=1:numcols(z),
			z(i,:) = sin(i/numcols(z)*ncycles*2*pi);
		end
	case {'rampx'},
		if nargin > 2,
			ncycles = varargin{1};
		else
			ncycles = 1;
		end
		for i=1:numcols(z),
			z(:,i) = mod(i/numcols(z)*ncycles,1);
		end
	case {'rampy'},
		if nargin > 2,
			ncycles = varargin{1};
		else
			ncycles = 1;
		end
		for i=1:numrows(z),
			z(i,:) = mod(i/numrows(z)*ncycles,1);
		end
	case {'line'},
		% args:
		%	angle intercept
		nr = numrows(z);
		nc = numcols(z);
		c = varargin{2};
		theta = varargin{1};

		if abs(tan(theta)) < 1,
			x = 1:nc;
			y = round(x*tan(theta) + c);
			
			s = find((y >= 1) & (y <= nr));

		else
			y = 1:nr;
			x = round((y-c)/tan(theta));
			
			s = find((x >= 1) & (x <= nc));

		end
		for k=s,	
			z(y(k),x(k)) = 1;
		end
	case {'squares'},
		% args:
		%	pitch diam 
		nr = numrows(z);
		nc = numcols(z);
		d = varargin{2};
		pitch = varargin{1};
		if d > (pitch/2),
			fprintf('warning: squares will overlap\n');
		end
		rad = floor(d/2);
		d = 2*rad;
		for r=pitch/2:pitch:(nr-pitch/2),
			for c=pitch/2:pitch:(nc-pitch/2),
				z(r-rad:r+rad,c-rad:c+rad) = ones(d+1);
			end
		end
	case {'dots'},
		% args:
		%	pitch diam 
		nr = numrows(z);
		nc = numcols(z);
		d = varargin{2};
		pitch = varargin{1};
		if d > (pitch/2),
			fprintf('warning: dots will overlap\n');
		end
		rad = floor(d/2);
		d = 2*rad;
		s = kcircle(d/2);
		for r=pitch/2:pitch:(nr-pitch/2),
			for c=pitch/2:pitch:(nc-pitch/2),
				z(r-rad:r+rad,c-rad:c+rad) = s;
			end
		end
		
	otherwise
		disp('Unknown pattern type')
		im = [];
	end

	if nargout == 0,
		idisp(z);
	else
		Z = z;
	end
