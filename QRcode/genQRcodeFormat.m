QR_format = struct('size', {}, 'mask', {});

QR_format(1).size = 21;
QR_format(2).size = 25;
QR_format(3).size = 29;
QR_format(4).size = 33;
QR_format(5).size = 37;
QR_format(6).size = 41;
QR_format(7).size = 45;
QR_format(8).size = 49;

filename = '../code/QRcode_record.mat';
save (filename, 'QR_format');