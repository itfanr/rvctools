/**
 * \file  zncc.c
 * \author Peter Corke 
 * \brief optimized zero-mean cross correlation
 *
 *      CSIRO MANUFACTURING SCIENCE & TECHNOLOGY
 *      QCAT, PO Box 883, Kenmore, Q 4069, Australia
 *
 *      $Header: /home/autom/pic/cvsroot/image-toolbox/zncc.c,v 1.1 2005/10/30 03:16:55 pic Exp $
 *
 *      $Log: zncc.c,v $
 *      Revision 1.1  2005/10/30 03:16:55  pic
 *      mex-file source for the zero-mean normalized cross correlation.
 *
 *      Revision 2.1  2003/05/01 11:43:46  pic
 *      New version, handles arbitrary size images, better offline processing.
 *
 *      Revision 1.4  2002/09/11 01:42:20  pic
 *      changed W to 2
 *      added subpixel interpolation of correlation peak.
 *
 *      Revision 1.3  2002/05/07 06:21:34  pic
 *      added doxygen comments.
 *
 * Revision 1.2  20/0./8.  3.:2.:6.  pic
 * Consolidate compile time constants WIDTH, HEIGHT and W into feature.h
 * 
 *      Revision 1.1  2000/08/03 22:33:27  pic
 *      Initial revision
 *
 *
 * Copyright (c) CSIRO Manufacturing Science & Technology
 */

#include	<stdlib.h>
#ifdef	__Lynx__
#include	<limits.h>
#else
#include	<values.h>
#endif
#include	<time.h>
#include	<sys/times.h>
#include	<math.h>

#include	"zncc.h"

/*
 * define FAST for optimized code
 */
#define	FAST

/**
 * Zero-mean normalized cross-correlation.  Window size is fixed.
 *
 * @param base1 Input image 1
 * @param x1 x coordinate of point in image 1
 * @param y1 y coordinate of point in image 1
 * @param base2 Input image 2
 * @param x2 x coordinate of point in image 2
 * @param y2 y coordinate of point in image 2
 * @param n size of window, should be odd
 * @return similarity measures.
 *
 * Similarity is computed over a window W2P1 x W2P1 in size.  The mean of 
 * each window is first subtracted then the normalized cross-correlation
 * is computed.  The score is in the range -1 to +1.  +1 is a perfect match,
 * -1 is inverse gray pattern.  A score over 0.8 is considered good.
 */
#ifdef	FAST
double
zncc(IMAGE *base1, int x1, int y1, IMAGE *base2,  int x2, int y2, int n)
{
	int	w;
	PIXEL	*p, *p0, *p00, *q, *q0, *q00;
	double	pbar, qbar;
	int	sump, sump2, sumq, sumq2;
	int	h;
	double	c;
	double	sum, den;
	int	W = n/2;
	int	W2P1 = 2*W+1;
	int	width = base1->width;

	/*
	 * for all pixels in the window gather first and second
	 * moments.  From this compute mean and standard deviation
	 */
	sump = sump2 = 0;
	for (p00=p0=IM_PIX(base1,(x1-W),(y1-W)),h=W2P1; h-->0; p0+=width) {
		for (p=p0,w=W2P1; w-->0; ) {
			register int	t = *p++;
			sump += t;
			sump2 += t*t;
		}
	}
	pbar = (double)sump / (W2P1*W2P1);

	sumq = sumq2 = 0;
	for (q00=q0=IM_PIX(base2,(x2-W),(y2-W)),h=W2P1; h-->0; q0+=width) {
		for (q=q0,w=W2P1; w-->0; ) {
			register int	t = *q++;
			sumq += t;
			sumq2 += t*t;
		}
	}
	qbar = (double)sumq / (W2P1*W2P1);

	/*
	 * now compute the correlation (numerator) with mean offset
	 */
	sum = 0;
	for (p0=p00,q0=q00,h=W2P1; h-->0; p0+=width,q0+=width) {
		for (p=p0,q=q0,w=W2P1; w-->0; )
			sum += (*p++ - pbar) * (*q++ - qbar);
	}

	/*
	 * denominator is product of standard deviations
	 */
	den = (sump2 - ((double)sump*sump)/(W2P1*W2P1)) *
		(sumq2 - ((double)sumq*sumq)/(W2P1*W2P1));

	if (den != 0)
		c = sum / sqrt(den);
	else
		c = -1.0;

	return c;
}
#else
double
zncc(IMAGE *base1, int x1, int y1, IMAGE *base2,  int x2, int y2, int n)
{
	double	pbar, qbar;
	double	sum, sump, sump2, sumq, sumq2;
	double	den;
	int	N;
	int	r, c;
	int	W = n/2;
	int	W2P1 = 2*W+1;
	int	w = base1->width;

	N = sump = sumq= 0;
	for (r=-W; r<=W; r++)
		for (c=-W; c<=W; c++) {
			sump += *PIX(base1,x1+c,y1+r,w);
			sumq += *PIX(base2,x2+c,y2+r,w);
			N++;
		}
	
	pbar = sump / N;
	qbar = sumq / N;

	/*
	 * now compute the correlation (numerator) with mean offset
	 */
	sum = 0;
	for (r=-W; r<=W; r++)
		for (c=-W; c<=W; c++)
			sum += (*PIX(base1,x1+c,y1+r)-pbar,w)*(*PIX(base2,x2+c,y2+r)-qbar,w);

	/*
	 * denominator is product of standard deviations
	 */
	N = sump = sumq = 0;
	for (r=-W; r<=W; r++)
		for (c=-W; c<=W; c++) {
			double	t;

			t = *PIX(base1,x1+c,y1+r,w) - pbar;
			sump += t*t;
			t = *PIX(base2,x2+c,y2+r,w) - qbar;
			sumq += t*t;
		}

	den = sump * sumq;

	if (den != 0.0)
		return (double)sum / sqrt(den);
	else
		return -1.0;
}
#endif

/**
 * Subpixel refinement of match.  Region 1 is matched to the refined 
 * coordinate near (x2,y2).
 *
 * @param dx returned refined x-coordinate offset (-1 to 1)
 * @param dy returned refined y-coordinate offset (-1 to 1)
 * @param zC previously computed ZNCC value for match
 * @param base1 Input image 1
 * @param x1 x coordinate of point in image 1
 * @param y1 y coordinate of point in image 1
 * @param base2 Input image 2
 * @param x2 x coordinate of point in image 2
 * @param y2 y coordinate of point in image 2
 * @param n size of window, should be odd
 *
 * The ZNCC is computed for window 2 shifted 1 pixel in each of the N, S,
 * E and W directions.  This allows the coefficients of a paraboloid to
 * be computed and its maxima is the refined estimate of the position
 * of the corresponding window in image 2.
 */
void
zncc_subpixel(double *dx, double *dy, double zC, 
	IMAGE *base1, int x1, int y1, IMAGE *base2,  int x2, int y2, int n)
{
	double	zN, zE, zS, zW;
	/*
	IMAGE_COMPASS_DIRS(base1)
	*/

	zN = zncc(base1, x1, y1, &base2,  x2, y2-1, n);
	zE = zncc(base1, x1, y1, &base2,  x2+1, y2, n);
	zS = zncc(base1, x1, y1, &base2,  x2, y2+1, n);
	zW = zncc(base1, x1, y1, &base2,  x2-1, y2, n);

	*dx = -(zW-zE)/(-zW-zE+2.0*zC)/2.0;
	*dy = -(zN-zS)/(-zN-zS+2.0*zC)/2.0;

#ifdef	DEBUG
	if ((fabs(*dx) > 1) || (fabs(*dy) > 1)) {
		printf("dx dy too big: %f %f\n", *dx, *dy);
		printf("       %6.3f\n%6.3f %6.3f %6.3f\n        %6.3f\n",
			zN, zW, zC, zE, zS);
	}
#endif
}

#ifdef	MAIN
#include	<pgm.h>

#define	NSAMPLE	100000

PIXEL	left[WIDTH*HEIGHT];

main(int ac, char *av[])
{
	int	ncorn, i, j, cols, rows, format;
	gray	graymax;
	PIXEL	*p;
#define	CMAX	2000
	clock_t	t0, t1, t2, tf;
	FILE	*fp, *fp_l, *fp_r;
	int	n_matching_points = 0;
	int	verbose = 0;
	double	m;

	if (ac == 0) {
		fprintf(stderr, "usage: %s <pgm file>\n", av[0]);
		exit(2);
	}

	pgm_init(&ac, av);

	/*
	 * load file from left.pgm 
	 */

	fprintf(stderr, "read file\n");

	if ((fp_l = fopen(av[1], "r")) == NULL) {
		fprintf(stderr, "cant open image %s\n", av[1]);
		exit(2);
	}
	pgm_readpgminit(fp_l, &cols, &rows, &graymax, &format);

	/* check dimensions match those hardcoded */
	if ((cols != WIDTH) || (rows != HEIGHT)) {
		fprintf(stderr, "size mismatch\n");
		exit(3);
	}
	/* append the rows to 1d image in core */

#ifdef	PGM_BIGGRAYS
	for (p=left,i=0; i<HEIGHT; i++) {
		gray	temp[WIDTH];
		int	j;

		pgm_readpgmrow(fp_l, temp, cols, graymax, format);
		for (j=0; j<WIDTH; j++)
			*p++ = temp[j];
	}
#else
	for (p=left,i=0; i<HEIGHT; i++, p+=WIDTH)
		pgm_readpgmrow(fp_l, p, cols, graymax, format);
#endif

	t0 = clock();

	for (i=0; i<10; i++) {
		m = zncc(left, 100, 100, left, 100+i, 100);
		fprintf(stderr, "horizontal offset %d pix: m = %f\n", i, m);
	}
	for (i=0; i<NSAMPLE; i++)
		m = zncc(left, 100, 100, left, 50, 50);
	tf = clock();
	fprintf(stderr, "elapsed time %f us\n",
		(tf-t0)*1e6/CLOCKS_PER_SEC/NSAMPLE);
	fprintf(stderr, "m = %f\n", m);
}
#endif
