function [myoIndex] = findMyocyte(position, geom)

substrateType = 'block';
switch substrateType
    case 'full' % we have all myocytes stored as objects with their actual positions
        
        position_LOCAL = position;
        
    case 'block' % we just have a block subset that is repeated
        
        position_LOCAL = transformPosition(geom.substrate, position);
        
end
myoIndex = searchMyocytes(geom.myocytes, position_LOCAL);

end

function [myoIndex] = searchMyocytes(myocytes, position)

myoIndex = NaN(); % initial guess (NaN == free space)
for iMyocyte = 1:numel(myocytes)
    try
        inside = myocytes(iMyocyte).containsPoint(position);
    catch exception
        switch exception.identifier
            case 'Geometry:Polyhedron:contains'
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
