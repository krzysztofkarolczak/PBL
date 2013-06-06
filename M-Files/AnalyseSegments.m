function AnalyseSegments

filenames = { 
    'f_ati'
    'f_bart'
    'f_krzys'
    'f_przemek'
    'f_piotrek'
    'f_grzes'
    'f_koniu2'
    'f_sankowski'
    };


for file = 1 : 8
    Str = load(filenames{file});
    Segments = Str.Segments;
    NoSegments = length(Segments);
    Data = cell(0);
    for k = 1 : NoSegments
        S = DrawSegment2(Segments{k});
        if numel(S)>0
        Data = cat(1,Data,S{1});
        end
    end
    for k = 1 : length(Data)
        dlmwrite('Feature.txt',[file;Data{k}]','-append');
    end
end