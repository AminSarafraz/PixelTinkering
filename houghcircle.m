function [y0detect,x0detect,accumulator] = houghcircle(imBinary,r,thresh)
%HOUGHCIRCLE - detects circles with specific radius in a binary image. This
%is just a standard implementaion of Hough transform for circles in order
%to show how this method works.
%
%Comments:
%       Function uses Standard Hough Transform to detect circles in a binary image.
%       According to the Hough Transform for circles, each pixel in image space
%       corresponds to a circle in Hough space and vise versa. 
%       upper left corner of image is the origin of coordinate system.
%
%Usage: [y0detect,x0detect,accumulator] = houghcircle(imBinary,r,thresh)
%
%Arguments:
%       imBinary - A binary image. Image pixels with value equal to 1 are
%                  candidate pixels for HOUGHCIRCLE function.
%       r        - Radius of the circles.
%       thresh   - A threshold value that determines the minimum number of
%                  pixels that belong to a circle in image space. Threshold must be
%                  bigger than or equal to 4(default).
%
%Returns:
%       y0detect    - Row coordinates of detected circles.
%       x0detect    - Column coordinates of detected circles. 
%       accumulator - The accumulator array in Hough space.
%
%Written by :
%       Amin Sarafraz
%       Computer Vision Online 
%       http://www.computervisiononline.com
%
% Acknowledgement: Thanks to CJ Taylor and Peter Bone for their constructive comments
%
%May 5,2004         - Original version
%November 24,2004   - Modified version,faster and better performance (suggested by CJ Taylor)
%Aug 31,2012        - Implemented suggestion by Peter Bone/ Better documentation 

if nargin < 2
    error('HOUGHCIRCLE:: You must pass at least two arguments: imBinary and r.')
end

if nargin == 2
    thresh = 4; % set threshold to default value
end

if thresh < 4
    error('HOUGHCIRCLE:: Treshold value must be bigger than or equal to 4');
end

% Voting
accumulator = zeros(size(imBinary)); % initialize the accumulator
[yIndex xIndex] = find(imBinary); % find x,y of edge pixels
numRow = size(imBinary,1); % number of rows in the binary image
numCol = size(imBinary,2); % number of columns in the binary image
r2 = r^2; % to prevent its calculation in the loop

for cnt = 1:numel(xIndex)
    low=xIndex(cnt)-r;
    high=xIndex(cnt)+r;
    
    if (low<1) 
        low=1; 
    end
    
    if (high>numCol)
        high=numCol; 
    end
    
    for x0 = low:high
        yOffset = sqrt(r2-(xIndex(cnt)-x0)^2);
        y01 = round(yIndex(cnt)-yOffset);
        y02 = round(yIndex(cnt)+yOffset);
                
        if y01 < numRow && y01 >= 1
            accumulator(y01,x0) = accumulator(y01,x0)+1;
        end
        
        if y02 < numRow && y02 >= 1
            accumulator(y02,x0) = accumulator(y02,x0)+1;
        end
    end
end

% Finding local maxima in the accumulator
y0detect = []; x0detect = [];
accumulatorBinaryMax = imregionalmax(accumulator);
[y0potential x0potential] = find(accumulatorBinaryMax == 1);
accumulatorTemp = accumulator - thresh;
for cnt = 1:numel(y0potential)
    if accumulatorTemp(y0potential(cnt),x0potential(cnt)) >= 0
        y0detect = [y0detect;y0potential(cnt)];
        x0detect = [x0detect;x0potential(cnt)];
    end
end