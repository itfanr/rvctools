%IMATCH Fast window matching
%
%	[xm,score] = imatch(IM1, IM2, x, y, w2, search)
%
%  Template in IM1 is centered at (x,y), find the best match in IM2 within 
% the region specified by search.  Matching window half-width is w2.
%
% search is the search bounds [xmin xmax ymin ymax] or 
% if a scalar it is [-s s -s s]
%
%  xm is [dx, dy, cc] which are the x- and y-offsets relative to (x, y) 
% and cc is the match (zero-mean normalized cross correlation) score for
% the best match in the search region.
%
% score is a matrix of matching score values of dimensions given by search
%
% Copyright (c) Peter Corke, 2001  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/imatch.m,v 1.1 2005/10/23 11:32:52 pic Exp $
% $Log: imatch.m,v $
% Revision 1.1  2005/10/23 11:32:52  pic
% Search for matching template in image region.
%

