/* ihist.c
 *
 * Fast histogram function for images.
 *
 *	N = IHIST(IM)
 *	[N,X] = IHIST(IM)
 *
 *	$Header: /home/autom/pic/cvsroot/image-toolbox/fhist.c,v 1.1 2002/08/28 04:53:05 pic Exp $
 *
 *	$Log: fhist.c,v $
 *	Revision 1.1  2002/08/28 04:53:05  pic
 *	Initial CVS version.
 *
 *	Revision 1.1  2000/03/10 07:04:11  pic
 *	Initial revision
 *
 *
 * Copyright (c) Peter Corke, 1995  Machine Vision Toolbox for Matlab
 *		pic 3/95
 */
#include "mex.h"
#include <math.h>

/* Input Arguments */

#define	IM_IN		prhs[0]

/* Output Arguments */

#define	N_OUT	plhs[0]
#define	X_OUT	plhs[1]

#define	NBINS	256

static void 
ihist(double *bins, double *im, int n)
{
	int	*ibin, i, pix;

	ibin = mxCalloc(NBINS, sizeof(int));

	for (i=0; i<n; i++) {
		pix = (int)*im++;
		ibin[(pix<256) ? pix: 255]++;
	}
	for (i=0; i<NBINS; i++)
		*bins++ = ibin[i];
	mxFree(ibin);
}

void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	mxArray	*Mbins, *Mbinnum;
	double	*bins, *im, *binnum;
	int	n, m, i;

	/* Check for proper number of arguments */

	switch (nrhs) {
	case 1:
		break;
	default:
		mexErrMsgTxt("IHIST requires one input arguments.");
		break;
	}


	m = mxGetM(IM_IN);
	n = mxGetN(IM_IN);
	if (!mxIsNumeric(IM_IN) || mxIsComplex(IM_IN) || 
		!mxIsDouble(IM_IN)) {
		mexErrMsgTxt("IHIST requires a real matrix.");
	}

	/* Create a matrix for the return argument */

	Mbins = mxCreateDoubleMatrix(NBINS, 1, mxREAL);


	/* Do the actual computations in a subroutine */

	im = mxGetPr(IM_IN);		/* get pointer to image */
	bins = mxGetPr(Mbins);		/* get pointer to bins */
	ihist(bins, im, m*n);

	switch (nlhs) {
	case 2:
		Mbinnum = mxCreateDoubleMatrix(NBINS, 1, mxREAL);
		binnum = mxGetPr(Mbinnum);
		for (i=0; i<NBINS; i++)
			binnum[i] = i;
		X_OUT = Mbinnum;
		/* fall through */
	case 1:
		N_OUT = Mbins;
		break;
	}

	return;
}


