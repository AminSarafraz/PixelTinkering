function [pDetect,tetaDetect,accumulator] = houghline(imBinary,pStep,tetaStep,thresh)
%HOUGHLINE - detects lines in a binary image using common computer vision operation 
%known as the Hough Transform. This is just a standard implementaion of Hough transform 
%for lines in order to show how this method works.
%
%Comments:
%       Function uses Standard Hough Transform to detect Lines in a binary image.
%       According to the Hough Transform, each pixel in image space
%       corresponds to a line in Hough space and vise versa.This function uses
%       polar representation of lines i.e. x*cos(teta)+y*sin(teta)=p to detect 
%       lines in binary image. upper left corner of image is the origin of polar coordinate
%       system.
%
%Usage: [pDetect,tetaDetect,accumulator] = houghline(imBinary,pStep,tetaStep,thresh)
%
%Arguments:
%       imBinary - A binary image. image pixels that have value equal to 1 are
%                  interested pixels for HOUGHLINE function.
%       pStep    - Interval for radius of lines in polar coordinates.
%       tetaStep - Interval for angle of lines in polar coordinates.
%       thresh   - A threshold value that determines the minimum number of
%                  pixels that belong to a line in image space. threshold must 
%                  be bigger than or equal to 3(default).
%
%Returns:
%       pDetect     - A vactor that contains radius of detected lines in
%                     polar coordinates system.
%       tetaDetect  - A vector that contains angle of detcted lines in
%                     polar coordinates system.
%       accumulator - The accumulator array in Hough space.
%
%Written by :
%       Amin Sarafraz
%       Computer Vision Online 
%       http://www.computervisiononline.com
%
% Acknowledgement: Thanks to Nicolas HUOT for his comment
%
%May 5,2004         - Original version
%November 24,2004   - Modified version,slightly faster and better performance.
%August 31, 2012    - Error handling/ Better documentation/ Evaluating the comment by Nicolas HUOT
                          
if nargin < 3
    error('HOUGHLINE:: You must pass at least imBinary, pStep, and tetaStep.')
end

if nargin == 3
    thresh = 3;
end

if thresh < 3
    error('HOUGHLINE:: Threshold must be bigger than or equal to 3.')
end

p = 1:pStep:sqrt((size(imBinary,1))^2+(size(imBinary,2))^2);
teta = 0:tetaStep:180-tetaStep;

% Voting step
accumulator = zeros(length(p),length(teta)); % initialize the accumulator
[yIndex xIndex] = find(imBinary); % find x,y of edge pixels
for cnt = 1:numel(xIndex)
    indTeta = 0;
    for tetai = teta*pi/180
        indTeta = indTeta+1;
        roi = xIndex(cnt)*cos(tetai)+yIndex(cnt)*sin(tetai);
        if roi >= 1 && roi <= p(end)
            temp = abs(roi-p);
            minTemp = min(temp);
            indP = find(temp == minTemp);
            indP = indP(1);
            accumulator(indP,indTeta) = accumulator(indP,indTeta)+1;
        end
    end
end

% Finding local maxima in the accumulator
accumulatorBinaryMax = imregionalmax(accumulator);
[potentialP potentialTeta] = find(accumulatorBinaryMax == 1);
accumulatorTemp = accumulator - thresh;
pDetect = [];tetaDetect = [];
for cnt = 1:numel(potentialP)
    if accumulatorTemp(potentialP(cnt),potentialTeta(cnt)) >= 0
        pDetect = [pDetect;potentialP(cnt)];
        tetaDetect = [tetaDetect;potentialTeta(cnt)];
    end
end

% Calculating detected lines parameters(Radius & Angle)
pDetect = pDetect * pStep;
tetaDetect = tetaDetect *tetaStep - tetaStep;