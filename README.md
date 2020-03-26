# MappingDN2OandFlux
Machinery to map sparse oceanic n2o data globally and compute its flux to the atmosphere.

For the below instructions to function, you'll need:
- Matlab 2018 or higher
- enough RAM memory
- time

You'll also need to populate the /Data/ folder. Some of the relevant data is available 
for download, e.g.  the n2o compilation, from the BCO-BMO website. Other more heavy
data such as atmospheric reanalysis and 4D WOA fields are publicly available. Refer 
to the supplementary information of the manuscript for links to these data.

Instructions:
(1) Run grid_compilation.m 
   % Grids the raw data onto the WOA grid

(2) Run dn2o_train_RaForest.m
   % Trains an ensemble of random Forest on the gridded data, subsequently used to map
   % dn2o globally

(3) Run GetFluxAndDecompose.m
   % Computes the flux at 6-hourly resolution using two different formulations for all the
   % ensemble members retreived in (2). This is extremely computationally and memory heavy.

   For more information or help, contact;
   -Simon Yang (yangsi@atmos.ucla.edu) 
   -Daniele Bianchi (dbianchi@atmos.ucla.edu)

