%INVHOMOG	invert (decompose) the image plane homography
%
%	s = invhomog(A)
%
%	where s is an array of structures with elements
%		R 3x3 rotation matrix
%		t 3x1 translation vector
%
%	corresponding to the 8 possible solutions.
%
%	s = invhomog(A, m)
%
%	if a point on the plane is given, m, then infeasible solutions will not
%	be returned.  In the general case this still leaves two solutions.
%
% SEE ALSO: homography
%
% Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% (c) Peter Corke 1999
% $Header: /home/autom/pic/cvsroot/image-toolbox/invhomog.m,v 1.3 2005/10/30 03:28:20 pic Exp $
% $Log: invhomog.m,v $
% Revision 1.3  2005/10/30 03:28:20  pic
% Doco tidyup
%
% Revision 1.2  2004/01/02 11:35:43  pic
% Add semicolon to reduce printing.
%
% Revision 1.1.1.1  2002/05/26 10:50:22  pic
% initial import
%


function sol = invhomog(A, m)
	[U,L,V] = svd(A);

	s = det(U)*det(V);

	Lv = diag(L);
	d1 = Lv(1); d2 = Lv(2); d3 = Lv(3);

	if ~isclose(d1,d2) & ~isclose(d2, d3),
		% we have unique singular values, 8 solutions

		%% first for dp > 0
		x1 = sqrt((d1^2-d2^2)/(d1^2-d3^2));
		x3 = sqrt((d2^2-d3^2)/(d1^2-d3^2));

		sth = sqrt((d1^2-d2^2)*(d2^2-d3^2))/(d1+d3)/d2;
		cth = (d2^2+d1*d3)/(d1+d3)/d2;

		% ++
		sol(1).R = [cth 0 -sth; 0 1 0; sth 0 cth];
		sol(1).t = (d1-d3)*[x1 0 -x3]';
		sol(1).n = [x1 0 x3]';
		sol(1).d = d2;

		% +-, sinth changes sign
		sol(2).R = [cth 0 sth; 0 1 0; -sth 0 cth];
		sol(2).t = (d1-d3)*[x1 0 x3]';
		sol(2).n = [x1 0 -x3]';
		sol(2).d = d2;

		% -+, sinth changes sign
		sol(3).R = [cth 0 sth; 0 1 0; -sth 0 cth];
		sol(3).t = (d1-d3)*[-x1 0 -x3]';
		sol(3).n = [-x1 0 x3]';
		sol(3).d = d2;

		% --
		sol(4).R = [cth 0 -sth; 0 1 0; sth 0 cth];
		sol(4).t = (d1-d3)*[-x1 0 x3]';
		sol(4).n = [-x1 0 -x3]';
		sol(4).d = d2;

		%% now for dp < 0
		sth = sqrt((d1^2-d2^2)*(d2^2-d3^2))/(d1-d3)/d2;
		cth = (d1*d3-d2^2)/(d1-d3)/d2;

		x1 = sqrt((d1^2-d2^2)/(d1^2-d3^2));
		x3 = sqrt((d2^2-d3^2)/(d1^2-d3^2));

		% ++
		sol(5).R = [cth 0 sth; 0 -1 0; sth 0 -cth];
		sol(5).t = (d1+d3)*[x1 0 x3]';
		sol(5).n = [x1 0 x3]';
		sol(5).d = -d2;

		% +-, sinth changes sign
		sol(6).R = [cth 0 -sth; 0 -1 0; -sth 0 -cth];
		sol(6).t = (d1+d3)*[x1 0 -x3]';
		sol(6).n = [x1 0 -x3]';
		sol(6).d = -d2;

		% -+, sinth changes sign
		sol(7).R = [cth 0 -sth; 0 -1 0; -sth 0 -cth];
		sol(7).t = (d1+d3)*[-x1 0 x3]';
		sol(7).n = [-x1 0 x3]';
		sol(7).d = -d2;

		% --
		sol(8).R = [cth 0 sth; 0 -1 0; sth 0 -cth];
		sol(8).t = (d1+d3)*[-x1 0 -x3]';
		sol(8).n = [-x1 0 -x3]';
		sol(8).d = -d2;

		% transform to original coordinate frame
		for i=1:8,
			sol(i).R = s*U*sol(i).R*V';
			sol(i).t = U*sol(i).t;
			sol(i).n = V*sol(i).n;
			sol(i).d = s*sol(i).d;
		end


		if nargin > 1,
			M = [m(:); 1];
			% we have a point on the plane, cull the solutions
			sol2 = [];
			for i=1:8,
				if A(3,1:3)*M/sol(i).d > 0,
					if sol(i).n'*M/sol(i).d > 0,
						sol2 = [sol2; sol(i)];
					end
				end
			end
			
			sol = sol2;	% return only the feasible solutions
		end
	elseif isclose(d1,d2) & isclose(d2,d3),
		% we have multiplicity 3, no solution
		disp('help, multiplicity 3, no solution')
		Lv

		sol(1).R = eye(3,3);
		sol(1).t = [0 0 0]';
		sol(1).n = [];
		sol(1).d = dp;
	else
		% 2 equal singular values, 4 solutions

		%% dp > 0
		sol(1).R = eye(3,3);
		sol(1).n = [0 0 1]';
		sol(1).t = (d3-d1)*sol(1).n;
		sol(1).d = d2;

		sol(2).R = eye(3,3);
		sol(2).n = [0 0 -1]';
		sol(2).t = (d3-d1)*sol(2).n;
		sol(2).d = d2;

		%% dp < 0
		sol(3).R = -eye(3,3);
		sol(3).n = [0 0 1]';
		sol(3).t = (d3+d1)*sol(3).n;
		sol(3).d = -d2;

		sol(4).R = -eye(3,3);
		sol(4).n = [0 0 -1]';
		sol(4).t = (d3+d1)*sol(4).n;
		sol(4).d = -d2;
	end

function c = isclose(x, y)

	tol = 1e-4;
	c = abs(x-y) < tol;
