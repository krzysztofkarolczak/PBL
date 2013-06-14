function RotationProcessing()
close all;

S = [];
f_name=strcat('run samples/grzes.m');
eval(f_name);
A = SkeletonToArray(S);
A = FilterPoints(A);

%GetVelocity
v1 = [0;diff(A.Crotch(:,1))];
v2 = [0;diff(A.Crotch(:,2))];
v3 = [0;diff(A.Crotch(:,3))];
samples = (sqrt(v1.^2+v2.^2+v3.^2) - 0.01) > 0;
%close all;
%figure('units','normalized','outerposition',[0 0 1 1]);
%subplot(411),plot(v1);
%subplot(412),plot(v2);
%subplot(413),plot(v3);
%subplot(414),plot(sqrt(v1.^2+v2.^2+v3.^2));hold on; plot([0 3655],0.01*[1 1],'r'); plot(max(sqrt(v1.^2+v2.^2+v3.^2)) * ((sqrt(v1.^2+v2.^2+v3.^2) - 0.01) > 0),'m')
%return;
%plot(v),return

A = ShiftToCrotch(A);
Floor = FindFloorVector(A);

% disp(Floor);
% disp(Floor2);
% return

h = waitbar(0,'Please wait rotating...');
C = length(A.Skeleton);
C = 1;

Frames = zeros(C,20,2);
for frame = 1 : C
    LH = A.LeftHip(frame,:);
    RH = A.RightHip(frame,:);
    Back = inv([Floor';LH;RH])*[0;1;1];

    Move = cross(Floor,Back);

    dot(Floor,Back)
    dot(Floor,Move)
    dot(Back,Move)

    [X,Y] = meshgrid(-1:0.1:1);
    ZF = -Floor(1)/Floor(3)*X -Floor(2)/Floor(3)*Y;
    ZB = -Back(1)/Back(3)*X -Back(2)/Back(3)*Y;
    ZM = -Move(1)/Move(3)*X -Move(2)/Move(3)*Y;

    sk = cell2mat(struct2cell(ApplyToSkeleton(@(x) x(frame,:),A)));
    LH = LH - sk(1,:);
    RH = RH - sk(1,:);
    sk = sk(1:end-1,:);% - repmat(sk(1,:),20,1);

    %project on plane Move
    M = repmat(Move'/norm(Move),20,1);
    sk_p = sk - repmat(sum(M.*sk,2),1,3).*M;

    %axis
    F_ = Floor/norm(Floor);
    B_ = Back/norm(Back);

    P_ = zeros(20,2);
    for k = 1 : 20
        P_(k,:) = ([F_ B_]\sk_p(k,:)')';
    end
    Frames(frame,:,:) = P_;
    %waitbar(frame/C);
end
close(h) 

%h = waitbar(0,'Please wait: drawing...');
SkFrames = zeros(C,29,2);
Order = [8 7 6 5 3 4 3 13 14 15 16 15 14 13 3 2 1 9 10 11 12 11 10 9 1 17 18 19 20];
for frame = 1 : C
    SkFrames(frame,:,1) = Frames(frame,Order,1);
    SkFrames(frame,:,2) = Frames(frame,Order,2);
    %waitbar(frame/C);
end
%close(h) 

close all;
figure('units','normalized','outerposition',[0 0 1 1]);
    
if 1
    %subplot(121)
    hold on;
    %surf(X,Y,ZF,'FaceColor','black','EdgeColor','none'); alpha 0.3;
    %surf(X,Y,ZB,'FaceColor','black','EdgeColor','none'); alpha 0.3;
    surf(X,Y,ZM,'FaceColor','black','EdgeColor','none'); alpha 0.3;
    plot3(sk(:,1),sk(:,2),sk(:,3),'ro','LineWidth',2);
    %plot3(LH(1),LH(2),LH(3),'k*');
    %plot3(RH(1),RH(2),RH(3),'k*');
    %plot3(sk_p(:,1),sk_p(:,2),sk_p(:,3),'b.','LineWidth',4);
    %plot3([0 F_(1)],[0,F_(2)],[0,F_(3)],'k');
    %plot3([0 B_(1)],[0,B_(2)],[0,B_(3)],'k');
    axis equal
    
    %subplot(122)
    %plot(-P_(:,2),P_(:,1),'b*');
    %axis equal
    return
end

P_ = zeros(29,2);
P_(:,:) = SkFrames(1,:,:);
h_s = plot(sign(P_(16,2))*P_(:,2),P_(:,1),'b-');
axis square;
axis equal;
xlim([-0.5 0.5]), ylim([-1,1]);
h_t = title('1');  
pause
for frame = 2 : C
    if (samples(frame) > 0 && sign(v1(frame)) < 0)
        P_(:,:) = SkFrames(frame,:,:);
        %subplot(321)
        set(h_s,'XData',sign(P_(16,2))*P_(:,2));
        set(h_s,'YData',P_(:,1));
        set(h_t,'String',num2str(frame));
        drawnow;
    end
%     subplot(312)
%     plot(v(1:frame));
%     subplot(313)
%     plot(a(1:frame));
    %pause(0.1);
end

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
function X = ShiftToCrotch(S)
f = @(x) x - S.Crotch;
X = ApplyToSkeleton(f,S);
end
%%
function X = FindFloorVector(A)
L = size(A.Skeleton,1);
LF = A.LeftAnckle;
RF = A.RightAnckle;
X = [RF(:,1) LF(:,1)];
Y = [RF(:,2) LF(:,2)];
Z = [RF(:,3) LF(:,3)];
T = 1 : L + (diff(Y,1,2) > 1) * L;
X = [X(T') Y(T') Z(T')];
X = X\-ones(L,1);
end
%%
function y = ff(x)
[B,A] = butter(3,0.06);
y = filtfilt(B,A,x);
end
function X = FilterPoints(S)
X = ApplyToSkeleton(@ff,S);
end