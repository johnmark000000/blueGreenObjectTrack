% SETTING UP THE VIDEO INPUT
% Capture the video frames using the videoinput function
vid = videoinput('winvideo', 1);

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 5;

% STARTING THE VIDEO ACQUISITION
start(vid)

% IMAGE PROCESSING AND OBJECT DETECTION LOOP
% Set a loop that stop after 100 frames of aquisition
while(vid.FramesAcquired <= 200)
    % Get the snapshot of the current frame
    data = getsnapshot(vid);

    % Now to track blue and green objects in real time
    % we have to subtract the blue and green component 
    % from the grayscale image to extract the blue and green components in the image. 
    blue_diff_im = imsubtract(data(:, :, 3), rgb2gray(data));
    green_diff_im = imsubtract(data(:, :, 2), rgb2gray(data));

    % Use a median filter to filter out noise
    blue_diff_im = medfilt2(blue_diff_im, [3 3]);
    green_diff_im = medfilt2(green_diff_im, [3 3]);
    
    % Convert the resulting grayscale image into a binary image.
    blue_diff_im = im2bw(blue_diff_im, 0.18);
    green_diff_im = im2bw(green_diff_im, 0.12);

    % Remove all those pixels less than 300px
    blue_diff_im = bwareaopen(blue_diff_im, 300);
    green_diff_im = bwareaopen(green_diff_im, 300);

    % Label all the connected components in the image.
    blue_bw = bwlabel(blue_diff_im, 8);
    green_bw = bwlabel(green_diff_im, 8);

    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    blue_stats = regionprops(blue_bw, 'BoundingBox', 'Centroid');
    green_stats = regionprops(green_bw, 'BoundingBox', 'Centroid');

    % Display the image
    imshow(data)

    hold on

    %This is a loop to bound the blue objects in a rectangular box.
    for object = 1:length(blue_stats)
        bb = blue_stats(object).BoundingBox;
        bc = blue_stats(object).Centroid;
        rectangle('Position',bb,'EdgeColor','b','LineWidth',2)
        plot(bc(1), bc(2), '-m+')
        a=text(bc(1)+15, bc(2), strcat('X: ', num2str(round(bc(1))), ' Y: ', num2str(round(bc(2)))));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color','yellow');
    end
    
    %This is a loop to bound the green objects in a rectangular box.
    for object = 1:length(green_stats)
        bb = green_stats(object).BoundingBox;
        bc = green_stats(object).Centroid;
        rectangle('Position',bb,'EdgeColor','g','LineWidth',2)
        plot(bc(1), bc(2), '-m+')
        a=text(bc(1)+15, bc(2), strcat('X: ', num2str(round(bc(1))), ' Y: ', num2str(round(bc(2)))));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color','yellow');
    end

    hold off
end
% Both the loops end here.

% STOPPING THE VIDEO ACQUISITION
stop(vid);

% CLEARING MEMORY AND VARIABLES
% Flush all the image data stored in the memory buffer.
flushdata(vid);

% Clear all variables
clear all
sprintf('%s','That was all about Image tracking, Guess that was pretty easy :) ')