function Segments = RotationProcessingClean(filename)
close all;

%ReadData
S = [];
f_name=strcat('run samples/',[filename '.m']);
eval(f_name);

A = SkeletonToArray(S);
A = FilterPoints(A);

%GetVelocity
v1 = [0;diff(A.Crotch(:,1))];
v2 = [0;diff(A.Crotch(:,2))];
v3 = [0;diff(A.Crotch(:,3))];

%DetectMovementSamples
Samples = (sqrt(v1.^2+v2.^2+v3.^2) - 0.01) > 0 & sign(v1) < 0;

%FindGlobalFloorPlane
A = ShiftToCrotch(A);
Floor = FindFloorVector(A);

%GetSkeletonsMatrix
Skeletons = SkeletonToFullArray(A);

%ProjectOnMovementPlane
h = waitbar(0,'Please wait rotating...');
C = length(A.Skeleton);

Frames = zeros(C,20,2);
for frame = 1 : C
    %FindBackPlane - a mo¿e shoulders?
    Back = cross(Floor,A.LeftShoulder(frame,:)-A.RightShoulder(frame,:))';
    %FindMovementPlane
    Move = cross(Floor,Back);

    %GetCurrentSkeleton
    sk = zeros(3,20);
    sk(:,:) = Skeletons(frame,:,:);

    %ProjectSkeleton
    M = repmat(Move'/norm(Move),20,1);
    sk_p = sk' - repmat(sum(M.*sk',2),1,3).*M;

    %DefineNewAxises
    F_ = Floor/norm(Floor);
    B_ = Back/norm(Back);

    %FindNewCoordinatesRespectivelyToNewAxises
    P_ = zeros(20,2);
    for k = 1 : 20
        P_(k,:) = ([F_ B_]\sk_p(k,:)')';
    end
    Frames(frame,:,:) = P_;
    
    waitbar(frame/C,h);
end
close(h) 

%DivideFramesIntoSegments
NoSegments = sum(diff(Samples) == 1);
Segments = cell(NoSegments,1);
Boundings = 1 + find(diff(Samples) ~= 0);
for Segment = 1 : 2 : numel(Boundings)
    Segments{(Segment+1)/2} = Frames(Boundings(Segment):Boundings(Segment+1),:,:);    
end

%FindKeyFramesForASegment
f_name=strcat('save f_',[filename '.mat Segments']);
eval(f_name);
%return

%PrepareForDrawing
SkFrames = zeros(C,29,2);
Order = [8 7 6 5 3 4 3 13 14 15 16 15 14 13 3 2 1 9 10 11 12 11 10 9 1 17 18 19 20];
for frame = 1 : C
    SkFrames(frame,:,1) = Frames(frame,Order,1);
    SkFrames(frame,:,2) = Frames(frame,Order,2);
end

close all;
figure('units','normalized','outerposition',[0 0 1 1]);

P_ = zeros(29,2);
P_(:,:) = SkFrames(1,:,:);
h_s = plot(sign(P_(16,2))*P_(:,2),P_(:,1),'b-');
axis square;
axis equal;
xlim([-0.5 0.5]), ylim([-1,1]);
h_t = title('1');  
pause
for frame = 2 : C
    %if samples(frame) > 0 
        P_(:,:) = SkFrames(frame,:,:);
        %subplot(321)
        set(h_s,'XData',sign(P_(16,2))*P_(:,2));
        set(h_s,'YData',P_(:,1));
        set(h_t,'String',num2str(frame));
        drawnow;
    %end
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
function X = SkeletonToFullArray(S)
f = @(x) x(:);
X = struct2cell(ApplyToSkeleton(f,S))';
L = length(X{1});
X = reshape(cell2mat(X(1:20)),L/3,3,20);
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