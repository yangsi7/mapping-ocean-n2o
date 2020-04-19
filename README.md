# MappingDN2OandFlux
Machinery to map sparse oceanic N2O data globally and compute its climatological flux to the atmosphere. Refer to the supplementary information of the manuscript for detailed methods and reference to datasets. For links to required datasets, just scroll down.


## Installation and requirements
### System requirements:
- **Matlab 2018 or higher**
- **A lot of RAM (20Gb), 20 x pe if running in parallel**
- **~1 Tb space for storing for populating /Data/ with required datasets**
### Required data:
- **compilation of observed n2o**
   - download the published compilation from the BCO-BMO website
   - Add new data to exisiting file or use as template to add your own data
- **NOAA's N2O flasks data**
   - Original at https://www.esrl.noaa.gov/gmd/hats/combined/N2O.html
   - download the processed version we used from the BCO-BMO website
- **Predictor data**
   - See manuscript for a list of references
   - download the processed predictor data we used from the BCO-BMO website
- **ERA5 atmospheric reanalysis data**
   - ~500 Gb - not included in the BCO-BMO upload
   - download from the Climate Data Store (https://cds.climate.copernicus.eu/cdsapp#!/home)
- **CCMP atmospheric reanalysis data**  
   - ~300 Gb - not included in the BCO-BMO upload
   - download from http://www.remss.com/measurements/ccmp/
- **NOAA's OISST v2 ** 
   - ~40 Gb - not included in the BCO-BMO upload
   - download from https://www.ncdc.noaa.gov/oisst/data-access

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

