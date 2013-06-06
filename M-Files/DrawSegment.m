function DrawSegment(S)

%FindDistanceBetweenAnckles
F1 = sum((S(:,19,:)-S(:,11,:)).^2,3);
F2 = [NaN;diff(F1)];
F3 = sign(F2).*[sign(F2(2:end));sign(F2(end))];
F4 = [NaN;diff(F2)];

%FindKeyFrames
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
%subplot(322),hold on;plot(Extremas,F1(Extremas),'ro')


%PrepareForDrawing
SkFrames = zeros(size(S,1),29,2);
Order = [8 7 6 5 3 4 3 13 14 15 16 15 14 13 3 2 1 9 10 11 12 11 10 9 1 17 18 19 20];
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
        set(h_f2,'XData',Extremas(1:Extremum));
        set(h_f2,'YData',F1(Extremas(1:Extremum)));
        subplot(2,8,8 + Extremum)
        plot(sign(P_(16,2))*P_(:,2),P_(:,1));
        axis square;
        axis equal;
        xlim([-0.5 0.5]), ylim([-1,1]);
        Extremum = Extremum + 1;
    end
    drawnow;
    pause(0.005);
end

end