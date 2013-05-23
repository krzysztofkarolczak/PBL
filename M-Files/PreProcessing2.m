%%
function A = PreProcessing2()
	close all;

	S = [];
	LoadSkeleton;
	A = SkeletonToArray(S);
    
    %(frame,coordinate)
    [startWithFrame, endWithFrame] = computeFrameRange(A, 10, 0.0154, 10, 0.003);  

	%TakePoints
	A = TakePoints(A,startWithFrame,endWithFrame);
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
    
    finalVector=keyFrameHunter(A,1,(endWithFrame-startWithFrame+1));
    
    figure('units','normalized','outerposition',[0 0 1 1]);
	pause
	Boundary = GetBoundaryFromSkeleton(A);
    a=1;
	for k = 1 : length(A.Crotch)
		DrawSkeleton(A,k,Boundary);
		pause(0.1);
 		drawnow;
        el=(finalVector(2,a));
        if(k==el)
            pause
            if a+1<=length(finalVector)
                a=a+1;
            end
        end
	end
	%LeftLegSegment = sqrt((S.LeftHip.X-S.LeftKnee.X).^2 + (S.LeftHip.Y - S.LeftKnee.Y).^2 + (S.LeftHip.Z - S.LeftKnee.Z).^2);
	%RightLegSegment = sqrt((S.RightHip.X-S.RightKnee.X).^2 + (S.RightHip.Y - S.RightKnee.Y).^2 + (S.RightHip.Z - S.RightKnee.Z).^2);
end
%%
function [finalVector]=keyFrameHunter (S, start, stop)
    
    lastFrame = stop-start+1;

    distanceBetweenRightKneeAndLeftKnee = 2.*ones (1, length(S.RightKnee));
    distanceBetweenRightFootAndLeftFoot = distanceBetweenRightKneeAndLeftKnee;
    
    vectorForCharPhase1 =zeros(1,lastFrame);
    vectorForCharPhase2 = vectorForCharPhase1;
    vectorForCharPhase3 = vectorForCharPhase1;
    vectorForCharPhase4 = vectorForCharPhase1;
    
    zeroCrossings=zeros(1,lastFrame);
    
    zeroCrossingsKnees=zeros(1,lastFrame);
    
	for k = start : stop 
        distanceBetweenRightKneeAndLeftKnee(k)= S.RightKnee(k,1)  -   S.LeftKnee(k,1);
        distanceBetweenRightFootAndLeftFoot(k)= S.RightFoot(k,1)  -   S.LeftFoot(k,1); 
    end

    for k = start : stop-1
        if (distanceBetweenRightFootAndLeftFoot(k)*distanceBetweenRightFootAndLeftFoot(k+1)<=0)
            if (abs(distanceBetweenRightFootAndLeftFoot(k+1))<abs(distanceBetweenRightFootAndLeftFoot(k)))
                zeroCrossings(1,k+1)=0.5;
            else
                zeroCrossings(1,k)=0.5;
            end
        end
        
        if (distanceBetweenRightKneeAndLeftKnee(k)*distanceBetweenRightKneeAndLeftKnee(k+1)<=0)
            if (abs(distanceBetweenRightKneeAndLeftKnee(k+1))<abs(distanceBetweenRightKneeAndLeftKnee(k)))
                zeroCrossingsKnees(1,k+1)=0.5;
            else
                zeroCrossingsKnees(1,k)=0.5;
            end
        end
    end

    for k = 1 : length(zeroCrossings)
        zeroTimesDistance(k) = zeroCrossings(k)*distanceBetweenRightKneeAndLeftKnee(k);
    end

%     figure(1)
%     plot(distanceBetweenRightKneeAndLeftKnee)
%     hold on
%     plot(distanceBetweenRightFootAndLeftFoot,'r')
%     stem(zeroCrossings(1,:),'m')
%     stem(zeroCrossingsKnees(1,:),'c')
%     legend('distanceKnees','distanceFeet','0 cross Feet', '0 cross knees')
    
    [valuesOfMaximasFeet,locationOfMaximasFeet]=findpeaks(distanceBetweenRightFootAndLeftFoot,'sortstr','ascend');
    [valuesOfMinimasFeet, locationOfMinimasFeet]=findpeaks(-1.*distanceBetweenRightFootAndLeftFoot,'sortstr','ascend');
    %valuesOfMinimasFeet=-1.*valuesOfMinimasFeet;- nieu¿ywane
    
    for i=1:length(zeroTimesDistance)
        if (zeroTimesDistance(i) > 0)
            vectorForCharPhase1(i)=i;
        elseif (zeroTimesDistance(i) < 0)
            vectorForCharPhase3(i)=i;    
        end
    end
    
    for i=1:length(locationOfMaximasFeet)
        e=locationOfMaximasFeet(i);       
        vectorForCharPhase2(e)=e;
    end
    
    for i=1:length(locationOfMinimasFeet)
        e=locationOfMinimasFeet(i);
        vectorForCharPhase4(e)=e;
    end
    
    vectorForCharPhase1 = [1.*ones(1,length(unique(vectorForCharPhase1)));unique(vectorForCharPhase1)];
    vectorForCharPhase2 = [2.*ones(1,length(unique(vectorForCharPhase2)));unique(vectorForCharPhase2)];
    vectorForCharPhase3 = [3.*ones(1,length(unique(vectorForCharPhase3)));unique(vectorForCharPhase3)];
    vectorForCharPhase4 = [4.*ones(1,length(unique(vectorForCharPhase4)));unique(vectorForCharPhase4)];
    
    finalVector=sortrows([vectorForCharPhase1';vectorForCharPhase2';vectorForCharPhase3';vectorForCharPhase4'],2)';
    
    o=1;
    for k=1:length(finalVector)-3
        
        currentIndex = finalVector(1,k);
        nextIndex = finalVector(1,k+1);
        nextNextIndex = finalVector(1,k+2);
        nextNextNextIndex = finalVector(1,k+3);
        
        if (currentIndex==1 && nextIndex ==2 && nextNextIndex == 3&& nextNextNextIndex == 4)
            if (finalVector(2,k) ~= finalVector(2,k+1) && finalVector(2,k+1) ~= finalVector(2,k+2) && finalVector(2,k+2) ~= finalVector(2,k+3))
                tempMatrix(:, o) = finalVector(:,k);
                tempMatrix(:,o+1) = finalVector(:,k+1);
                tempMatrix(:,o+2) = finalVector(:,k+2);
                tempMatrix(:,o+3) = finalVector(:,k+3);
                o=o+4;
            end
        end   
    end
    finalVector=tempMatrix;
end
%%
function [start,stop] = computeFrameRange(S, startTolerance, startThreshold, endTolerance, endThreshold)

    hit=0;

    rFoot = S.RightFoot;
    distance = ones (1,length(S.RightFoot));
    
	for k = 1 : length(S.RightFoot)-1
		distance(k) = sqrt(  power( rFoot(k,1)  -   rFoot(k+1,1),2 )+ power(  rFoot(k,2)  -   rFoot(k+1,2),2 )  +   power(  rFoot(k,3)  -   rFoot(k+1,3),2    )    );
    end
    %plot(distance)
    for k = 1 : length(distance)
        if(distance(k)>startThreshold)
            hit=hit+1;
            if (hit>=startTolerance)
                startFrame = k-startTolerance;
                break;
            end
        else
            hit=0;
        end
    end
    
    hit=0;
    
    for k = startFrame : length(distance)
        if( distance(k)<endThreshold)
            hit=hit+1;
            if (hit>=endTolerance)
                stopFrame = k-endTolerance;
                break;
            end
        else
            hit=0;
        end
    end
    
    start = startFrame;
    stop = stopFrame;
    
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
% 	    A.LeftFingers(Point,:);
% 	    A.LeftHand(Point,:);
% 	    A.LeftElbow(Point,:);
% 	    A.LeftShoulder(Point,:);
% 	    A.RightFingers(Point,:);
% 	    A.RightHand(Point,:);
% 	    A.RightElbow(Point,:);
% 	    A.RightShoulder(Point,:);
% 	    A.Head(Point,:);
% 	    A.Neck(Point,:);
% 	    A.Spine(Point,:);
		];

    plot(X(:,1),X(:,2),'-');
    title(Point)
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