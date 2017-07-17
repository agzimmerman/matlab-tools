function [Grad_I] = gradientOfScatteredInterpolant( Interpolant )
%%GRADIENTOFSCATTEREDINTERPOLANT computes the gradient of the interpolant.
%   The scattered interolant is sampled onto a dense tensor-structured grid
%   which is used to compute the gradients. Then a new scatteredInterpolant
%   is made from the original sample space, which is probably a terrible
%   idea.
%
% @todo: Is this working correctly at all? Is there a way to create less
% noise?
X = Interpolant.Points(:,1);
Y = Interpolant.Points(:,2);
% Structure the data.
XUnique = sort(unique(X));
YUnique = sort(unique(Y));
[XGrid, YGrid] = meshgrid(XUnique, YUnique);
I = Interpolant(XGrid, YGrid);
[Grad_I{1}, Grad_I{2}]  = gradient(I);
% Scatter the data again to preserve the size of the data.
for i = 1:2
    Grad_I{i} = scatteredInterpolant(X, Y,...
        interp2(XGrid, YGrid, Grad_I{i}, X, Y),...
        Interpolant.Method, Interpolant.ExtrapolationMethod);
end
end