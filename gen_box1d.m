function X = gen_box1d(nbx, dist)

switch dist
case 0
   X = linspace(-1.0, 1.0, nbx+1);
case 1 % second kind, includes end points
   X = cos(pi * (0:nbx) / nbx);
case 2
   [X, ~] = zwgll(nbx);
end

