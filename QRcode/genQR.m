function [qr_mk, ver, qr_size] = genQR(txt, ecc)
% GENERATE QR CODE
load('qrtab.mat');
close all

%%  Prompt User Input
%%
% fprintf('Welcome, this program will output qr codes for some given input.\n');

%%  Encoding Mode , Version , and ECC level
%%
% ecc = input('Select an Error Correction Level: ' , 's');
% ver = 1;
% coll = 1;

%%  Get Character Count
%%
% txt = input('Please enter text to convert: ' , 's');
count = length(txt);

%%  Choose Encoding Mode
%%
txtMod = txt;
txtMod(txtMod==' ') = '';

if( any(isstrprop(txtMod , 'lower')) )                  % check for lowercase letters
	alnm_cap = charcap(:,3);
	alnm_err = errcap(:,1);
    coll = 3;
    [raw luval] = qr_byte( txt , count , ecc , alnm_cap , alnm_err);
else
    if( sum(isstrprop(txtMod , 'upper')) == length(txtMod) )           % check for alphanumeric characters
        alnm_cap = charcap(:,2);
        alnm_err = errcap(:,1);
        coll = 2;
        [raw luval] = qr_alphanum( txt , count , ecc , alnm_cap , alnm_err);
    else                                            % stricly numeric digits
        alnm_cap = charcap(:,1);
        alnm_err = errcap(:,1);
        coll = 1;
        [raw luval] = qr_numeric( txt , count , ecc , alnm_cap , alnm_err);
    end
end

splt = blockup(raw , luval , errcap);
errcod = zeros(length(splt) , errcap(luval,2));
datcod = zeros(length(splt) , max(errcap(luval,4) , errcap(luval,6)));
Gpol = genPoly(errcap(luval , 2) , gftab);

%%  Generate Message Polynmial and Error Codewords for each block
%%
for i = 1:length(splt)
    Mpol = genMPoly( splt{i} );
    errcod(i,:) = divPoly(Mpol , Gpol , errcap(luval , 2) , gftab);
    datcod(i,1:length(Mpol)) = Mpol;
end
%%  Interleave Codewords
%%
intr = intrLv(datcod , errcod , errcap(luval , :));

%%  Convert Message to Binary
%%
fmsg = binMsg( intr );

%%  Add Remainder Bits
%%
ver = ceil(luval/4);
rb = remcap(ver);
if(rb)
    fmsg = horzcat(fmsg , dig2bin(0 , rb));
end

if(ver == 1)
    [qr, mk] = qrmodule(ver , fmsg , [] , ecc);     
else
    [qr, mk] = qrmodule(ver , fmsg , algtab(ver - 1,:) , ecc);
end

[h, w] = size(qr);
qr_size = h * 3;
qr_mk = zeros(qr_size, qr_size);

for i = 1 : h
    for j = 1 : w
        y = (i - 1) * 3 + 1;
        x = (j - 1) * 3 + 1;
        
        if (mk(i, j))
            qr_mk(y:y+2, x:x+2) = qr(i, j);
        else
            qr_mk(y:y+2, x:x+2) = -1;
            qr_mk(y+1, x+1) = qr(i, j);
        end
    end
end

end
