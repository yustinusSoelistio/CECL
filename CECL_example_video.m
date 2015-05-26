% Circular-based Eye Center Localization (CECL) example (video)
% Based on paper: 
% Author: Yustinus Eko Soelistio, Eric Postma, Alfons Maes
% Last update: Dec. 11, 2014

% fileName = 'test.avi';
fileName = '/media/yustinus/ECDE7088DE704D38/DATA/Data S3/Processed/D2/Watching/R1/D2-R1-Watch-Neutral.mp4';
videoFrame = vision.VideoFileReader(fileName);
frameInImage = step(videoFrame);

while ~isDone(videoFrame)    
    image = frameInImage;    
%     image = imresize(image, [160 240]);
    [x1, y1, r1, x2, y2, r2] = CECL(rgb2gray(image));
    figure(1), imshow(image), title(fileName), hold on, viscircles([x1 y1], r1, 'EdgeColor', 'g', 'LineWidth', 1), hold on; viscircles([x2 y2], r2, 'EdgeColor', 'g', 'LineWidth', 1), hold off;
    frameInImage = step(videoFrame);
end