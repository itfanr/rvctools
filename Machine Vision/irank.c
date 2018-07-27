/*
 * irank.c
 * 
 * Fast rank filter for images.
 * 
 * IMM = IRANK(IM, ORDER, SE [,HISTOBINS] [, EDGE])
 *              0    1     2      3          4
 * 
 * where	SE is the structuring element ORDER is EDGE is 'border', 'none',
 * 'trim', 'wrap', 'zero'.
 * 
 *	$Header: /home/autom/pic/cvsroot/image-toolbox/irank.c,v 1.1 2002/08/28 04:53:07 pic Exp $
 *
 *	$Log: irank.c,v $
 *	Revision 1.1  2002/08/28 04:53:07  pic
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
 * pic 3/95
 *
 * Uses code from the package VISTA Copyright 1993, 1994 University of 
 * British Columbia.
 */
#include "mex.h"
#include <math.h>

/* Input Arguments */

#define	IM_IN		prhs[0]
#define	ORDER_IN	prhs[1]
#define	SE_IN		prhs[2]
#define	HISTBINS_IN	prhs[3]
#define	EDGE_IN		prhs[4]

#define	HISTBINS	256

/* Output Arguments */

#define	IMM_OUT	plhs[0]

enum pad {
	PadBorder,
	PadNone,
	PadWrap,
	PadTrim
}               pad_method = PadBorder;

enum op_type {
	OpMax,
	OpMin,
	OpDiff
}               oper;

#define	BUFLEN	100

mxArray        *irank(const mxArray * msrc, const mxArray * mmask, const mxArray *morder, int hbins);

void
mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
	char            s[BUFLEN];
	mxArray        *r;
	int		histbins = HISTBINS;

	/* Check for proper number of arguments */
/*
 * 
 * IMM = IRANK(IM, ORDER, SE [,HISTOBINS] [, EDGE])
 *              0    1     2      3          4
 */

	if (nrhs < 3)
		mexErrMsgTxt("IRANK requires three input arguments.");

	/* parse out the edge method */
	switch (nrhs) {
	case 5:
		if (!mxIsChar(EDGE_IN))
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
	case 4:
		if (!mxIsNumeric(HISTBINS_IN))
			mexErrMsgTxt("histbins arg must be numeric");
		histbins = (int) * mxGetPr(HISTBINS_IN);
	}

	if ((!mxIsNumeric(IM_IN)) || (!mxIsNumeric(ORDER_IN)) || (!mxIsNumeric(SE_IN)))
			mexErrMsgTxt("first 3 args must be numeric");
		

	if (!mxIsNumeric(IM_IN) || mxIsComplex(IM_IN) ||
	    !mxIsDouble(IM_IN)) {
		mexErrMsgTxt("IMORPH requires a real matrix.");
	}

	/* Do the actual computations in a subroutine */

	r = irank(IM_IN, SE_IN, ORDER_IN, histbins);
	if (nlhs == 1)
		plhs[0] = r;

	return;
}


/*
 * ClampIndex
 * 
 * This macro implements behavior near the borders of the source image. Index is
 * the band, row or column of the pixel being convolved. Limit is the number
 * of bands, rows or columns in the source image. Label is a label to jump to
 * to break off computation of the current destination pixel.
 */

#define ClampIndex(index, limit, label)	   \
{					   \
    if (index < 0)		    \
	switch (pad_method) {\
	case PadBorder:		index = 0; break;\
	case PadNone:		goto label;    \
	case PadWrap:		index += limit; break;    \
	default:		continue;    \
	}		    \
    else if (index >= limit)	    \
	switch (pad_method) {	    \
	case PadBorder:		index = limit - 1; break; \
	case PadNone:		goto label;	   \
	case PadWrap:		index -= limit; break;	    \
	default:		continue;	    \
	}	    \
}

#define	SPixel(r, c)	src[r+c*src_nrows]
#define	DPixel(r, c)	dest[r+c*dest_nrows]
#define	MPixel(r, c)	mask[r+c*mask_nrows]

mxArray        *
irank(const mxArray * msrc, const mxArray * mmask, const mxArray * morder, int histbins)
{
	int             dest_nrows, dest_ncols, mask_nrows, mask_ncols;
	int             src_nrows, src_ncols;
	mxArray        *mdest;
	double         *src, *dest, *mask, min, max, offset, scale;
	int             band_offset, row_offset, col_offset;
	int             src_band, src_row, src_col, dest_band, dest_row,
	                mask_row, mask_col, dest_col, i, j, k, iorder;
	unsigned int	*hist, *ph, cumsum, count;

	src_nrows = mxGetM(msrc);
	src_ncols = mxGetN(msrc);
	mask_nrows = mxGetM(mmask);
	mask_ncols = mxGetN(mmask);



	/* process input variables */
	src = mxGetPr(msrc);
	mask = mxGetPr(mmask);
	iorder = (int) * mxGetPr(morder);

	/*
	 * find span of pixel values in the image
	 */
	max = -DBL_MAX;
	min = DBL_MAX;
	for (src_col = 0; src_col < src_ncols; src_col++)
		for (src_row = 0; src_row < src_nrows; src_row++) {
			double          p = SPixel(src_row, src_col);

			if (p > max)
				max = p;
			if (p < min)
				min = p;
		}
	printf("image pixel values: %f to %f\n", min, max);
	offset = min;
	if ( (max - min) == 0)
			mexErrMsgTxt("Image has no variance");
	scale = histbins / (max - min);

	/*
	 * determine number of non-zero mask elements
	 */
	count = 0;
	for (mask_col = 0; mask_col < mask_ncols; mask_col++)
		for (mask_row = 0; mask_row < mask_nrows; mask_row++) {
			double          p = MPixel(mask_row, mask_col);

			if (p > 0)
				count++;
		}
	printf("%d non-zero mask elements\n", count);
	if ( (iorder < 1) || (iorder > count) )
			mexErrMsgTxt("Order must be between 1 and number of elements in mask");
	iorder = count + 1 - iorder;

	/*
	 * Determine what dimensions the destination image should have: o if
	 * the pad method is Trim, the destination image will have smaller
	 * dimensions than the source image (by an amount corresponding to the
	 * mask size); otherwise it will have the same dimensions.
	 */
	dest_nrows = src_nrows;
	dest_ncols = src_ncols;
	if (pad_method == PadTrim) {
		dest_nrows -= (mask_nrows - 1);
		dest_ncols -= (mask_ncols - 1);
		if (dest_nrows <= 0 || dest_ncols <= 0)
			mexErrMsgTxt("Image is smaller than mask");
	}

	mdest = mxCreateDoubleMatrix(dest_nrows, dest_ncols, mxREAL);
	dest = mxGetPr(mdest);

	if ((hist = mxCalloc(histbins+1, sizeof(unsigned int))) == NULL)
		mexErrMsgTxt("irank: calloc() failed");

	/*
	 * Determine the mapping from destination coordinates + mask
	 * coordinates to source coordinates:
	 */
	if (pad_method == PadTrim)
		row_offset = col_offset = 0;
	else {
		row_offset = -(mask_nrows / 2);
		col_offset = -(mask_ncols / 2);
	}

	for (dest_row = 0; dest_row < dest_nrows; dest_row++)
		for (dest_col = 0; dest_col < dest_ncols; dest_col++) {
			/* zero the histogram */
			for (i=0, ph=hist; i<histbins; i++)
				*ph++ = 0;

			for (j = 0; j < mask_nrows; j++) {
				src_row = dest_row + j + row_offset;
				ClampIndex(src_row, src_nrows, label);
				for (k = 0; k < mask_ncols; k++) {
					double	p;
					src_col = dest_col + k + col_offset;
					ClampIndex(src_col, src_ncols, label);
					if (MPixel(j, k) > 0) {
						int	t;

						p = SPixel(src_row, src_col);
						/* convert value to bin index */
						t = (int) (p-offset)*scale;
						hist[t]++;
					}
				}
			}
	label:		;
			for (ph=hist, cumsum=0; cumsum<iorder; ph++)
				cumsum += *ph;
			/* convert bin index to value */
			DPixel(dest_row, dest_col) = (double)(ph - hist) / scale + offset;
		}


	return mdest;
}
