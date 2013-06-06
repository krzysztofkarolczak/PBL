function [bezierArray] = GetBezierApproximation (controlPoints, outputSegmentCount)
%approximation for any number of control points
%
%C# implementation:
%
%         PolyLineSegment GetBezierApproximation(Point[] controlPoints, int outputSegmentCount)
%         {
%             Point[] points = new Point[outputSegmentCount + 1];
%             for (int i = 0; i <= outputSegmentCount; i++)
%             {
%                 double t = (double)i / outputSegmentCount;
%                 points[i] = GetBezierPoint(t, controlPoints, 0, controlPoints.Length);
%             }
%             return new PolyLineSegment(points, true);
%         }
% 
%         Point GetBezierPoint(double t, Point[] controlPoints, int index, int count)
%         {
%             if (count == 1)
%                 return controlPoints[index];
%             var P0 = GetBezierPoint(t, controlPoints, index, count - 1);
%             var P1 = GetBezierPoint(t, controlPoints, index + 1, count - 1);
%             return new Point((1 - t) * P0.X + t * P1.X, (1 - t) * P0.Y + t * P1.Y);
%         }

bezierArray=zeros(outputSegmentCount+1,2);
for i=1:outputSegmentCount+1
  t = (i-1)/outputSegmentCount;
  
  bezierArray(i,:) = GetBezierPoint(t,controlPoints,1,length(controlPoints));
end
plotBezier(controlPoints,bezierArray);
end
%%
function [point] = GetBezierPoint (t,controlPoints,index,count)
point=zeros(1,2);
if count == 1
    point = controlPoints(index,:);
else
    P0=GetBezierPoint(t, controlPoints, index, count -1);
    P1=GetBezierPoint(t, controlPoints, index+1, count -1);
    point(1,1) = (1-t)* P0(1,1) + t*P1(1,1);
    point(1,2) = (1-t)* P0(1,2) + t*P1(1,2);

end
end
%%
function [] = plotBezier (in,out)
plot(in(:,1),in(:,2),'o')
hold
plot(out(:,1),out(:,2),'r.')
end





