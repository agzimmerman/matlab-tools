function [ p ] = convergenceOrder( r, f1, f2, f3 )
%CONVERGENCEORDER estimates the empirical order of convergence
%   r is the grid refinement ratio.
%   f1, f2, and f3 are norms of the the fine, medium, and coarse solutions.
%
%   This assumes that the solution is in the asymptotic range of 
%   convergence. If the calculated order is far from the theoretical order,
%   check that the grid is refined enough to be in the asymptotic range.
%
%   The norm can be an error norm such as L2 or RMS, or is can be some
%   other scalar quantity of interest.
%
%   See: https://www.grc.nasa.gov/WWW/wind/valid/tutorial/spatconv.html
p = log((f3 - f2)/(f2 - f1))/log(r);
end
