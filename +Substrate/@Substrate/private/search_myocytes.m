function [myoIndex] = search_myocytes(myocytes, position)
% return myocyte index that contains the point (nan if none of them)
%   assumes position is in the right coordinate frame already

myoIndex = NaN(); % initial guess (NaN == free space)
for iMyocyte = 1:numel(myocytes)
    inside = myocytes(iMyocyte).containsPoint(position);
    if inside
        if ~isnan(myoIndex) % check if already assigned to another myocyte
            error('Substrate:search_myocytes:multiple', 'Point cannot be inside multiple myocytes');
        end
        myoIndex = iMyocyte;
    end
end

end
