function X = rescale_x(X, newMin, newMax)

xmin = min(X(:));
xmax = max(X(:));

scale = (newMax - newMin) / (xmax - xmin);

X = (X - xmin) * scale + newMin;

end
