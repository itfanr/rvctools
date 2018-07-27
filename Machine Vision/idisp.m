%IDISP	Interactive image display tool
%
%	IDISP(image)
%	IDISP(image, clip)
%	IDISP(image, clip, n)
%
%	Display the image in current figure and create buttons for:
%		* region zooming
%		* unzooming
%		* drawing a cross-section line.  Intensity along line will be
%		  displayed in a new figure.
%
%	Left clicking on a pixel will display its value in a box at the top.
%
%	The second form will limit the displayed greylevels.  If CLIP is a
%	scalar pixels greater than this value are set to CLIP.  If CLIP is
%	a 2-vector pixels less than CLIP(1) are set to CLIP(1) and those
%	greater than CLIP(2) are set to CLIP(2).  CLIP can be set to [] for
%	no clipping.
%	The N argument sets the length of the greyscale color map (default 64).
%
% SEE ALSO:	iroi, image, colormap, gray
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/idisp.m,v 1.3 2005/10/23 11:14:23 pic Exp $
% $Log: idisp.m,v $
% Revision 1.3  2005/10/23 11:14:23  pic
% Major restructure.  Userdata is now a structure.  Mods to support color
% in browser.
%
% Revision 1.2  2005/07/04 02:58:08  pic
% Handle color images.
%
% Revision 1.1.1.1  2002/05/26 10:50:21  pic
% initial import
%


function idisp(z, clip, ncmap)
	if nargin < 3,
		ncmap = 256;
	end

	if (nargin > 0) & ~isstr(z),
		% command line invocation, display the image

		clf
		scaleFactor = 1;

		if length(size(z)) == 2,
			% greyscale image
			colormap(gray(ncmap))
			n = ncmap;
			if nargin == 2,
				if length(clip) == 2,
					z(find(z<clip(1))) = clip(1);
					z(find(z>clip(2))) = clip(2);
				elseif length(clip) == 1,
					z(find(z>clip)) = clip;
				end
			end
		else
			% color image
			%colormap(gray(ncmap))
			%n = ncmap;
			if nargin == 2,
				if length(clip) == 2,
					z(find(z<clip(1))) = clip(1);
					z(find(z>clip(2))) = clip(2);
				elseif length(clip) == 1,
					z(find(z>clip)) = clip;
				end
			end
			if isa(z, 'double'),
				if max(z(:)) > 1,
					scaleFactor = 255;
					z = z / scaleFactor;
				end
			end
		end
		hi = imagesc(z);
		set(gcf,'ShareColors','off');
		set(hi, 'CDataMapping', 'scaled');
		htf = uicontrol(gcf, ...
				'style', 'text', ...
				'units',  'norm', ...
				'pos', [.6 .93 .4 .07], ...
				'string', '' ...
			);
		%ud = [gca htf hi axis scaleFactor];
		ud.h_axis = gca;
		ud.h_text = htf;
		ud.h_image = hi;
		ud.axis = axis;
		ud.scaleFactor = scaleFactor;
		set(gca, 'UserData', ud);
		set(hi, 'UserData', ud);

		hpb=uicontrol(gcf,'style','push','string','line', ...
			'units','norm','pos',[0 .93 .1 .07], ...
			'userdata', ud, ...
			'callback', 'idisp(''line'')');
		hzm=uicontrol(gcf,'style','push','string','zoom', ...
			'units','norm','pos',[.1 .93 .1 .07], ...
			'userdata', ud, ...
			'callback', 'idisp(''zoom'')');
		huz=uicontrol(gcf,'style','push','string','unzoom', ...
			'units','norm','pos',[.2 .93 .15 .07], ...
			'userdata', ud, ...
			'callback', 'idisp(''unzoom'')');

		set(hi, 'UserData', ud);
		set(gcf, 'WindowButtonDownFcn', 'idisp(''down'')');
		set(gcf, 'WindowButtonUpFcn', 'idisp(''up'')');
		return;
	end

% otherwise idisp() is being invoked on a GUI event

	if nargin == 0,
		% mouse push or motion request
		h = get(gcf, 'CurrentObject'); % image
		ud = get(h, 'UserData');		% axis

		cp = get(ud.h_axis, 'CurrentPoint');
		x = round(cp(1,1));
		y = round(cp(1,2));
		imdata = get(ud.h_image, 'CData');
		try,
			if length(size(imdata)) == 2,
				% greyscale
				if isa(imdata(y,x,:), 'uint8'),
					val = sprintf('%d', double(imdata(y,x)));
				else
					val = sprintf('%f', ud.scaleFactor*imdata(y,x));
				end
				s = sprintf('(%d, %d) = %s', x, y, val);
			else
				% color
				if isa(imdata(y,x,:), 'uint8'),
					val = sprintf('%d, ', double(imdata(y,x,:)));
				else
					val = sprintf('%f, ', ud.scaleFactor*imdata(y,x,:));
				end
				s = sprintf('(%d, %d) = %s', x, y, val);
			end
			set(ud.h_text, 'String', s);
			drawnow
		catch,
		end
	elseif nargin == 1,
		switch z,
		case 'down',
			% install pixel value inspector
			set(gcf, 'WindowButtonMotionFcn', 'idisp');
			idisp
			
		case 'up',
			set(gcf, 'WindowButtonMotionFcn', '');

		case 'line',
			h = get(gcf, 'CurrentObject'); % push button
			ud = get(h, 'UserData');

			set(ud.h_text, 'String', 'First point');
			[x1,y1] = ginput(1);
			x1 = round(x1); y1 = round(y1);
			set(ud.h_text, 'String', 'Last point');

			[x2,y2] = ginput(1);
			x2 = round(x2); y2 = round(y2);
			set(ud.h_text, 'String', '');

			imdata = get(ud.h_image, 'CData');
			dx = x2-x1; dy = y2-y1;
			if abs(dx) > abs(dy),
				x = x1:x2;
				y = round(dy/dx * (x-x1) + y1);
				figure
				plot(ud.scaleFactor*double(imdata(y+x*numrows(imdata))))
				grid on
			else
				y = y1:y2;
				x = round(dx/dy * (y-y1) + x1);
				figure
				plot(ud.scaleFactor*double(imdata(y+x*numrows(imdata))))
				grid on
			end
		case 'zoom',
			h = get(gcf, 'CurrentObject'); % push button
			ud = get(h, 'UserData');

			set(ud.h_text, 'String', 'First point');
			[x1,y1] = ginput(1);
			x1 = round(x1); y1 = round(y1);
			set(ud.h_text, 'String', 'Last point');

			[x2,y2] = ginput(1);
			x2 = round(x2); y2 = round(y2);
			set(ud.h_text, 'String', '');

			axes(ud.h_axis);
			axis([x1 x2 y1 y2]);
		case 'unzoom',
			h = get(gcf, 'CurrentObject'); % push button
			ud = get(h, 'UserData');

			axes(ud.h_axis);
			axis(ud.axis);		% restore orginal settings
		end
	end
