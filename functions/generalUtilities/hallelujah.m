function [] = hallelujah()
%hallelujah: Play a tiny bit of Handel's "Hallelujah Chorus"

load handel.mat;
soundsc(y(3000:17000));

end

