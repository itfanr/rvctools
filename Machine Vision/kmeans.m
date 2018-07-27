%KMEANS	K-means clustering
%
%	[c, s] = kmeans(x,k)
%	[c, s] = kmeans(x,k, x0)
%
%	K-means clustering for data, x.  k is the number of
%	clusters, and x0 if given is the inital centroid for the clusters.
%	x can be 1- or multi-dimensional.
%
%	On return c[i] is the centroid of the i'th cluster.  s is a vector 
%	of length equal to x, whose value indicates which cluster the 
%	corresponding element of x belongs to.
%
% REF: Tou and Gonzalez, Pattern Recognition Principles, pp 94
%
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

%		pic 7/92
% $Header: /home/autom/pic/cvsroot/image-toolbox/kmeans.m,v 1.2 2005/10/20 11:25:37 pic Exp $
% $Log: kmeans.m,v $
% Revision 1.2  2005/10/20 11:25:37  pic
% Vectorize  step 2, much faster.  Minor doco changes.
%
% Revision 1.1.1.1  2002/05/26 10:50:23  pic
% initial import
%

%
function [c,s] = kmeans(X, K, z)
	deb = 0;

	if ndims(X) > 1,
		x = X(:);
	else
		x = X;
	end
	if nargin == 2,
		%
		% if no initial clusters are given spread the
		% centers evenly over the range min to max.
		%
		z = [0:K-1]/(K-1)*(max(x)-min(x)) + min(x);
	end
	if length(z) ~= K,
		error('initial cluster length should be k')
	end

	%
	% step 1
	%
	zp = z;
	s = zeros(size(x));
	n = length(x);

	iterating = 1;
	k = 1;
	iter = 0;
	while iterating,
		iter = iter + 1;

		%
		% step 2
		%
		for l=1:K,
			y(:,l) = abs(x - z(l));
			[zz,ind] = min(y');
			s = ind';	% assign index of closest set
		end
			
		%
		% step 3
		%
		for j=1:K
			zp(j) = mean( x(s==j) );
		end

		%
		% step 4
		%
		nm = norm(z - zp);
		if deb>0,
			nm
		end
		if nm == 0,
			iterating = 0;
		end
		z = zp;
		if deb>0,
			plot(z);
			pause(.1);
		end
	end
	if deb>0,
		disp('iterations ');
		disp(iter);
	end
	c = z;

	if nargout > 1,
		if ndims(X) > 1,
			s = reshape(s, size(X));
		end
	end
