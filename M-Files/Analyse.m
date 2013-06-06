function Analyse

clear all;
close all;

%X = KrystianIdzieProsto;
LoadSkeleton;
X = SkeletonToArray(S);
X = FilterPoints(X);
X = X.Skeleton;

x = [min(X(:,1)) max(X(:,1))];
p = polyfit(X(:,1),X(:,2),1);
y = x * p(1) + p(2);

d = (atan(diff(X(:,2))./diff(X(:,1))) - atan(p(1)))/pi*180;

figure('units','normalized','outerposition',[0 0 1 1]);
subplot(211)
plot(X(:,1),X(:,2),'b-',x,y,'r-');
subplot(212)
plot(X(:,1),[0;d],'r');
end
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
function y = ff(x)
[B,A] = butter(3,0.06);
y = filtfilt(B,A,x);
end
function X = FilterPoints(S)
X = ApplyToSkeleton(@ff,S);
end