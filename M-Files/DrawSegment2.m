function Bezierki = DrawSegment2(S)

%FindDistanceBetweenAnckles
F1 = sum((S(:,19,:)-S(:,11,:)).^2,3);
F2 = [NaN;diff(F1)];
F3 = sign(F2).*[sign(F2(2:end));sign(F2(end))];
F4 = [NaN;diff(F2)];

% FindKeyFrames
Candidates = zeros(sum(F3<1),1);
AF2 = abs(F2);
ExtremumCandidates = find(F3<1);
for Candidate = 1 : numel(ExtremumCandidates)
    ExtremumCandidate = ExtremumCandidates(Candidate);
    if AF2(ExtremumCandidate-1) < AF2(ExtremumCandidate)
        Candidates(Candidate) = ExtremumCandidate - 1;
    else
        Candidates(Candidate) = ExtremumCandidate;
    end
end
Extremas = Candidates(F4(Candidates) > 0 | F1(Candidates) > 0.01);
FF = S(Extremas,19,2)-S(Extremas,11,2);
Phases = zeros(size(Extremas));
Phases(F4(Extremas) < 0 & FF > 0) = 1;
Phases(F4(Extremas) < 0 & FF < 0) = 3;
for k = 2 : length(Phases) - 1
    if Phases(k) == 0 && Phases(k-1) == 1 && Phases(k+1) == 3
        Phases(k) = 2;
    elseif Phases(k) == 0 && Phases(k-1) == 3 && Phases(k+1) == 1
        Phases(k) = 4;
    end
end
Phases(1) = Phases(2) - 1;
if Phases(1) == 0, Phases(1) = 4; end
Phases(end) = Phases(end-1) + 1;
if Phases(end) == 5, Phases(end) = 1; end

Bezierki = cell(0);
if length(Phases) > 3
    for k = 1 : length(Phases) - 3
        if all(Phases(k:k+3) == unique(Phases(k,k+3)))
            for l = 0 : 3
                Beziers(Phases(k+l),1) = %X;
                Beziers(Phases(k+l),2) = %Y;
                Beziers(Phases(k+l),3) = %Mean;
            end
            Bezierki{end+1} = Beziers;
        end
    end
end

%subplot(322),hold on;plot(Extremas,F1(Extremas),'ro')

%phaseDetector(S,Extramas);

%[Extremas Kind] = keyFrameHunter(S);

%PrepareForDrawing
SkFrames = zeros(size(S,1),29,2);
Order = [8 7 6 5 3 4 3 13 14 15 16 15 14 13 3 2 1 9 10 11 12 11 10 9 1 17 18 19 20];
%Head-Neck-RightElbow-Crotch-LeftKnee-LeftToes-LeftAnckle
%LeftFoot-LeftAnckle-LeftKnee-RightHand-RightShoulder
%BezierOrder = [12 11 10 16 13 3];
BezierOrder = [21 22 23 11 13 14 15];% 15];
for frame = 1 : size(S,1)
    SkFrames(frame,:,1) = S(frame,Order,1);
    SkFrames(frame,:,2) = S(frame,Order,2);
end

close all;
figure('units','normalized','outerposition',[0 0 1 1]);

P_ = zeros(29,2);
P_(:,:) = SkFrames(1,:,:);
subplot(221)
h_s = plot(sign(P_(16,2))*P_(:,2),P_(:,1),'b-');
axis square;
axis equal;
xlim([-0.5 0.5]), ylim([-1,1]);
subplot(222)
h_f1 = plot(F1(1),'*');
set(gca,'NextPlot','add');
h_f2 = plot(NaN,'ro');
xlim([1 size(S,1)]), ylim([0 max(F1)]);

pause
Extremum = 1;
for frame = 2 : size(S,1)
    P_(:,:) = SkFrames(frame,:,:);
    set(h_s,'XData',sign(P_(16,2))*P_(:,2));
    set(h_s,'YData',P_(:,1));
    set(h_f1,'XData',1:frame);
    set(h_f1,'YData',F1(1:frame));
    if numel(find(Extremas == frame)) > 0  
        Nodes = [sign(P_(16,2))*P_(BezierOrder,2),P_(BezierOrder,1)];
        
        BezierX = GetBezier(Nodes(:,1),100);
        BezierY = GetBezier(Nodes(:,2),100);
        
        set(h_f2,'XData',Extremas(1:Extremum));
        set(h_f2,'YData',F1(Extremas(1:Extremum)));
        subplot(2,8,8 + Extremum)
        plot(sign(P_(16,2))*P_(:,2),P_(:,1));
        hold on;
        plot(Nodes(:,1),Nodes(:,2),'or');
        plot(BezierX,BezierY,'r','lineWidth',2);
        title(num2str(Phases(Extremum)));
        axis square;
        axis equal;
        xlim([-0.5 0.5]), ylim([-1,1]);
        Extremum = Extremum + 1;
    end
    drawnow;
    pause(0.005);
end

end

%%
function [finalVector phase]=phaseDetector(S,Extramas)
    for i=1:length(Extramas)
        
        distanceBetweenRightFootAndLeftFoot = sum((S(i,20,:)-S(i,12,:)).^2,3);
        distanceBetweenRightKneeAndLeftKnee = sum((S(i,18,:)-S(i,10,:)).^2,3);
    end
end

%%
function [finalVector v2]=keyFrameHunter(S)
    
    lastFrame = length(S);

    %distanceBetweenRightKneeAndLeftKnee = 2.*ones (1, lastFrame);
    %distanceBetweenRightFootAndLeftFoot = distanceBetweenRightKneeAndLeftKnee;
    
    vectorForCharPhase1 =zeros(1,lastFrame);
    vectorForCharPhase2 = vectorForCharPhase1;
    vectorForCharPhase3 = vectorForCharPhase1;
    vectorForCharPhase4 = vectorForCharPhase1;
    
    zeroCrossings=zeros(1,lastFrame);
    zeroCrossingsKnees=zeros(1,lastFrame);
    
% 	for k = 1 : lastFrame 
%         distanceBetweenRightKneeAndLeftKnee(k)= S.RightKnee(k,1)  -   S.LeftKnee(k,1);
%         distanceBetweenRightFootAndLeftFoot(k)= S.RightFoot(k,1)  -   S.LeftFoot(k,1); 
%     end
    distanceBetweenRightFootAndLeftFoot = sum((S(:,20,:)-S(:,12,:)).^2,3);
    distanceBetweenRightKneeAndLeftKnee = sum((S(:,18,:)-S(:,10,:)).^2,3);
    for k = 1 : lastFrame-1
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
    
    zeroTimesDistance = zeros(1,length(zeroCrossings));
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
    finalVector=tempMatrix(1,:)';
    v2 = tempMatrix(2,:)';
end
