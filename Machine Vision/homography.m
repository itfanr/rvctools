%HOMOGRAPHY	estimate homography between two sets of image points
%
%	H = homography(p1, p2 [, how])
%
%	The argument 'how' is used to specify the method and is one of
%	 'eig', 'svd', 'pinv', 'lsq' (default) or 'ransac'.
%
%
%	H is the homography that maps image plane points p1 -> p2.
%
%	RANSAC provides a very robust method of dealing with incorrect
%	point correspondances through outlier rejection.  It requires extra
%	arguments:
%		iter	maximum number of iterations
%		thresh	a threshold
%		how	the underlying method to use, as above except for
%			ransac (optional).
%
%	All methods require at least 4 points except 'eig' which requires 
%	at least 5.
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.
%
% Code wrapper by Peter Corke.
%	Different methods have different error characteristics, robustness
% to error, and minimum number of points.
%
% SEE ALSO:	invhomog, homtrans, homtest, fmatrix

% $Header: /home/autom/pic/cvsroot/image-toolbox/homography.m,v 1.3 2005/10/30 02:32:52 pic Exp $
% $Log: homography.m,v $
% Revision 1.3  2005/10/30 02:32:52  pic
% Doco cleanup
%
% Revision 1.2  2003/09/30 18:49:26  pic
% Add missing subfunctions to allow ransac mode.
%
% Revision 1.1.1.1  2002/05/26 10:50:21  pic
% initial import
%


function H = homography(Pa, Pb, varargin)

	if nargin == 2,
		how = 'svd';
	else
			how = varargin{1};
	end

	switch how,
	case {'eig'}
		H = Hgeig(Pa, Pb);
	case {'pinv'}
		H = Hgpsi(Pa, Pb);
	case {'svd'}
		H = Hgpsisvd(Pa, Pb);
	case {'lsq'}
		H = Hglsqsvd(Pa, Pb);
	case {'ransac'}
		switch nargin,
		case 3,
		case 4,
			error('Must have at least 4 parameters for RANSAC mode: Pa, Pb, iter, threshold [, how]');
		case 5,
			iter = varargin{2};
			th = varargin{3};
			H = Hgransac(Pa,Pb,iter,th);
		case 6,
			iter = varargin{2};
			th = varargin{3};
			typ = varargin{4};
			if strcmp(typ, 'ransac')
				error('type cannot be specified as ransac for ransac mode');
			end
			H = Hgransac(Pa,Pb,iter,th,typ);
		end
	otherwise
		error( sprintf('bad method %s specified', how) );
end


function Hg = Hgeig(Pte,Ptd);

% HGEIG Calculate the homography between the two vectors of 2D
%   points by the eigen values method.
% Hg = Hgeig(Pte,Ptd);
%
% Input  : Two vectors of 2D points, Pte and Ptd
% Output : The homographic matrix, Hg
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 2, 1998
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
	  error('The vectors should have at least five points');
	else
	  for i=1:size(Pte,1),
	    xe=Pte(i,1);
	    ye=Pte(i,2);
	    xd=Ptd(i,1);
	    yd=Ptd(i,2);
	    X=[X;xe ye 1 0 0 0 -xe*xd -ye*xd -xd;0 0 0 xe ye 1 -xe*yd -ye*yd -yd];
	  end;
	  V=homog_solve('eigsol', X);
	  Hg(1,1)=V(1,1);
	  Hg(1,2)=V(2,1);
	  Hg(1,3)=V(3,1);
	  Hg(2,1)=V(4,1);
	  Hg(2,2)=V(5,1);
	  Hg(2,3)=V(6,1);
	  Hg(3,1)=V(7,1);
	  Hg(3,2)=V(8,1);
	  Hg(3,3)=V(9,1);
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

function Hg = Hgpsi(Pte,Ptd);

% HGPSI Calculate the homography between the two vectors of 2D
%   points by the pseudo-inverse method.
% Hg = Hgpsi(Pte,Ptd);
%
% Input  : Two vectors of 2D points, Pte and Ptd
% Output : The homographic matrix, Hg
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 2, 1998
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
	  error('The vectors should have at least four points');
	else
	  for i=1:size(Pte,1),
	    xe=Pte(i,1);
	    ye=Pte(i,2);
	    xd=Ptd(i,1);
	    yd=Ptd(i,2);
	    X=[X;xe ye 1 0 0 0 -xe*xd -xd*ye;0 0 0 xe ye 1 -xe*yd -ye*yd];
	    x=[x;xd;yd];
	  end;
	  V=homog_solve('psinvsol', X,x);
	  Hg(1,1)=V(1,1);
	  Hg(1,2)=V(2,1);
	  Hg(1,3)=V(3,1);
	  Hg(2,1)=V(4,1);
	  Hg(2,2)=V(5,1);
	  Hg(2,3)=V(6,1);
	  Hg(3,1)=V(7,1);
	  Hg(3,2)=V(8,1);
	  Hg(3,3)=1.0;
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

function Hg = Hgpsisvd(Pte,Ptd);

% HGPSISVD Calculate the homography between the two vectors of 2D
%   points by the pseudo-inverse method, using svd.
% Hg = Hgpsisvd(Pte,Ptd);
%
% Input  : Two vectors of 2D points, Pte and Ptd
% Output : The homographic matrix, Hg
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 2, 1998
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
	  error('The vectors should have at least four points');
	else
	  for i=1:size(Pte,1),
	    xe=Pte(i,1);
	    ye=Pte(i,2);
	    xd=Ptd(i,1);
	    yd=Ptd(i,2);
	    X=[X;xe ye 1 0 0 0 -xe*xd -xd*ye;0 0 0 xe ye 1 -xe*yd -ye*yd];
	    x=[x;xd;yd];
	  end;
	  V=homog_solve('psinvsvd',X,x);
	  Hg(1,1)=V(1,1);
	  Hg(1,2)=V(2,1);
	  Hg(1,3)=V(3,1);
	  Hg(2,1)=V(4,1);
	  Hg(2,2)=V(5,1);
	  Hg(2,3)=V(6,1);
	  Hg(3,1)=V(7,1);
	  Hg(3,2)=V(8,1);
	  Hg(3,3)=1.0;
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

function Hg = Hglsqsvd(Pte,Ptd);

% HGLSQSVD Calculate the homography between the two vectors of 2D
%   points by the least-square method, using svd.
% Hg = Hglsqsvd(Pte,Ptd);
%
% Input  : Two vectors of 2D points, Pte and Ptd
% Output : The homographic matrix, Hg
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 2, 1998
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
	  error('The vectors should have at least four points');
	else
	  for i=1:size(Pte,1),
	    xe=Pte(i,1);
	    ye=Pte(i,2);
	    xd=Ptd(i,1);
	    yd=Ptd(i,2);
	    X=[X;xe ye 1 0 0 0 -xe*xd -xd*ye;0 0 0 xe ye 1 -xe*yd -ye*yd];
	    x=[x;xd;yd];
	  end;
	  V=homog_solve('lsqsvd',X,x);
	  Hg(1,1)=V(1,1);
	  Hg(1,2)=V(2,1);
	  Hg(1,3)=V(3,1);
	  Hg(2,1)=V(4,1);
	  Hg(2,2)=V(5,1);
	  Hg(2,3)=V(6,1);
	  Hg(3,1)=V(7,1);
	  Hg(3,2)=V(8,1);
	  Hg(3,3)=1.0;
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

function [Hg] = Hgransac(Pte,Ptd,iter,th,how)

% HGRANSAC Calculate a homography between Pte and Ptd, using the RANSAC
%   method to eliminate the false matches.
% [Hg] = Hgransac(Pte,Ptd,iter,th,how);
%
% Input  : Two vectors of 2D points, Pte and Ptd
%	   The number of iterations of the process, iter
%	   The threshold, th
%	   Type method, how
% Output : The homography matrix, Hg
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.

%clc;
max=0;
maxdist=1e+308;
maxnums=[];
for i=1:iter,
  [H,nums]=Hgaleat(Pte,Ptd,how);
  [test,dist]=Hgteste(Pte,Ptd,H,th);
  if ((test>max) | (test==max & dist<maxdist)),
    max=test;
    maxdist=dist;
    maxnums=nums;
  end;
end;
if (max>=4),
  for i=1:4,
    Pea(i,:)=Pte(maxnums(i),:);
    Pda(i,:)=Ptd(maxnums(i),:);
  end;
  H=homography(Pea,Pda,how);
  Pea=[];
  Pda=[];
  for i=1:size(Pte,1),
    Pd=H*[Pte(i,:) 1]';
    Pe=inv(H)*[Ptd(i,:) 1]';
    de=sqrt((Pte(i,1)-(Pe(1,1)/Pe(3,1)))^2+(Pte(i,2)-(Pe(2,1)/Pe(3,1)))^2);
    dd=sqrt((Ptd(i,1)-(Pd(1,1)/Pd(3,1)))^2+(Ptd(i,2)-(Pd(2,1)/Pd(3,1)))^2);
    if ((de<=th) & (dd<=th)),
      Pea=[Pea;Pte(i,:)];
      Pda=[Pda;Ptd(i,:)];
    end;
  end;
  Hg=homography(Pea,Pda,how);
  else
    %clc;
    disp('Can not calculate the homography');
end;


function [Hg,nums] = Hgaleat(Pte,Ptd,how)

% HGALEAT Calculate a rondom homography, with four points of the input
%   sets Pte and Ptd.
% [Hg,nums] = Hgaleat(Pte,Ptd);
%
% Input  : Two vectors of 2D points, Pte and Ptd
%	   Method type, how
% Output : The homographic matrix, Hg
%	   The positions of the points that were chosen, nums
%
% see HGCALC
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
Hg=homography(Pe,Pd,how);


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
  error('n must be >= 4');
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

function [test,dist] = Hgteste(Pte,Ptd,H,th)

% HGTESTE Counts how many points of the sets, Pte and Ptd, has the euclidean
%   distance between the point and his reprojection, under the threshold
%   range. 
% [test,dist] = Hgteste(Pte,Ptd,H,th);
%
% Input  : Two vectors of 2D points, Pte and Ptd
%          The homography, H
%          The threshold, th
% Output : The number of points under the threshold range, test
%          The distance error, dist
%
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.

count=[];
dist=0;
for i=1:size(Pte,1),
  Pd=H*[Pte(i,:) 1]';
  Pe=inv(H)*[Ptd(i,:) 1]';
  de=sqrt((Pte(i,1)-(Pe(1,1)/Pe(3,1)))^2+(Pte(i,2)-(Pe(2,1)/Pe(3,1)))^2);
  dd=sqrt((Ptd(i,1)-(Pd(1,1)/Pd(3,1)))^2+(Ptd(i,2)-(Pd(2,1)/Pd(3,1)))^2);
  if ((de<=th) & (dd<=th)),
    count=[count i];
    dist=dist+de+dd;
  end;
end;
test=size(count,2);
