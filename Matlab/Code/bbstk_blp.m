
clear all;

enddate=today();
startdate=enddate-1000;

[~, computer] = system('hostname');
[~, user] = system('whoami');
[~, alltask] = system(['tasklist /S ', computer, ' /U ', user]);
excelPID = regexp(alltask, 'EXCEL.EXE\s*(\d+)\s', 'tokens');
for i = 1 : length(excelPID)
      killPID = cell2mat(excelPID{i});
      system(['taskkill /f /pid ', killPID]);
end

Excel = actxserver ('Excel.Application'); 
File='C:\Users\ychen\Documents\MATLAB\input_ticker.xls'; 
if ~exist(File,'file') 
    ExcelWorkbook = Excel.Workbooks.Add; 
    ExcelWorkbook.SaveAs(File,1); 
    ExcelWorkbook.Close(false); 
end 
Excel.Workbooks.Open(File);

[num,txt]=xlsread1('input_ticker','proxy','b1:b2');

% Excel.ActiveWorkbook.Save; 
% Excel.Quit 
% Excel.delete 
% clear Excel


% GET DATA
c=blp;

for loop=1:size(txt,1)
%     new=[char(txt(loop)),' Equity'];
    new=char(txt(loop));
    [d sec] = history(c, new,'Last_Price',startdate,enddate);
    %[d sec] = history(c, new,'Last_Price',startdate,enddate,[],'USD');
    btxt(1:size(d,1),loop+1)=d(1:size(d,1),1);
    bbpx(1:size(d,1),loop+1)=d(1:size(d,1),2);
    
end;

close(c);
n_time=0;
for n_time=1:size(btxt,1)
    btxt(n_time,1)=n_time;
end

n_stk=0;
for n_stk=1:size(bbpx,1)
    bbpx(n_stk,1)=n_stk;
end

dtxt=sortrows(btxt,-1);
px=sortrows(bbpx,-1);