
%
% various linear equation solvers used by fmatrix and homography
%

% $Header: /home/autom/pic/cvsroot/image-toolbox/homog_solve.m,v 1.2 2005/10/23 11:12:44 pic Exp $
% $Log: homog_solve.m,v $
% Revision 1.2  2005/10/23 11:12:44  pic
% Change header so not added to contents.m file.
%
% Revision 1.1.1.1  2002/05/26 10:50:21  pic
% initial import
%

function x = homog_solve(how, A, b)

	switch how,
	case 'eigsol',
		x = eigsol(A);
	case 'lsqsvd',
		x = lsqsvd(A, b);
	case 'psinvsol',
		x = psinvsol(A,b);
	case 'psinvsvd',
		x = psinvsvd(A,b);
	otherwise,
		error('bad method');
	end

function x = eigsol(A);

% EIGSOL Calculate the eigen value solution of the system Ax=0.
% x = eigsol(A);
%
% input  : Coeficient Matrix of the system, A
% output : Solution vector, x
%
% Nuno Alexandre Cid Martins
% Coimbra, Sep 29, 1998
% I.S.R.

if (nargin~=1),
  error('Requires one input argument.');
else
  if (isstr(A)),
    error('Requires one matrix as input arguments.');
  else
    [V D]=eig(A'*A);
    m=1.0e+308;
    j=1;
    for i=1:size(D,1),
      if (m>D(i,i)),
	m=D(i,i);
	j=i;
      end;
    end;
    x=V(:,j);
  end;	
end;

function  x = lsqsvd(A,b);

% LSQSVD Computes the least-squares solution x of the system Ax=b,
%   using the SVD of A.
% x = lsqsvd(A,b);
%
% input  : Coeficient Matrix of the system, A
%			  Result vector of the system, b
% output : Solution vector, x
%
% Nuno Alexandre Cid Martins
% Coimbra, Sep 29, 1998
% I.S.R.

if (nargin~=2),
  error('Requires two input arguments.');
else
  if (isstr(A) | isstr(b)),
    error('Requires one matrix and one vector as input arguments.');
  else
    [U,S,V]=svd(A);
    ub=U'*b;
    y=zeros(size(A,2),1);
%    for i=1:size(A,2),	% mod by pic, was size(A,2)
    for i=1:min(size(A)),	% mod by pic, was size(A,2)
      if (S(i,i)~=0),
	y(i)=ub(i)/S(i,i);
      else
	y(i)=1.0e+308;
      end;
    end;
    x=V*y;
  end;
end;

function  x = psinvsol(A,b);

% PSINVSOL Computes pseudo-inverse solution x of the system Ax=b.
% x = psinvsol(A,b);
%
% input  : Coeficient Matrix of the system, A
%			  Result vector of the system, b
% output : Solution vector, x
%
% Nuno Alexandre Cid Martins
% Coimbra, Sep 29, 1998
% I.S.R.

if (nargin~=2),
  error('Requires two input arguments.');
else
  if (isstr(A) | isstr(b)),
    error('Requires one matrix and one vector as input arguments.');
  else
    x=inv(A'*A)*A'*b;
  end;
end;

function  x = psinvsvd(A,b);

% PSINVSVD Computes pseudo-inverse solution x of the system Ax=b,
%   using the SVD of A.
% x = psinvsvd(A,b);
%
% input  : Coeficient Matrix of the system, A
%			  Result vector of the system, b
% output : Solution vector, x
%
% Nuno Alexandre Cid Martins
% Coimbra, Sep 29, 1998
% I.S.R.

if (nargin~=2),
  error('Requires two input arguments.');
else
  if (isstr(A) | isstr(b)),
    error('Requires one matrix and one vector as input arguments.');
  else
    [U,S,V]=svd(A);
    Sp=zeros(size(S));
    for i=1:size(S,2),
      if (S(i,i)~=0),
	Sp(i,i)=1/S(i,i);
      else
	Sp(i,i)=0;
      end;
    end;
    Ap=V*Sp'*U';
    x=Ap*b;
  end;
end;
