%%
function A = PreProcessing()
close all;

S = [];
LoadSkeleton;
A = SkeletonToArray(S);
%TakePoints
A = TakePoints(A,1280,1387);
%FilterPoints
A = FilterPoints(A);
%Get tan(fi) of move direction
    Fi = FindDirection(A.Skeleton);

    %Fi = diff(A.Skeleton(:,3))./diff(A.Skeleton(:,1));
    %Fi = [Fi(1,:);Fi];
%SkeletonShiftToCrotch
A = ShiftToCrotch(A);
%Project
A = ProjectOnPlane(A,Fi);

figure('units','normalized','outerposition',[0 0 1 1]);
pause
Boundary = GetBoundaryFromSkeleton(A);
for k = 1 : length(A.Crotch)
    DrawSkeleton(A,k,Boundary);
    pause(0.1);
    drawnow;
end
%LeftLegSegment = sqrt((S.LeftHip.X-S.LeftKnee.X).^2 + (S.LeftHip.Y - S.LeftKnee.Y).^2 + (S.LeftHip.Z - S.LeftKnee.Z).^2);
%RightLegSegment = sqrt((S.RightHip.X-S.RightKnee.X).^2 + (S.RightHip.Y - S.RightKnee.Y).^2 + (S.RightHip.Z - S.RightKnee.Z).^2);
end
%%
function X = ApplyToSkeleton(fun,S)
X.Crotch = fun(S.Crotch);
X.Spine = fun(S.Spine);
X.Neck = fun(S.Neck);
X.Head = fun(S.Head);
X.LeftShoulder = fun(S.LeftShoulder);
X.LeftElbow = fun(S.LeftElbow);
X.LeftHand = fun(S.LeftHand);
X.LeftFingers = fun(S.LeftFingers);
X.LeftHip = fun(S.LeftHip);
X.LeftKnee = fun(S.LeftKnee);
X.LeftAnckle = fun(S.LeftAnckle);
X.LeftFoot = fun(S.LeftFoot);
X.RightShoulder = fun(S.RightShoulder);
X.RightElbow = fun(S.RightElbow);
X.RightHand = fun(S.RightHand);
X.RightFingers = fun(S.RightFingers);
X.RightHip = fun(S.RightHip);
X.RightKnee = fun(S.RightKnee);
X.RightAnckle = fun(S.RightAnckle);
X.RightFoot = fun(S.RightFoot);
X.Skeleton = fun(S.Skeleton);
end
%%
function X = SkeletonToArray(S)
f = @(x) cell2mat(struct2cell(x)');
X = ApplyToSkeleton(f,S);
end
%%
function X = TakePoints(S,From,To)
f = @(x) x(From:To,:);
X = ApplyToSkeleton(f,S);
end
%%
function X = ShiftToCrotch(S)
f = @(x) x - S.Crotch;
X = ApplyToSkeleton(f,S);
end
%%
function X = ProjectOnPlane(S,Fi)
f = @(x) [(x(:,1) - x(:,3).*Fi)./sqrt(1+Fi.^2) x(:,2)];
X = ApplyToSkeleton(f,S);
end
%%
function y = ff(x)
[B,A] = butter(3,0.06);
y = filtfilt(B,A,x);
end
function X = FilterPoints(S)
X = ApplyToSkeleton(@ff,S);
end
%%
function B = GetBoundaryFromSkeleton(S)
B.Min = cell2mat(struct2cell(ApplyToSkeleton(@min,S)));
B.Max = cell2mat(struct2cell(ApplyToSkeleton(@max,S)));

B.Min = min(B.Min(1:end-1,:));
B.Max = max(B.Max(1:end-1,:));
end
%%
function DrawSkeleton(A,Point,Boundary)
X = [
    A.LeftFoot(Point,:);
    A.LeftAnckle(Point,:);
    A.LeftKnee(Point,:);
    A.LeftHip(Point,:);
    A.Crotch(Point,:);
    A.RightHip(Point,:);
    A.RightKnee(Point,:);
    A.RightAnckle(Point,:);
    A.RightFoot(Point,:);
%     A.LeftFingers(Point,:);
%     A.LeftHand(Point,:);
%     A.LeftElbow(Point,:);
%     A.LeftShoulder(Point,:);
%     A.RightFingers(Point,:);
%     A.RightHand(Point,:);
%     A.RightElbow(Point,:);
%     A.RightShoulder(Point,:);
%     A.Head(Point,:);
%     A.Neck(Point,:);
%     A.Spine(Point,:);
    ];
plot(X(:,1),X(:,2),'-');
xlim([Boundary.Min(1) Boundary.Max(1)]);
ylim([Boundary.Min(2) Boundary.Max(2)]);
axis square;
end
%%
function p = FindDirection(X)
x = [min(X(:,1)) max(X(:,1))];
p = polyfit(X(:,1),X(:,3),1);
% y = x * p(1) + p(2);
% plot(X(:,1),X(:,3),'b',x,y,'r');
% axis square;
p = p(1);
end