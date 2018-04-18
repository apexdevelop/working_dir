 x1=num2cell(vols);
 x2=num2cell(prices);
 idx1=cellfun(@(x) any(isnan(x)),x1);
 x1(cellfun(@(x) any(isnan(x)),x1)) = '[]';
 idx2=any(cellfun(@(x) any(isnan(x)),x2),2);
 x2(any(cellfun(@(x) any(isnan(x)),x2),2),:) = [];