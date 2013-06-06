function MovementDetection(X)

if nargin < 1, LoadSkeleton; X = SkeletonToArray(S); X = X.Skeleton; end;


close all;

%v = sqrt(sum(diff(X).^2,2))*30;
xx =diff(X).^2;
v =  sqrt(xx(:,1)+xx(:,3))*30;

t = (0:length(v)-1)/30;


%filter velocity

figure('units','normalized','outerposition',[0 0 1 1]);
subplot(211);
plot(-X(1,1),X(1,3),'b-');
xlim([min(-X(:,1)),max(-X(:,1))]);
ylim([min(X(:,3)),max(X(:,3))]);
axis square;
subplot(212);
plot(t(1),v(1),'r','linewidth',2);
xlim([0,t(end)]);
ylim([0,max(v)]);
title('v(t)');
ylabel('velocity, m/s');
xlabel('time, s');

pause
for k = 1 : length(v)
    subplot(211);
    ch = get(gca,'Children');
    set(ch(1),'xdata',-X(1:k,1),'ydata',X(1:k,3));
    drawnow;
    subplot(212);
    ch = get(gca,'Children');
    set(ch(1),'xdata',t(1:k),'ydata',v(1:k));
    drawnow;
    %pause(1/60);
end

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