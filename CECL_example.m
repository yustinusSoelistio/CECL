% Circular-based Eye Center Localization (CECL) example
% Based on paper: 
% Author: Yustinus Eko Soelistio, Eric Postma, Alfons Maes
% Last update: Dec. 11, 2014

for imageNumber = 1:4
    imageFile = ['test' num2str(imageNumber) '.pgm'];
    image = imread(imageFile);

    [x1, y1, r1, x2, y2, r2] = CECL(image);    

    figure(1), imshow(image), title(imageFile), hold on, viscircles([x1 y1], r1, 'EdgeColor', 'g', 'LineWidth', 1), hold on; viscircles([x2 y2], r2, 'EdgeColor', 'g', 'LineWidth', 1), hold off;
    pause;    
end