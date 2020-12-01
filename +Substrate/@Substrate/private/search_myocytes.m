function [myoIndex] = search_myocytes(myocytes, position)
% return myocyte index that contains the point (nan if none of them)
%   assumes position is in the right coordinate frame already

myoIndex = NaN(); % initial guess (NaN == free space)
for iMyocyte = 1:numel(myocytes)
    try
        inside = myocytes(iMyocyte).containsPoint(position);
    catch exception
        switch exception.identifier
            case 'Geometry:Polyhedron:containsPoint'
                error('Myocyte:inside', exception.message); % is being handled
            otherwise
                rethrow(exception);
        end
    end
    if inside
        if ~isnan(myoIndex) % check if already assigned to another myocyte
            error('exec:init', 'Point cannot be inside multiple myocytes at the same time!');
        end
        myoIndex = iMyocyte;
    end
end

end
