/* imorph.c
 *
 * Fast morphological transform for images.
 *
 *	IMM = IMORPH(IM, SE, OP [, EDGE])
 *
 * where	SE is the structuring element
 *		OP is 'min', 'max', 'diff'
 *		EDGE is 'border', 'none', 'trim', 'wrap', 'zero'.
 *
 *	$Header: /home/autom/pic/cvsroot/image-toolbox/imorph.c,v 1.1 2002/08/28 04:53:06 pic Exp $
 *
 *	$Log: imorph.c,v $
 *	Revision 1.1  2002/08/28 04:53:06  pic
 *	Initial CVS version.
 *
 *	Revision 1.2  2001/03/07 22:13:14  pic
 *	Added UBC copyright message.
 *
 *	Revision 1.1  2000/03/10 07:04:11  pic
 *	Initial revision
 *
 *
 * Copyright (c) Peter Corke, 1995  Machine Vision Toolbox for Matlab
 *		pic 3/95
 *
 * Uses code from the package VISTA Copyright 1993, 1994 University of 
 * British Columbia.
 */
#include "mex.h"
#include <math.h>

/* Input Arguments */

#define	IM_IN		prhs[0]
#define	SE_IN		prhs[1]
#define	OP_IN		prhs[2]
#define	EDGE_IN		prhs[3]

/* Output Arguments */

#define	IMM_OUT	plhs[0]

enum pad {
	PadBorder,
	PadNone,
	PadWrap,
	PadTrim
} pad_method = PadBorder;

enum op_type {
	OpMax,
	OpMin,
	OpDiff
} oper;

#define	BUFLEN	100

mxArray *imorph(const mxArray *msrc, const mxArray *mmask);

void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	char	s[BUFLEN];
	mxArray	*r;

	/* Check for proper number of arguments */

	if (nrhs < 3)
		mexErrMsgTxt("IMORPH requires three input arguments.");

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
		if (!mxIsChar(OP_IN))
			mexErrMsgTxt("op arg must be string");
		mxGetString(OP_IN, s, BUFLEN);
		/* OP is 'min', 'max', 'diff' */
		if (strcmp(s, "min") == 0)
			oper = OpMin;
		else if (strcmp(s, "max") == 0)
			oper = OpMax;
		else if (strcmp(s, "diff") == 0)
			oper = OpDiff;
	}
			
	if (!mxIsNumeric(IM_IN) || mxIsComplex(IM_IN) || 
		!mxIsDouble(IM_IN)) {
		mexErrMsgTxt("IMORPH requires a real matrix.");
	}

	/* Do the actual computations in a subroutine */

	r = imorph(IM_IN, SE_IN);
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

/*
 *  Morph
 *
 *  This macro performs the actual morphological operaton, iterating over pixels
 *  of the destination and mask images.
 */

#define	Morph(op, label)		    \
{									    \
    double	min, max;					    	    \
    double	p, a;      		    \
	for (dest_row = 0; dest_row < dest_nrows; dest_row++)     \
	    for (dest_col = 0; dest_col < dest_ncols; dest_col++) { \
		max = -DBL_MAX;         	                    \
		min = DBL_MAX;	                            \
		    for (j = 0; j < mask_nrows; j++) {		    \
			src_row = dest_row + j + row_offset;	    \
			ClampIndex (src_row, src_nrows, label);	    \
			for (k = 0; k < mask_ncols; k++) {	    \
			    src_col = dest_col + k + col_offset;    \
			    ClampIndex (src_col, src_ncols, label); \
			    if (MPixel(j,k) > 0) {                 \
			        p = SPixel( src_row, src_col);	    \
				if (p > max)                        \
					max = p;		    \
				if (p < min)                        \
					min = p;		    \
			    }                                       \
			}					    \
		    }						    \
  label:	DPixel(dest_row, dest_col) = op;                    \
	    }							    \
}

#define	SPixel(r, c)	src[r+c*src_nrows]
#define	DPixel(r, c)	dest[r+c*dest_nrows]
#define	MPixel(r, c)	mask[r+c*mask_nrows]

mxArray *
imorph(const mxArray *msrc, const mxArray *mmask)
{
    int dest_nrows, dest_ncols, mask_nrows,mask_ncols;
    int	src_nrows, src_ncols;
    mxArray	*mdest;
    double	*src, *dest, *mask;
    int band_offset, row_offset, col_offset;
    int src_band, src_row, src_col, dest_band, dest_row, dest_col, i, j, k;

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

    /* Perform the convolution over all destination rows, columns: */
    switch (oper) {
    case OpMin:
		Morph(min, L1); break;
    case OpMax:
		Morph(max, L2); break;
    case OpDiff:
		Morph(max-min, L3); break;
	}

    return mdest;
}
