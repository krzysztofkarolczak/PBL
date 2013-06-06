function [BezierX BezierY] = ComputeBezierStatistic(KeyFrames)
%Head-Neck-RightElbow-Crotch-LeftKnee-LeftToes-LeftAnckle
%4-3-13-1-10-12-11
Nodes = KeyFrames([4 3 13 1 10 12 11],:);

BezierX = std(GetBezier(Nodes(:,1),100));
BezierY = std(GetBezier(Nodes(:,2),100));