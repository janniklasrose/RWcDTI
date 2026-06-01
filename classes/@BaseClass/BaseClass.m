classdef(Abstract=true) BaseClass < handle
    %BASECLASS Implements the handle class but hides public methods
    %
    %   When defining a new class to be a subclass of handle (through classdef MyClass < handle),
    %   all of its methods are inherited. However, this may confuse the user when trying to
    %   auto-completing methods with <TAB> after MyClass.___ and leads to clutter in the class
    %   reference page (>> doc MyClass).
    %
    %   This class BASECLASS is a subclass of the handle class, but hides all the inherited
    %   methods. Functionality is preserved by passing the arguments to the corresponding methods
    %   in the superclass handle. To benefit from this, simply use BASECLASS instead of handle
    %   in your class definitions (i.e. classdef MyClass < BASECLASS).
    %
    %   COPYRIGHT: Developed by Jan N. Rose (for contact information see below), at the
    %   Department of Aeronautics, Imperial College London.
    %
    %   CONTACT: If you have any questions or suggestions, please do not hesitate to
    %   drop me an email at jan.rose14@[alumni.]imperial.ac.uk to get in touch. I would
    %   be interested to find out what my code is being used for, and am happy to expand
    %   its functionality.
    %
    %   See also HANDLE
    
    %%% override methods to hide them
    methods(Hidden=true)
        function l = addlistener(varargin)
            l = addlistener@handle(varargin{:});
        end
        %{
        % do not re-define this, otherwise errors involving 
        %   deleted objects don't report correctly.
        function delete(varargin)
            delete@handle(varargin{:});
        end
        %}
        function b = eq(varargin)
            b = eq@handle(varargin{:});
        end
        function o = findobj(varargin)
            o = findobj@handle(varargin{:});
        end
        function p = findprop(varargin)
            p = findprop@handle(varargin{:});
        end
        function b = ge(varargin)
            b = ge@handle(varargin{:});
        end
        function b = gt(varargin)
            b = gt@handle(varargin{:});
        end
        %{
        % cannot re-define this, as it is a Sealed method from the
        %   superclass definition in @handle
        function b = isvalid(varargin)
            b = isvalid@handle(varargin{:});
        end
        %}
        function b = le(varargin)
            b = le@handle(varargin{:});
        end
        function b = lt(varargin)
            b = lt@handle(varargin{:});
        end
        function b = ne(varargin)
            b = ne@handle(varargin{:});
        end
        function notify(varargin)
            notify@handle(varargin{:});
        end
    end
    
end
