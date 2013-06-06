function Y = GetBezier(Nodes,N)
%Head-Neck-RightElbow-Crotch-LeftKnee-LeftToes-LeftAnckle
%N something like 100

Nodes = Nodes(:);
n = length(Nodes)-1;

t = linspace(0,1,N)';

Y = zeros(N,1);
for k = 0 : n
    Y = Y + nchoosek(n,k)*t.^k.*(1-t).^(n-k)*Nodes(k+1);
end