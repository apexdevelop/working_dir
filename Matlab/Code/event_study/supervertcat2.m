function C = supervertcat2(varargin)
% C = supervertcat(A1, A2, ...)

nrow = cellfun('size',varargin,1);
maxrow = max(nrow);
for k = 1:nargin
    if nrow(k) < maxrow
        varargin{k}(maxrow,end) = 0;
    end
end
C = cat(2, varargin{:});