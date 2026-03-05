warning off;clear all; close all; format compact; profile off; diary off; restoredefaultpath;warning on;
pause(.1);hdr;

verbose = 1;
ifgui = 1;
ifpng = 1; % save pngs

% debug
fldr_out = 'outputs_box2d';

% fluid

Lx = 2.0; Ly = 1.0;  % inner box: [-Lx, Lx] x [Ly, Ly]
bx = 0.5; by = 0.1;  % boundary layer thickness
tx = 0.2; ty = 0.1;  % solid thickness

% for thanh3
L = 1.0; Lx = L; Ly = L;
b = 1e-2; bx = b; by = b;
t = 0.13154897494; tx = t; ty = t;
fldr_out = 'outputs_box2d_reso1';

% box 0
nbox0 = 8;
xmin0 = -Lx + bx; xmax0 = Lx - bx;
ymin0 = -Ly + by; ymax0 = Ly - by;

% box 1
bratio1 = 1.0; % geometric ratio, 1 = uniform, >1: coaser outer, <1: finer outer
nlayer1 = 1;
xmin1 = -Lx; xmax1 = Lx;
ymin1 = -Ly; ymax1 = Ly;

% solid
bratio2 = 1.5;
nlayer2 = 3;
xmin2 = -Lx - tx; xmax2 = Lx + tx;
ymin2 = -Ly - ty; ymax2 = Ly + ty;


mkdir(fldr_out);

vis = 'on'; if (ifgui==0); vis='off'; end; set(0,'DefaultFigureVisible',vis);

save_aux = @(h,tag) print(h, '-dpng','-r400',[fldr_out '/' tag '.png']);
if (ifpng==0); save_aux = @(h,tag)[]; end

apply_xylim = @(x) axis([-1.2 1.2 -1.2 1.2]);

% core box
tag = 'box0'; deform = 0.0; dist = 1; % 0 = uniform; 1 = Chebyshev; 2 = GLL
[X, Quad, Qfront] = gen_box2d(nbox0, dist, deform); nQ = size(Quad,1); 
X(:,1) = rescale_x(X(:,1), xmin0, xmax0);
X(:,2) = rescale_x(X(:,2), ymin0, ymax0);
Qcurve = zeros(6, 4, nQ); % (type + bc(5), 4 faces, E)
Qbc = zeros(4, nQ);
bc_set = chk_bcid([],Qbc,tag,1);
ifig = 1; h=plot_quad(ifig,X,Quad); apply_xylim(); save_aux(h,tag);

% fluid box
tag = 'box1'; Nlap = 0; vbox = [xmin1, xmax1, ymin1, ymax1]; nlyr=nlayer1; ratio=bratio1;
[X, Quad, Qbc, Qcurve, Qfront] = extrude2d_front2box(X, Quad, Qbc, Qcurve, Qfront, vbox, nlyr, ratio, Nlap);
bc_set = chk_bcid([],Qbc,tag,1);
ifig = 2; h=plot_quad(ifig,X,Quad); apply_xylim(); save_aux(h,tag);

nQ = size(Quad,1);
nelv = size(Quad,1);

% set fluid BC
bc_map = {};
bc_map{1} = [1,2,3,4];
CBCv = set_cbc(Qbc,bc_map)';

%% solid domain
tag = 'box2'; Nlap = 0; vbox = [xmin2, xmax2, ymin2, ymax2]; nlyr=nlayer2; ratio=bratio2;
[X, Quad, Qbc, Qcurve, Qfront] = extrude2d_front2box(X, Quad, Qbc, Qcurve, Qfront, vbox, nlyr, ratio, Nlap);
bc_set = chk_bcid([],Qbc,tag,1);
ifig = 5; h=plot_quad(ifig,X,Quad); apply_xylim(); save_aux(h,tag);

% set solid BC
bc_map = {};
bc_map{1} = [5,6,7,8];
CBCt = set_cbc(Qbc,bc_map)';

%% dump mesh
fout='out';
fname=[fldr_out '/' fout]; ord2=0; % linear elements
dump_nek_rea_heat(fname,X,Quad,{CBCv,CBCt},ord2,Qcurve,verbose+1);

flist = {'nekwriter/head.rea', [fname '.out'], 'nekwriter/tail.rea'}; % TODO chk 3D head.rea, ifheat, nBC, etc
fout = [fname '.rea'];
combine_txt(flist, fout, verbose)
%
%
