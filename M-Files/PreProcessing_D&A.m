%%
function A = PreProcessing()
	close all;

	S = [];
	LoadSkeleton;
	A = SkeletonToArray(S);
    
    %(frame,coordinate)
    [startWithFrame, endWithFrame] = computeFrameRange(A, 10, 0.0154, 10, 0.003);
    keyFrameHunter(A,startWithFrame,endWithFrame);

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
function keyFrameHunter (S, start, stop)

    distanceBetweenRightKneeAndLeftKnee = 2.*ones (1, length(S.RightKnee));
    distanceBetweenRightFootAndLeftFoot = distanceBetweenRightKneeAndLeftKnee;

    i=1;
    j=1;
    o=1;
    l=1;
    
	for k = start : stop
        distanceBetweenRightKneeAndLeftKnee(k)= S.RightKnee(k,1)  -   S.LeftKnee(k,1);
        distanceBetweenRightFootAndLeftFoot(k)= S.RightFoot(k,1)  -   S.LeftFoot(k,1);
    end
    
    [valuesOfMaximasKnees,locationOfMaximasKnees]=findpeaks(distanceBetweenRightKneeAndLeftKnee,'sortstr','ascend');
    [valuesOfMinimasKnees, locationOfMinimasKnees]=findpeaks(-1.*distanceBetweenRightKneeAndLeftKnee,'sortstr','ascend');
    valuesOfMinimasKnees=-1.*valuesOfMinimasKnees;
    
    [valuesOfMaximasFeet,locationOfMaximasFeet]=findpeaks(distanceBetweenRightFootAndLeftFoot,'sortstr','ascend');
    [valuesOfMinimasFeet, locationOfMinimasFeet]=findpeaks(-1.*distanceBetweenRightFootAndLeftFoot,'sortstr','ascend');
    valuesOfMinimasFeet=-1.*valuesOfMinimasFeet;
    
    for i=1:length(locationOfMaximasKnees)
        eMin = locationOfMaximasKnees(i);
       for j=1:length(locationOfMinimasFeet) 
                       
            eMax = locationOfMinimasFeet(j);
            diff=abs(eMax-eMin);
            if(diff<2)
                if (valuesOfMaximasKnees(i)>0) %prawa z przodu
                    vectorForCharPhase1(l,1) = eMax;
                    l=l+1;
                end
                if (valuesOfMaximasKnees(i)<0) %lewa z przodu
                    vectorForCharPhase3(o,1) = eMax;
                    o=o+1;
                end
            end
       end
    end
    
    vectorForCharPhase2 = [2.*ones(1,length(locationOfMaximasFeet));locationOfMaximasFeet];
    
    B = unique (vectorForCharPhase3);
    vectorForCharPhase3 = [3.*ones(1,length(B));B'];
    
    B = unique (vectorForCharPhase1);
    vectorForCharPhase1 = [ones(1,length(B));B'];

    finalVector = [vectorForCharPhase1';abs(vectorForCharPhase2');vectorForCharPhase3'];
    finalVector=sortrows(finalVector,2)';
 
    o=1;
    for k=1:length(finalVector)-2
        currentIndex = finalVector(1,k);
        nextIndex = finalVector(1,k+1);
        nextNextIndex = finalVector(1,k+2);
        diff = nextIndex - currentIndex;
        
        if (currentIndex==1 & nextIndex ==2 & nextNextIndex == 3)
            tempMatrix(o,:) = finalVector(:,k);
            tempMatrix(o+1,:) = finalVector(:,k+1);
            tempMatrix(o+2,:) = finalVector(:,k+2);
            o=o+3;
        end
        
        
    end
    
    
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