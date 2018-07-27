/* iwindow.c
 *
 * General function of a local window
 *
 *	IMM = IWINDOW(IM, SE, FUNC [, EDGE])
 *
 * where	SE is the structuring element
 *		FUNC is the name of a Matlab function which is passed a vector
 *			of all pixels in the window
 *		EDGE is 'border', 'none', 'trim', 'wrap', 'zero'.
 *
 *	$Header: /home/autom/pic/cvsroot/image-toolbox/iwindow.c,v 1.1 2002/08/28 04:53:08 pic Exp $
 *
 *	$Log: iwindow.c,v $
 *	Revision 1.1  2002/08/28 04:53:08  pic
 *	Initial CVS version.
 *
 *	Revision 1.2  2001/03/07 22:13:14  pic
 *	Added UBC copyright message.
 *
 *	Revision 1.1  2000/03/10 07:04:11  pic
 *	Initial revision
 *
 *
 * Copyright (c) Peter Corke, 1998  Machine Vision Toolbox for Matlab
 *		pic 12/98 based on imorph.c
 *
 * Uses code from the package VISTA Copyright 1993, 1994 University of 
 * British Columbia.
 */
#include "mex.h"
#include <math.h>

/* Input Arguments */

#define	IM_IN		prhs[0]
#define	SE_IN		prhs[1]
#define	FUNC_IN		prhs[2]
#define	EDGE_IN		prhs[3]

/* Output Arguments */

#define	IMM_OUT	plhs[0]

enum pad {
	PadBorder,
	PadNone,
	PadWrap,
	PadTrim
} pad_method = PadBorder;

#define	BUFLEN	100

mxArray *iwindow(const mxArray *msrc, const mxArray *mmask);

char	matlabfunc[BUFLEN];

void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	mxArray	*r;
	char	s[BUFLEN];

	/* Check for proper number of arguments */

	if (nrhs < 3)
		mexErrMsgTxt("IWINDOW requires three input arguments.");

	/* parse out the edge method */
	switch (nrhs) {
	case 4:
		if (!mxIsChar(prhs[3]))
			mexErrMsgTxt("edge arg must be string");
		mxGetString(EDGE_IN, s, BUFLEN);
 		/* EDGE is 'border', 'none', 'trim', 'wrap', 'zero'. */
		if (strcmp(s, "border") == 0)
			pad_method = PadBorder;
		else if (strcmp(s, "none") == 0)
			pad_method = PadNone;
		else if (strcmp(s, "wrap") == 0)
			pad_method = PadWrap;
		else if (strcmp(s, "trim") == 0)
			pad_method = PadTrim;
		/* fall through */
	case 3:
		if (!mxIsChar(FUNC_IN))
			mexErrMsgTxt("op arg must be a string");
		mxGetString(FUNC_IN, matlabfunc, BUFLEN);
	}
			
	if (!mxIsNumeric(IM_IN) || mxIsComplex(IM_IN) || 
		!mxIsDouble(IM_IN)) {
		mexErrMsgTxt("IWINDOW requires a real matrix.");
	}

	/* Do the actual computations in a subroutine */

	r = iwindow(IM_IN, SE_IN);
	if (nlhs == 1)
		plhs[0] = r;

	return;
}


/*
 *  ClampIndex
 *
 *  This macro implements behavior near the borders of the source image.
 *  Index is the band, row or column of the pixel being convolved.
 *  Limit is the number of bands, rows or columns in the source image.
 *  Label is a label to jump to to break off computation of the current
 *  destination pixel.
 */

#define ClampIndex(index, limit, label)	   \
{					   \
    if (index < 0)		    \
	switch (pad_method) {\
	case PadBorder:	index = 0; break;\
	case PadNone:		goto label;    \
	case PadWrap:		index += limit; break;    \
	default:			continue;    \
	}		    \
    else if (index >= limit)	    \
	switch (pad_method) {	    \
	case PadBorder:	index = limit - 1; break; \
	case PadNone:		goto label;	   \
	case PadWrap:		index -= limit; break;	    \
	default:			continue;	    \
	}	    \
}

#define	SPixel(r, c)	src[r+c*src_nrows]
#define	DPixel(r, c)	dest[r+c*dest_nrows]
#define	MPixel(r, c)	mask[r+c*mask_nrows]
#define	WPixel(r, c)	win[r+c*mask_nrows]

mxArray *
iwindow(const mxArray *msrc, const mxArray *mmask)
{
    int dest_nrows, dest_ncols, mask_nrows,mask_ncols;
    int	src_nrows, src_ncols;
    mxArray	*mdest, *mwin;
    double	*src, *dest, *mask, *win;
    int band_offset, row_offset, col_offset;
    int src_band, src_row, src_col, dest_band, dest_row, dest_col, i, j, k;
    int	mask_pixels = 0;

    src_nrows = mxGetM(msrc);
    src_ncols = mxGetN(msrc);
    mask_nrows = mxGetM(mmask);
    mask_ncols = mxGetN(mmask);

    /* Determine what dimensions the destination image should have:
	o if the pad method is Trim, the destination image will have smaller
	  dimensions than the source image (by an amount corresponding to the
	  mask size); otherwise it will have the same dimensions. */
    dest_nrows = src_nrows;
    dest_ncols = src_ncols;
    if (pad_method == PadTrim) {
	dest_nrows -= (mask_nrows - 1);
	dest_ncols -= (mask_ncols - 1);
	if (dest_nrows <= 0 || dest_ncols <= 0)
	    mexErrMsgTxt("Image is smaller than mask");
    }


    /* Locate the destination. Since the operation cannot be carried out in
       place, we create a temporary work image to serve as the destination if
       dest == src or dest == mask: */
    mdest = mxCreateDoubleMatrix(dest_nrows, dest_ncols, mxREAL);

    src = mxGetPr(msrc);
    dest = mxGetPr(mdest);
    mask = mxGetPr(mmask);

    /* Determine the mapping from destination coordinates + mask coordinates to
       source coordinates: */
    if (pad_method == PadTrim)
	row_offset = col_offset = 0;
    else {
	row_offset = - (mask_nrows / 2);
	col_offset = - (mask_ncols / 2);
    }

	/* figure the number of elements set in the mask */
	    for (j = 0; j < mask_nrows; j++) {
		for (k = 0; k < mask_ncols; k++) {
		    if (MPixel(j,k) > 0)
			mask_pixels++;
		}
	}
	/* allocate storage for the vector to pass to Matlab */
    mwin = mxCreateDoubleMatrix(mask_pixels, 1, mxREAL);
    win = mxGetPr(mwin);

    /* Perform the convolution over all destination rows, columns: */
    {
    double	*p, *pp;
    mxArray	*mreturn[1];

	for (dest_row = 0; dest_row < dest_nrows; dest_row++)
	    for (dest_col = 0; dest_col < dest_ncols; dest_col++) {
		    p = win;
		    for (j = 0; j < mask_nrows; j++) {
			src_row = dest_row + j + row_offset;
			ClampIndex (src_row, src_nrows, done);
			for (k = 0; k < mask_ncols; k++) {
			    src_col = dest_col + k + col_offset;
			    ClampIndex (src_col, src_ncols, done);
			    if (MPixel(j,k) > 0) {
			        *p++ = SPixel( src_row, src_col);
			    }
			}
		    }

done:
		    /* now call Matlab back with the vector */
		   mexCallMATLAB(1, mreturn, 1, &mwin, matlabfunc);
		   pp = mxGetPr(mreturn[0]);
		DPixel(dest_row, dest_col) = pp[0];
		mxDestroyArray(mreturn[0]);
	    }
    }


    return mdest;
}
