% find optimal settlement point for feb option
% Yan Feb 13, 2013
cd('C:\Documents and Settings\YChen\My Documents');
[num_p,txt_p]=xlsread('feb_option','feb pnc','j26:j71');
[num_sp,txt_sp]=xlsread('feb_option','feb pnc','a26:a71');
[num_vp,txt_vp]=xlsread('feb_option','feb pnc','l26:l71');
[num_c,txt_c]=xlsread('feb_option','feb pnc','j73:j119');
[num_sc,txt_sc]=xlsread('feb_option','feb pnc','a73:a119');
[num_vc,txt_vc]=xlsread('feb_option','feb pnc','l73:l119');

% x1=145;
% x2=165;
% [x,fval] = fminbnd(@(x) -sum((x-num_sp).*num_p),x1,x2)
% [x,fval] = fminbnd(@(x) -sum((x-num_sp).*num_p)-1.4*sum((num_sv-x).*num_c),x1,x2);
z1=[];z2=[];z3=[];
y=145:165;
for yt=145:165
    new_z1=-sum((yt-num_sp).*num_p)-sum(num_vp);
    z1=[z1 new_z1];
    new_z2=-sum((num_sc-yt).*num_c)-sum(num_vc);
    z2=[z2 new_z2];
    new_z3=new_z1+new_z2;
    z3=[z3 new_z3];
end
plot(y,z1,'red')
hold on;
plot(y,z2,'blue')
hold on;
plot(y,z3,'green')
