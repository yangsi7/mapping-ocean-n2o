function decompclim = init_decompclim()
fnameOut.param = {'quad', 'bubbles'};
fnameOut.all= {'A','U','N','B'};
for fp = 1 : length(fnameOut.param)
    for fc = 1 : length(fnameOut.all)
            decompclim.(fnameOut.param{fp}).(fnameOut.all{fc}) = []; 
   end
end
