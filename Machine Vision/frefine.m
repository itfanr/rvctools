%FREFINE refine estimate of fundamental matrix
%
%	fr = frefine(F, uv1, uv2)
%
%  Return a refined estimate of fundamental matrix using non-linear
% optimization and enforcing the rank-2 constraint.
%
% SEE ALSO: fmatrix epiline epidist
%
%	Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/frefine.m,v 1.2 2005/10/23 10:02:18 pic Exp $
% $Log: frefine.m,v $
% Revision 1.2  2005/10/23 10:02:18  pic
% Added copyright line.
%
% Revision 1.1.1.1  2002/05/26 10:50:21  pic
% initial import
%

function fr = frefine(F, uv1, uv2)

	A = [];
	for i=1:numrows(uv1),
		a = [	uv1(i,1)*uv2(i,1)
			uv1(i,2)*uv2(i,1)
			uv2(i,1)
			uv1(i,1)*uv2(i,2)
			uv1(i,2)*uv2(i,2)
			uv2(i,2)
			uv1(i,1)
			uv1(i,2)
			1
		];
		A = [A; a'];
	end
	f = F';
	f = f(:);
	fprintf('Initial residual is %g\n', norm(A * f));
	fprintf('Initial determinant is %g\n', det(F));

	options = optimset('MaxFunEvals', 10000, ...
		'LevenbergMarquardt', 'on', ...
		'TolFun', 1e-16, ...
		'TolCon', 1e-16, ...
		'LargeScale', 'off' ...
		);
	fr = fmincon(@fun, f, [], [], [], [], [], [], ...
		@nlfun, options, A);
	fprintf('Final residual is %g\n', norm(A * fr));
	fr = reshape(fr, 3, 3)';
	det(fr)
	fprintf('Final determinant is %g\n', det(fr));
		
function e = fun(x, A)
	e = norm(A * x);

function [c,ceq] = nlfun(x, A)

	ceq = abs( det(reshape(x, 3, 3)) );
	c = [];
