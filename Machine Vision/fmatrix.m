%FMATRIX	estimate the fundamental matrix
%
%	F = FMATRIX(Pa, Pb [, how])
%
%	Given two sets of corresponding points Pa and Pb (each an nx2 matrix)
%	return the fundamental matrix relating the two sets of observations.
%
%	The epipolar line is F*[pa 1] and corresponding points pb will lie
%	on this line.
%
%	The argument 'how' is used to specify the method and is one of
%	 'eig', 'svd', 'pinv', 'lsq' (default) or 'ransac'.
%
%	RANSAC provides a very robust method of dealing with incorrect
%	point correspondances through outlier rejection.  It requires extra
%	arguments:
%		iter	maximum number of iterations
%		thresh	a threshold
%		how	the underlying method to use, as above except for
%			ransac (optional).
%	All methods require at least 4 points except 'eig' which requires 
%	at least 5.
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.
%
% SEE ALSO: homography frefine epiline epidist
%

% Code wrapper by Peter Corke.
% $Header: /home/autom/pic/cvsroot/image-toolbox/fmatrix.m,v 1.3 2005/10/30 03:39:42 pic Exp $
% $Log: fmatrix.m,v $
% Revision 1.3  2005/10/30 03:39:42  pic
% Fixup display of residual.
%
% Revision 1.2  2004/01/02 11:35:55  pic
% Add residual as return argument.
%
% Revision 1.1.1.1  2002/05/26 10:50:20  pic
% initial import
%


function [F,resid] = fmatrix(Pa, Pb, varargin)

	if numrows(Pa) == 1,
		Pa = reshape(Pa, 2, numcols(Pa)/2)';
	end
	if numrows(Pb) == 1,
		Pb = reshape(Pb, 2, numcols(Pb)/2)';
	end
	if nargin == 2,
		how = 'lsq';
	else
			how = varargin{1};
	end

	switch how,
	case {'eig'}
		F = Mfeig(Pa, Pb);
	case {'pinv'}
		F = Mfpsi(Pa, Pb);
	case {'svd'}
		F = Mfpsisvd(Pa, Pb);
	case {'lsq'}
		F = Mflsqsvd(Pa, Pb);
	case {'ransac'}
		switch nargin,
		case 3,
		case 4,
			error('Must have at least 4 parameters for RANSAC mode: Pa, Pb, iter, threshold [, how]');
		case 5,
			F = Mfransac(Pa,Pb, varargin{2:end})
		case 6,
			if strcmp(varargin{4}, 'ransac')
				error('type cannot be specified as ransac for ransac mode');
			end
			F = Mfransac(Pa,Pb, varargin{2:end})
		end
	otherwise
		error( sprintf('bad method %s specified', how) );
	end

	% check the residuals
	resid = epidist(F, Pa, Pb);
	fprintf('maximum residual %f pix\n', max(abs(diag(resid))));

function F = Mfeig(Pte,Ptd);

% MFEIG Calculate the fundamental matrix between the two vectors of 2D
%   points by the eigen values method.
% F = Mfeig(Pte,Ptd);
%
% Input  : Two vectors of 2D points, Pte and Ptd
% Output : The fundamental matrix, F
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.

transpe=0;
transpd=0;
X=[];
x=[];
if (nargin~=2),
  error('Requires two vectors of 2D points as input arguments.');
else
  if (isstr(Pte) | isstr(Ptd)),
    error('Requires two vectors of 2D points as input arguments.');
  else
    if (size(Pte,1)~=size(Ptd,1) | size(Pte,2)~=size(Ptd,2)),
      error('The vectors must have the same size');
    else
      if (size(Pte,1)==2 & size(Pte,2)~=2),
	Pte=Pte';
	transpe=1;
      end;
      if (size(Ptd,1)==2 & size(Ptd,2)~=2),
	Ptd=Ptd';
	transpd=1;
      end;
      if ((size(Pte,2)~=2) | (size(Ptd,2)~=2)),
	error('The points of the vector must be 2D.');
      else
	if ((size(Pte,1)<5) | (size(Ptd,1)<5)),
	  error('The vectors should have at least nine points');
	else
	  for i=1:size(Pte,1),
	    xe=Pte(i,1);
	    ye=Pte(i,2);
	    xd=Ptd(i,1);
	    yd=Ptd(i,2);
	    X=[X;xe*xd ye*xd xd xe*yd ye*yd yd xe ye 1];
	  end;
	  V=homog_solve('eigsol',X);
	  F(1,1)=V(1,1);
	  F(1,2)=V(2,1);
	  F(1,3)=V(3,1);
	  F(2,1)=V(4,1);
	  F(2,2)=V(5,1);
	  F(2,3)=V(6,1);
	  F(3,1)=V(7,1);
	  F(3,2)=V(8,1);
	  F(3,3)=V(9,1);
	end;
      end;
      if (transpe),
	Pte=Pte';
      end;
      if (transpd),
	Ptd=Ptd';
      end;
    end;
  end;
end;

function F = Mfpsi(Pte,Ptd);

% MFPSI Calculate the fundamental matrix between the two vectors of 2D
%   points by the pseudo-inverse method.
% F = Mfpsi(Pte,Ptd);
%
% Input  : Two vectors of 2D points, Pte and Ptd
% Output : The fundamental matrix, F
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.

transpe=0;
transpd=0;
X=[];
x=[];
if (nargin~=2),
  error('Requires two vectors of 2D points as input arguments.');
else
  if (isstr(Pte) | isstr(Ptd)),
    error('Requires two vectors of 2D points as input arguments.');
  else
    if (size(Pte,1)~=size(Ptd,1) | size(Pte,2)~=size(Ptd,2)),
      error('The vectors must have the same size');
    else
      if (size(Pte,1)==2 & size(Pte,2)~=2),
	Pte=Pte';
	transpe=1;
      end;
      if (size(Ptd,1)==2 & size(Ptd,2)~=2),
	Ptd=Ptd';
	transpd=1;
      end;
      if ((size(Pte,2)~=2) | (size(Ptd,2)~=2)),
	error('The points of the vector must be 2D.');
      else
	if ((size(Pte,1)<4) | (size(Ptd,1)<4)),
	  error('The vectors should have at least eight points');
	else
	  for i=1:size(Pte,1),
	    xe=Pte(i,1);
	    ye=Pte(i,2);
	    xd=Ptd(i,1);
	    yd=Ptd(i,2);
	    X=[X;xe*xd ye*xd xd xe*yd ye*yd yd xe ye];
	    x=[x;-1];
	  end;
	  V=homog_solve('psinvsol',X,x);
	  F(1,1)=V(1,1);
	  F(1,2)=V(2,1);
	  F(1,3)=V(3,1);
	  F(2,1)=V(4,1);
	  F(2,2)=V(5,1);
	  F(2,3)=V(6,1);
	  F(3,1)=V(7,1);
	  F(3,2)=V(8,1);
	  F(3,3)=1.0;
	end;
      end;
      if (transpe),
	Pte=Pte';
      end;
      if (transpd),
	Ptd=Ptd';
      end;
    end;
  end;
end;


function F = Mfpsisvd(Pte,Ptd);

% MFPSISVD Calculate the fundamental matrix between the two vectors of
%   2D points by the pseudo-inverse method, using svd.
% F = Mfpsisvd(Pte,Ptd);
%
% Input  : Two vectors of 2D points, Pte and Ptd
% Output : The fundamental matrix, F
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.

transpe=0;
transpd=0;
X=[];
x=[];
if (nargin~=2),
  error('Requires two vectors of 2D points as input arguments.');
else
  if (isstr(Pte) | isstr(Ptd)),
    error('Requires two vectors of 2D points as input arguments.');
  else
    if (size(Pte,1)~=size(Ptd,1) | size(Pte,2)~=size(Ptd,2)),
      error('The vectors must have the same size');
    else
      if (size(Pte,1)==2 & size(Pte,2)~=2),
	Pte=Pte';
	transpe=1;
      end;
      if (size(Ptd,1)==2 & size(Ptd,2)~=2),
	Ptd=Ptd';
	transpd=1;
      end;
      if ((size(Pte,2)~=2) | (size(Ptd,2)~=2)),
	error('The points of the vector must be 2D.');
      else
	if ((size(Pte,1)<4) | (size(Ptd,1)<4)),
	  error('The vectors should have at least eight points');
	else
	  for i=1:size(Pte,1),
	    xe=Pte(i,1);
	    ye=Pte(i,2);
	    xd=Ptd(i,1);
	    yd=Ptd(i,2);
	    X=[X;xe*xd ye*xd xd xe*yd ye*yd yd xe ye];
	    x=[x;-1];
	  end;
	  V=psinvsvd(X,x);
	  F(1,1)=V(1,1);
	  F(1,2)=V(2,1);
	  F(1,3)=V(3,1);
	  F(2,1)=V(4,1);
	  F(2,2)=V(5,1);
	  F(2,3)=V(6,1);
	  F(3,1)=V(7,1);
	  F(3,2)=V(8,1);
	  F(3,3)=1.0;
	end;
      end;
      if (transpe),
	Pte=Pte';
      end;
      if (transpd),
	Ptd=Ptd';
      end;
    end;
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
    for i=1:min(size(S)),
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

function F = Mflsqsvd(Pte,Ptd);

% MFLSQSVD Calculate the fundamental matrix between the two vectors of
%   2D points by the least-square method, using svd.
% F = Mflsqsvd(Pte,Ptd);
%
% Input  : Two vectors of 2D points, Pte and Ptd
% Output : The fundamental matrix, F
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.

transpe=0;
transpd=0;
X=[];
x=[];
if (nargin~=2),
  error('Requires two vectors of 2D points as input arguments.');
else
  if (isstr(Pte) | isstr(Ptd)),
    error('Requires two vectors of 2D points as input arguments.');
  else
    if (size(Pte,1)~=size(Ptd,1) | size(Pte,2)~=size(Ptd,2)),
      error('The vectors must have the same size');
    else
      if (size(Pte,1)==2 & size(Pte,2)~=2),
	Pte=Pte';
	transpe=1;
      end;
      if (size(Ptd,1)==2 & size(Ptd,2)~=2),
	Ptd=Ptd';
	transpd=1;
      end;
      if ((size(Pte,2)~=2) | (size(Ptd,2)~=2)),
	error('The points of the vector must be 3D.');
      else
	if ((size(Pte,1)<4) | (size(Ptd,1)<4)),
	  error('The vectors should have at least eight points');
	else
	  for i=1:size(Pte,1),
	    xe=Pte(i,1);
	    ye=Pte(i,2);
	    xd=Ptd(i,1);
	    yd=Ptd(i,2);
	    X=[X;xe*xd ye*xd xd xe*yd ye*yd yd xe ye];
	    x=[x;-1];
	  end;

	  V=homog_solve('lsqsvd',X,x);
	  F(1,1)=V(1,1);
	  F(1,2)=V(2,1);
	  F(1,3)=V(3,1);
	  F(2,1)=V(4,1);
	  F(2,2)=V(5,1);
	  F(2,3)=V(6,1);
	  F(3,1)=V(7,1);
	  F(3,2)=V(8,1);
	  F(3,3)=1.0;
	end;
      end;
      if (transpe),
	Pte=Pte';
      end;
      if (transpd),
	Ptd=Ptd';
      end;
    end;
  end;
end;


function [F] = Mfransac(Pte,Ptd,iter,th,how)

% MFRANSAC Calculate the fundamental matrix between Pte and Ptd, using
%   the RANSAC method to eliminate the false matches.
% [F] = Mfransac(Pte,Ptd,iter,th,how);
%
% Input  : Two vectors of 2D points, Pte and Ptd
%	   The number of iterations of the process, iter
%	   The threshold, th
%	   Type method, how
% Output : The fundamental matrix, F
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.

max=0;
maxdist=1e+308;
maxnums=[];
for i=1:iter,
  [F,nums]=mfaleat(Pte,Ptd,how);
  [test,dist]=mfteste(Pte,Ptd,F,th);
  if ((test>max) | (test==max & dist<maxdist)),
    max=test;
    maxdist=dist;
    maxnums=nums;
  end;
end;
maxdist
if (max>=4),
  for i=1:4,
    Pea(i,:)=Pte(maxnums(i),:);
    Pda(i,:)=Ptd(maxnums(i),:);
  end;
  F=fmatrix(Pea,Pda,how);
  Pea=[];
  Pda=[];
  good=[];
  for i=1:size(Pte,1),
    Re=F*[Pte(i,:) 1]';
    Rd=F'*[Ptd(i,:) 1]';
    de=(Rd(1,1)*Pte(i,1)+Rd(2,1)*Pte(i,2)+Rd(3,1))/sqrt(Rd(1,1)^2+Rd(2,1)^2);
    dd=(Re(1,1)*Ptd(i,1)+Re(2,1)*Ptd(i,2)+Re(3,1))/sqrt(Re(1,1)^2+Re(2,1)^2);
    if ((de<=th) & (dd<=th)),
      Pea=[Pea;Pte(i,:)];
      Pda=[Pda;Ptd(i,:)];
      good = [good i];
    end;
  end;
  good
  F=fmatrix(Pea,Pda,how);
  else
    disp('Can not calculate the fundamental matrix');
end;


function [F,nums] = mfaleat(Pte,Ptd,how)

% MFALEAT Calculate a rondom fundamental matrix, with four points
%	of the input sets Pte and Ptd.
% [F,nums] = Mfaleat(Pte,Ptd);
%
% Input  : Two vectors of 2D points, Pte and Ptd
%	   Method type, how
% Output : The fundamental matrix, F
%	   The positions of the points that were chosen, nums
%
% see MFCALC
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.

if (size(Pte)~=size(Ptd)),
  disp('Wrong size of the sets of points');
else
  n=size(Pte,1);
end;
nums=numaleat(n);
for i=1:4,
  Pe(i,:)=Pte(nums(i),:);
  Pd(i,:)=Ptd(nums(i),:);
end;
F=fmatrix(Pe,Pd,how);

function nums = numaleat(n)

% NUMALEAT Give four random numbers from 1 to n.
% nums = numaleat(n);
%
% Input  : The maximum number, n
% Output : The four random numbers, nums
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.

num=0;
while (~num),
  num=round(n*rand);
end;
if (n<4),
  return;
elseif (n~=4),
  nums=[num];
else
  nums=[1;2;3;4];
end;
while (size(nums,1)~=4),
  num=0;
  while (~num),
    num=round(n*rand);
  end;
  ig=0;
  for i=1:size(nums,1),
    if (num==nums(i)),
      ig=1;
      break;
    end;
  end;
  if (~ig),
    nums=[nums;num];
  end;
end;

function [test,dist] = mfteste(Pte,Ptd,F,th)

% MFTESTE Counts how many points of the sets, Pte and Ptd, has the euclidean
%   distance between the point and the epipolar line, under the threshold range. 
% [test,dist] = Mfteste(Pte,Ptd,F,th);
%
% Input  : Two vectors of 2D points, Pte and Ptd
%	   The fundamental matrix, F
%	   The threshold, th
% Output : The number of points under the threshold range, test
%	   The distance error, dist
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.

count=[];
dist=0;
for i=1:size(Pte,1),
  Re=F*[Pte(i,:) 1]';
  Rd=F'*[Ptd(i,:) 1]';
  de=(Rd(1,1)*Pte(i,1)+Rd(2,1)*Pte(i,2)+Rd(3,1))/sqrt(Rd(1,1)^2+Rd(2,1)^2);
  dd=(Re(1,1)*Ptd(i,1)+Re(2,1)*Ptd(i,2)+Re(3,1))/sqrt(Re(1,1)^2+Re(2,1)^2);
  de = abs(de);
  dd = abs(dd);
  if ((de<=th) & (dd<=th)),
    count=[count i];
    dist=dist+de+dd;
  end;
end;
test=size(count,2);
