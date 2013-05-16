function [bezierArray] = CreateBezierPoints (controlPoints,outputSegmentCount)
%exact curve for 5 control points only
%usage:
% in=[2 3; 7 8; 11 12; 3 4; 8 9]
% out = CreateBezierPoints(in,256);
%
%C# implementation:
%
%  private Point[] CreateBezierPoints(List<KinectLib.SkeletonNode> nodes, int outputSegmentCount)
%         {
%             Point[] points = new Point[outputSegmentCount + 1];
%             double tSpan = 1.0 / outputSegmentCount;
%             double tPos = 0;
% 
%             for (int i = 0; i < points.Length; i++)
%             {
%                 double temp = 1 - tPos;
%                 points[i].X = Math.Pow(temp, 5) * nodes.ElementAt(0).X +
%                     5 * tPos * Math.Pow(temp, 4) * nodes.ElementAt(1).X +
%                     10 * Math.Pow(tPos, 2) * Math.Pow(temp, 3) * nodes.ElementAt(2).X +
%                     5 * Math.Pow(tPos, 3) * Math.Pow(temp, 1) * nodes.ElementAt(3).X +
%                     Math.Pow(tPos, 5) * nodes.ElementAt(4).X;
%                 points[i].Y = Math.Pow(temp, 5) * nodes.ElementAt(0).Y +
%                     5 * tPos * Math.Pow(temp, 4) * nodes.ElementAt(1).Y +
%                     10 * Math.Pow(tPos, 2) * Math.Pow(temp, 3) * nodes.ElementAt(2).Y +
%                     5 * Math.Pow(tPos, 3) * Math.Pow(temp, 1) * nodes.ElementAt(3).Y +
%                     Math.Pow(tPos, 5) * nodes.ElementAt(4).Y;
%                 tPos += tSpan;
%             }
%             return points;
%         }
%

bezierArray=zeros(outputSegmentCount,2);
tSpan = 1/outputSegmentCount;
tPos = 0;
for i =1:length(bezierArray)
    temp = 1 - tPos;
    bezierArray(i,1) = temp^5 * controlPoints(1,1) + 5 * tPos * temp^4 * controlPoints(2,1) + 10 * tPos^2 * temp^3 * controlPoints(3,1) + 5 * tPos^3 * temp * controlPoints(4,1) + tPos^5 * controlPoints(5,1);
    bezierArray(i,2) = temp^5 * controlPoints(1,2) + 5 * tPos * temp^4 * controlPoints(2,2) + 10 * tPos^2 * temp^3 * controlPoints(3,2) + 5 * tPos^3 * temp * controlPoints(4,2) + tPos^5 * controlPoints(5,2);
tPos = tPos + tSpan;
end
plotBezier(controlPoints,bezierArray);
end
%%
function [] = plotBezier (in,out)
plot(in(:,1),in(:,2),'o')
hold
plot(out(:,1),out(:,2),'r.')
end