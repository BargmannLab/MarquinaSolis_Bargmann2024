%% Lawn edge detection
function [ edge_x, edge_y ] = edge_detection(background,th)

    % Detect edges on the image
    BW = edge(background,'sobel',th,'nothinning');
    BW2 = bwareaopen(BW, 2000); % Get rid of schmutz
    [edge_y, edge_x] = find(BW2);

    % Dilate the image
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    BW2dil = imdilate(BW2, [se90 se0]);

    % Remove connected objects on border
    BWnobord = imclearborder(BW2dil, 8);

    % Fill interior gaps
    BWdfill = imfill(BWnobord, 'holes');

    % Smooth the object
    seD = strel('diamond',1);
    BWfinal = imerode(BWdfill,seD);
    BWfinal = imerode(BWfinal,seD);

    % Select the region in which to find the boundary
    imshow(BWfinal); hold on; 
    H = imfreehand;
    Position = wait(H);
    pos_x = Position(:,1); pos_y = Position(:,2);

    % Find  edge pixels which fall inside the polygon specified by imfreehand
    in = inpolygon(edge_x,edge_y,pos_x,pos_y);
    scatter(edge_x(in),edge_y(in),10,'b');  %these points are inside the drawn polygon;
    inside_x = edge_x(in);
    inside_y = edge_y(in);

    % Obtain the convex hull of the perimeter
    K = convhull(inside_x,inside_y, 'Simplify', false);
    % scatter(inside_x(K), inside_y(K),25,'r+');
    
    edge_x = inside_x(K); edge_y = inside_y(K);
    close all;
    
end
