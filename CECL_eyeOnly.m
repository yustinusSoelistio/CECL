% Circular-based Eye Center Localization (CECL)
% Based on paper: 
% Author: Yustinus Eko Soelistio, Eric Postma, Alfons Maes
% Last update: Oct. 23, 2014
%
% The function takes arguments:
% image : grayscale image matrix
% npr   : Gaussian filter radius (default: 5)
% gs    : Gaussian standard deviation (default: Default: 0.02 * length(image))
% t     : threshold for binary transformation based on image median intensity (default: 14)
% cp    : clossing morphology connectivity (default: 3)
% bc    : remove eye brow (remove bc% of image height from the top) (default: 0)
% rminr : minimum radius for circle detection (default: 8)
% rmaxr : maximum radius for circle detection (default: 15)
% cs    : circle detection sensitivity (default: 0.95)
% r     : radius for fine tunning the detected circle (default: 1)

% -----------------------------------------------------------------------------------------------------
function [maxPositionX, maxPositionY, rad] = CECL_eyeOnly(image, npr, gs, t, cp, bc, rminr, rmaxr, cs, r)
% -----------------------------------------------------------------------------------------------------
    % Prepare image
    raw = image;

    % Check arguments
    if nargin > 10
        error('Too many inputs');
    end
    switch nargin
        case 1
            npr = 5;
            gs = 0.02 * length(raw);
            t = 14;
            cp = 3;
            bc = 0;
            rminr = 8;
            rmaxr = 15;
            cs = 0.95;
            r = 1;
        case 2        
            gs = 0.02 * length(raw);
            t = 14;
            cp = 3;
            bc = 0;
            rminr = 8;
            rmaxr = 15;
            cs = 0.95;
            r = 1;
        case 3        
            t = 14;
            cp = 3;
            bc = 0;
            rminr = 8;
            rmaxr = 15;
            cs = 0.95;
            r = 1;
        case 4        
            cp = 3;
            bc = 0;
            rminr = 8;
            rmaxr = 15;
            cs = 0.95;
            r = 1;
        case 5        
            bc = 0;
            rminr = 8;
            rmaxr = 15;
            cs = 0.95;
            r = 1;
        case 6        
            rminr = 8;
            rmaxr = 15;
            cs = 0.95;
            r = 1;
        case 7        
            rmaxr = 15;
            cs = 0.95;
            r = 1;
        case 8
            cs = 0.95;
            r = 1;
        case 9        
            r = 1;
    end



    % ------------------------
    % SET ALL GLOBAL VARIABLES
    % ------------------------
    % Variables for Gaussian filter
    noisePixelRadius = npr; % Default: 5
    gaussSigma = gs; % Default: 0.02 * length(raw)
    % Variables for "binary" filter
    threshold = t; % Default: 14
    closingParameter = cp; % Default: 3
    % Remove eyebrow (optional: only used when the original image include eyebrow.  Recommended value for Viola-Jones eye detection: 22 - 40)
    browCut = bc; % Default: 0
    % Variables for circle detection
    rMinRadius = rminr; % Default: 8
    rMaxRadius = rmaxr; % Default: 15
    circleSensitivity = cs; % Default: 0.95
    % Variables to fine tuning circle center (Recommended value: 0.6 - 0.8)
    radius = r; % Default: 1
    % ------------------------


    % -------------------
    % PRE-PROCESSING STEP
    % -------------------
    fprintf('Pre-processing\n');
    % Filter noises
    filter = fspecial('gaussian',[noisePixelRadius noisePixelRadius], gaussSigma);
    im = imfilter(raw, filter);
    % -------------------
    % Increase contrast
    im = imadjust(im);
    % -------------------
    % Change to binary                              
    med = median(double(im(:)));                        
    imBW = im2bw(im, med / 255 * threshold / 100);
    % -------------------
    % Remove small object
    imBW = ~imBW;
    imBW = bwareaopen(imBW, closingParameter);
    imBW = ~imBW;
    % -------------------                       
    % Remove eyebrow
    for i = 1:ceil(browCut / 100 * size(imBW,2))
        for j = 1:size(imBW,2)
            imBW(i,j) = 1;
        end
    end
    % -------------------           
    % Fill hole in blob object               
    imBW = bwmorph(imBW, 'clean');
    imBW = ~imBW;
    imBW = bwmorph(imBW, 'majority');
    imBW = ~imBW;
    % -------------------


    % -------------------
    % IRIS DETECTION STEP
    % -------------------
    fprintf('Iris detection\n');
    % Find circular object
    Rmin = ceil(rMinRadius / 100 * size(imBW,2));
    Rmax = round(rMaxRadius / 100 * size(imBW,2)) + 1;
    if Rmax < Rmin
        Rmax = Rmin;
    end
    [centersDarkEye, radiiDarkEye] = imfindcircles(imBW,[Rmin Rmax],'ObjectPolarity','dark', 'Method', 'twostage', 'Sensitivity', circleSensitivity);
    % -------------------
    % Locate smallest circle
    if size(centersDarkEye,1) >= 1
        [irisRadiusEye irisRadiusPositionEye] = min(radiiDarkEye);
        irisLocationEye = centersDarkEye(irisRadiusPositionEye,:);
    % -------------------
        % Fine tunning the cicle center
        fprintf('Fine tunning\n');
        irisRadiusEye = irisRadiusEye * radius;
        % -------------------
        % Create a box with width = radius
        boxCircle = [(irisLocationEye(1) - irisRadiusEye) (irisLocationEye(2) - irisRadiusEye) (irisRadiusEye * 2) (irisRadiusEye * 2 )];
        im = imcrop(raw, boxCircle);                                            
        % -------------------
        % Finding the darkest pixel
        darkestRightEye = 256;
        maxPositionX = 0;
        maxPositionY = 0;
        for i = 1:size(im, 1)
            for j = 1:size(im, 2)
                if im(i,j) <= darkestRightEye
                    darkestRightEye = im(i,j);
                    maxPositionX = i;
                    maxPositionY = j;
                end
            end
        end        
        maxPositionX = maxPositionX + boxCircle(1);
        maxPositionY = maxPositionY + boxCircle(2);        
        % -------------------
    else                                   
        % Guessing if no circle found
        maxPositionX = size(im,1) / 2;
        maxPositionY = size(im,2) / 2;                            
        % -------------------
    end
    
    rad = irisRadiusEye;
   
% -----------------------------------------------------------------------------------------------------    
end