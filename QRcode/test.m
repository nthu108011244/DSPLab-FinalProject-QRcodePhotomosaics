%% generate a QR code
close all;
if_show = 1;

% txt can be a string or URL
txt = 'THis is DSP Lab Final Project.';

% ecc can be ['L', 'M', 'Q', 'H']
ecc = 'L';

% generate a qrcode
% black -> 0
% white -> 1
[qr, ver] = genQR(txt, ecc);

if if_show
    figure();
    imagesc(qr);
    colormap(gray);
    axis square;
    set(gca,'XTickLabel','');
    set(gca,'YTickLabel','');
    set(gca,'Xtick',[],'Ytick',[]);
end

