%IROI	Extract region of interest from current image figure
%
%	si = iroi(image)
%	[si,region] = iroi(image)
%
%	si = IROI(image,region)
%
%	The first two forms display the image and a rubber band box to
%	allow selection of the region of interest.
%	The selected subimage is output and optionally the coordinates of 
%	the region selected which is of the form [top bottom; left right].
%
%	The last form is non-interactive and uses a previously created 
%	region matrix and outputs the corresponding subimage.  Useful for 
%	chopping the same region out of	a different image.
%
%
% SEE ALSO:	iclip, idisp
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% 1995 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/iroi.m,v 1.3 2005/10/20 11:13:23 pic Exp $
% $Log: iroi.m,v $
% Revision 1.3  2005/10/20 11:13:23  pic
% Handle multi-plane images.
%
% Revision 1.2  2002/05/26 10:55:55  pic
% Work with multi-plane, color, image.
%
% Revision 1.1.1.1  2002/05/26 10:50:22  pic
% initial import
%


function [im, region] = iroi(image, reg)

	if nargin == 2,
		im = image(reg(1,1):reg(2,1),reg(1,2):reg(2,2),:);
	else
		% save old event handlers, otherwise may interfere with
		% other tools operating on the figure, eg. idisp()

		clf
		imagesc(image);

		upfunc = get(gcf, 'WindowButtonUpFcn');
		downfunc = get(gcf, 'WindowButtonDownFcn');
		set(gcf, 'WindowButtonUpFcn', '');
		set(gcf, 'WindowButtonDownFcn', '');

		% get the rubber band box
		waitforbuttonpress
		%fprintf('got button 1\n');
		f = gcf;
		cp0 = get(gcf, 'CurrentPoint');
		c0 = floor( get(gca, 'CurrentPoint') );		% top left
		rect = [cp0 16 16];
		rbbox(rect, cp0);			% return on up click

		%disp('rbbox done, restore handlers');

		% restore event handlers
		set(gcf, 'WindowButtonUpFcn', upfunc);
		set(gcf, 'WindowButtonDownFcn', downfunc);

		c1 = floor( get(gca, 'CurrentPoint') );		% bottom right

		ax = get(gca, 'Children');
		img = get(ax, 'CData');			% get the current image

		top = c0(1,2);
		left = c0(1,1);
		bot = c1(1,2);
		right = c1(1,1);
		im = img(top:bot,left:right,:);
		if nargout == 2,
			region = [top left; bot right];
		end
	end

