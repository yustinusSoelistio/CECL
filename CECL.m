% Circular-based Eye Center Localization (CECL)
% Based on paper: 
% Author: Yustinus Eko Soelistio, Eric Postma, Alfons Maes
% Last update: Dec. 11, 2014
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
% face  : merge threshold value for Viola Jones face detector (default: 20)
% right  : merge threshold value for Viola Jones right eye detector (default: 10)
% left  : merge threshold value for Viola Jones left eye detector (default: 10)

% -----------------------------------------------------------------------------------------------------
function [positionX1, positionY1, rad1, positionX2, positionY2, rad2] = CECL(image, npr, gs, t, cp, bc, rminr, rmaxr, cs, r, face, right, left)
% -----------------------------------------------------------------------------------------------------
    % Prepare image
    raw = image;

    % Check arguments
    if nargin > 13
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
            face = 20;
            right = 10;
            left = 10;
        case 2        
            gs = 0.02 * length(raw);
            t = 14;
            cp = 3;
            bc = 0;
            rminr = 8;
            rmaxr = 15;
            cs = 0.95;
            r = 1;
            face = 20;
            right = 10;
            left = 10;
        case 3        
            t = 14;
            cp = 3;
            bc = 0;
            rminr = 8;
            rmaxr = 15;
            cs = 0.95;
            r = 1;
            face = 20;
            right = 10;
            left = 10;
        case 4        
            cp = 3;
            bc = 0;
            rminr = 8;
            rmaxr = 15;
            cs = 0.95;
            r = 1;
            face = 20;
            right = 10;
            left = 10;
        case 5        
            bc = 0;
            rminr = 8;
            rmaxr = 15;
            cs = 0.95;
            r = 1;
            face = 20;
            right = 10;
            left = 10;
        case 6        
            rminr = 8;
            rmaxr = 15;
            cs = 0.95;
            r = 1;
            face = 20;
            right = 10;
            left = 10;
        case 7        
            rmaxr = 15;
            cs = 0.95;
            r = 1;
            face = 20;
            right = 10;
            left = 10;
        case 8
            cs = 0.95;
            r = 1;
            face = 20;
            right = 10;
            left = 10;
        case 9        
            r = 1;
            face = 20;
            right = 10;
            left = 10;
        case 10            
            face = 20;
            right = 10;
            left = 10;
        case 11            
            right = 10;
            left = 10;
        case 12            
            left = 10;
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
    
    % ------------------
    % EYE DETECTION STEP
    % ------------------
    % Setup detector   
    faceDetector = vision.CascadeObjectDetector('FrontalFaceCART','MergeThreshold',face);
    rightEyeDetector = vision.CascadeObjectDetector('RightEyeCART','MergeThreshold',right);
    leftEyeDetector =  vision.CascadeObjectDetector('LeftEyeCART','MergeThreshold',left);
    % ------------------
    % Detect face
    fprintf('Face detection\n');
    rawFace = wiener2(raw, [5 5]); % Filter noise from original image
    boxFace = step(faceDetector, rawFace);
    detectedFace = raw(boxFace(2):boxFace(2)+boxFace(4), boxFace(1):boxFace(1)+boxFace(3));
    % ------------------
    % Split face
    rightFace = detectedFace(1:round(size(detectedFace,1) * 3 / 5), 1:round(size(detectedFace,2) / 2));
    leftFace = detectedFace(1:round(size(detectedFace,1) * 3 / 5), round(size(detectedFace,2) / 2):end);
    % ------------------
    % Localize eyes
    fprintf('Left eye detection\n');
    boxLeftEye = step(leftEyeDetector, leftFace);
    fprintf('Right eye detection\n');
    boxRightEye = step(rightEyeDetector, rightFace);    
    % ------------------
    % Crop eyes
    fprintf('Left eye cropping\n');        
    leftEye = imcrop(leftFace, boxLeftEye);    
    fprintf('Right eye cropping\n');
    rightEye = imcrop(rightFace, boxRightEye);
    % ------------------
    
    % Run CECL_eye_only
    fprintf('Left eye CECL\n');
    [positionX1 positionY1 rad1] = CECL_eyeOnly(leftEye, npr, gs, t, cp, bc, rminr, rmaxr, cs, r);
    fprintf('Right eye CECL\n');
    [positionX2 positionY2 rad2] = CECL_eyeOnly(rightEye, npr, gs, t, cp, bc, rminr, rmaxr, cs, r);
    % -----------------                   
    
    % Map to position
    positionX1 = positionX1 + boxFace(1) + round(size(detectedFace,2) / 2) + boxLeftEye(1);
    positionY1 = positionY1 + boxFace(2) + boxLeftEye(2);    
    positionX2 = positionX2 + boxFace(1) + boxRightEye(1);
    positionY2 = positionY2 + boxFace(2) + boxRightEye(2);    
    % ----------------
end