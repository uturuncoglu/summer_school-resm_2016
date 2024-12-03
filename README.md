# Regional Earth System Modeling Summer School 2016

**Location:** 5-7 September 2016, Istanbul Technical University, Istanbul, Turkey

The offical page of summer school web page can be found in [here](http://hbm.itu.edu.tr/egitimler/ysm2016/) (in Turkish)

## Login Information for HPC System (Anadolu@UHeM)

To login your [UHeM](http://www.uhem.itu.edu.tr) account that is created for the summer school, please type following commands (**you need to setup VPN connection to reach the server from outside of the campus!**):

```
> ssh lnode.uhem.itu.edu.tr -l [workshop user name]
> [type your password belong to your workshop user name]
```

The provided accounts will be available until **10 Sept. 2016** and they are limited to submit job with **max. 32 processor per user**. 

## Installation of Required Libraries (not required, optional)
This section includes detailed information to prepare required software environment that will be used in the hands-on section of the summer school. Please note that:

* The commands shown in the rest of the document is tested on **Anadolu@UHeM** cluster using **Intel C/C++/Fortran Compiler (14.0.1)** and **MPI (4.0 Update 3)** and might slightly change in other HPC system or server. 

* The required third-party libraries and tools to install and run the models (i.e. RegCM, ROMS and RegESM) are already installed to the **/RS/progs/workshop** folder.

Before starting to install or use the third-party libraries, you must load following modules (Intel Fortan/C/C++ compiler and MPI) on **Anadolu@UHeM**.

```
> module load intel/composer_xe_2013_sp1.1.106
> source /RS/progs/intel/impi/4.0.3.008/bin64/mpivars.sh
```

It is also possible to add these commands to **~/.bashrc** (for bash shell users which is default in most of the systems) file for automatization of loading necessary environment variables.  

The **install.sh** script can be used for the installation of required tools (i.e. [zlib](http://www.zlib.net), [HDF5](https://www.hdfgroup.org/HDF5/), [netCDF C/C++ and Fortran](http://www.unidata.ucar.edu/software/netcdf/), [xerces-c](http://xerces.apache.org/#xerces-c) and [ESMF](https://www.earthsystemcog.org/projects/esmf/) libraries). The script can be executed using following command (the command line argument given after shell script is the installation directory i.e. **/opt/progs**).

```
> wget --no-check-certificate https://github.com/uturuncoglu/summer_school-resm_2016/raw/master/install.sh
> ./install.sh `pwd`

or in case of explicitly defined installation directory 
> ./install.sh /opt/progs
```

Then source the **env_progs** file to use installed libraries and tools using following command (optinonally you might add the command to **~/.bashrc** file),

```
> source /RS/progs/workshop/env_progs
```

## Day1: Installation and Usage of RegCM

The [ICTP](http://www.ictp.it/research/esp.aspx)'s RegCM (**Reg**ional **C**Limate **M**odel) development is managed by SVN repository that can be found in [here](https://gforge.ictp.it/gf/project/regcm/scmsvn/?action=AccessInfo). To retrieve and install latest tagged version of the source code, please issue following commands,

```
> cd /RS/projects/workshop/$USER
> mkdir -p day1/src
> cd day1/src
> wget --no-check-certificate https://gforge.ictp.it/gf/download/frsrelease/252/1580/RegCM-4.5.0.tar.gz
> tar -zxvf RegCM-4.5.0.tar.gz
> cd RegCM-4.5.0
> ./configure --prefix=`pwd` CC=${CC} FC=${FC} MPIFC=mpiifort
> make install
> cd ../..
> ln -s src/RegCM-4.5.0/bin .
```

The installation of the model might take time depending on the used system and the selected compiler. Due to the limited time of the hands-on section, the RegCM installation under **/RS/progs/workshop/hands-on/day1/src/RegCM-4.5.0** directory can be used by linking binary directory,

```
> cd /RS/users/$USER/workshop
> mkdir day1
> cd day1
> ln -s /RS/progs/workshop/hands-on/day1/src/RegCM-4.5.0/bin .
```

### Use Case

The atmospheric model use case that will be used in the hands-on session includes,

* A parent domain that covers entire Mediterranean Basin (MED50) with 50 km horizontal resolution.
* A nested domain that covers entire Black Sea and Turkey with 10 km horizontal resolution. In the model coupling session (day 3), we will couple Black Sea ocean model (ROMS) with inner-most atmosphere model domain (TR10).
* The parent domain will be forced by [ERA-Interim](http://www.ecmwf.int/en/research/climate-reanalysis/era-interim) dataset and nested domain ICBC will be created using output of parent model domain (MED50). This procedure is called as "one-way nesting".
* The test simulation is planed as one month long (Jan. 2010).

![Domain map with high-resolution nest](https://github.com/uturuncoglu/summer_school-resm_2016/raw/master/images/Fig_01_domain.png)

### Running Parent Domain (MED50)

Before running the model, we need to create ICBC files,

* The whole set of suppoted initial and boundary conditions for RegCM model can be found in [here](http://clima-dods.ictp.it/regcm4/). 
* In this session, the ERA-Interim ([EIN75](http://clima-dods.ictp.it/regcm4/EIN75)) dataset will be used along with weekly SST ([OI-SST](http://clima-dods.ictp.it/regcm4/SST)) dataset (used as prescribed SST data in standalone model simulation)
* For year 2010, the data already placed under **/RS/progs/workshop/data/RCMDATA**. 

To get RegCM configuration file for MED50 simulation,

```
> cd /RS/users/$USER/workshop/day1
> wget --no-check-certificate https://github.com/uturuncoglu/summer_school-resm_2016/raw/master/day1/regcm.in_MED50km
```

Then, edit **regcm.in_MED50km** file and modify **dirter**, **dirglob**, **dirout** paths according to your user directories and run following commands to create input files for RegCM simulation, 

``` 
> mkdir input output
> bin/terrain regcm.in_MED50km
> bin/sst regcm.in_MED50km 
> bin/icbc regcm.in_MED50km
```

This will create a bunch of files under *input/* diectory. The generation of ICBC files could take time. So, the folder given in following command contains the required input files and can be linked to the user directory.

```
> mkdir output
> ln -s /RS/progs/workshop/data/DAY1/input .
```

After having input files, now we are ready to run the model. **Anadolu@UHeM** cluster uses LSF as a job schedular. To submit the actual RegCM simulation to the cluster, we need to create job submission script. So, following script (you can call it as **regcm.lsf**) can be used for this purpose,

```
#!/bin/bash
#BSUB -P workshop
#BSUB -J regcm 
#BSUB -q workshop 
#BSUB -m anadolu_quad 
#BSUB -o %J.out
#BSUB -e %J.err
#BSUB -a intelmpi4
#BSUB -n 16 

mpirun.lsf bin/regcmMPI regcm.in_MED50km >& regcmout.txt 
```

In this case, **-n** option basically controls the number of processor that will be used for the simulation. **-P** is the name of the project that will be used for the accounting purpose.

After creating job submission script (i.e. **regcm.lsf**), it could be submmited to the system using following command,

```
> bsub < regcm.lsf
```

The simulation can be checked by looking **regcmout.txt** file using *cat* or *tail* basic Linux commands. The output files will be placed under *output/* directory. The following LSF commands might help to monitor or kill the jobs.

```
> bjobs - shows the running jobs
> bjobs -u all - shows all jobs in the system (including other users)
> bkill [JOB ID] - kill the job
```

### Running Nested Domain (TR10)

After running parent domain (MED50) simulation and having output files, the initial and boundary conditions of nested model can be created. The first step is to create the input file directory (MED50 output files and SST data) that will be used to create input file for TR10 simulation.

```
> cd /RS/users/$USER/workshop/day1
> mkdir data
> cd data
> wget --no-check-certificate https://github.com/uturuncoglu/summer_school-resm_2016/raw/master/day1/link.sh

edit idir parameter and change the output directory before running following commands! 

> ./link.sh
> ln -s /RS/progs/workshop/data/RCMDATA/SST .
> wget --no-check-certificate https://github.com/uturuncoglu/summer_school-resm_2016/raw/master/day1/regcm.in_TR10km
```

Then, edit **regcm.in_TR10km** file and modify **dirter**, **dirglob**, **dirout** paths according to your user directories and run following commands to create input files for RegCM simulation,

```
> bin/terrain regcm.in_TR10km 
> bin/sst regcm.in_TR10km
> bin/icbc regcm.in_TR10km
```

Edit job submission script (**regcm.lsf**) used to run parent model domain and place **regcm.in_MED50km** with **regcm.in_TR10km**. So, the new run will use configuration of nested model domain (TR10). You may also increase the number of processor from 16 to 32. Then, the LSF script can be submitted as usual.

### Visualization and Analysis of Model Results

The output of the model is in NetCDF format and can be read by common data analysis and visualization tools such as [NCL](http://www.ncl.ucar.edu), [Ferret](http://ferret.pmel.noaa.gov/Ferret/), [Grads](http://cola.gmu.edu/grads/), [R](https://www.r-project.org) or Python programming language with [Matplotlib](http://matplotlib.org) toolbox. 

The results of simulations (MED50 and TR10) can be found in **/RS/progs/workshop/data/DAY1/output**.


## Day2: Installation and Usage of ROMS

The installation and usage of ROMS oceean modeling system include set of steps;

1. Preparing model using system/architecture specific definitions (i.e. compiler, MPI and third-party libraries)
2. Modifiying source code of the model for specific application (optional!)
3. Creating build script and model configuration file (*.h) to install model
4. Creating ocean model grid, initial and boundary conditions (not covered in this school) and atmospheric forcing (partly covered) in NetCDF format.
5. Creating model parameter file (*.in) to run the model 

The simplified version of the Black Sea model will be used during the summer school,

![Bathymetry map](https://github.com/uturuncoglu/summer_school-resm_2016/raw/master/images/Fig_02_bathymetry.png)

The configuration details of the Black Sea Model:

* **Model Resolution:** ~5 km (171-103 grid noktası) / 32 sigma seviyesi (θs = 6.5, θb = 2.5 and critical depth is, Hc = 5 m)
* **Bathymetry:** [GEBCO](http://www.gebco.net)
* **Initial and Boundary Condition:** Black Sea ROMS Simulation that was performed previously in a TUBITAK project (113Y108)
* **Atmospheric Forcing:** Long simulation of TR10 model (1979-2012) that was also performed previously in a TUBITAK project (113Y108)
* **River Forcing:** It was calculated by using Max Planck's [HD](http://www.mpimet.mpg.de/en/science/the-land-in-the-earth-system/working-groups/terrestrial-hydrology/hd-model/) River Routing Model

The following commands can be used to download ROMS modeling system (**the original version of the model does not support coupling through the RegESM driver! See section for day three for more information**) but first, you must register in [here](https://www.myroms.org/index.php?page=RomsCode) to get access to download the model using [SVN](https://subversion.apache.org) command.

```
> mkdir /RS/users/$USER/workshop/day2
> cd /RS/users/$USER/workshop/day2
> mkdir src
> cd src

if you already registered and have user name and password
> svn checkout -r 809 --username [ROMS USER NAME] https://www.myroms.org/svn/src/trunk roms-r809

if not, you could download the source code from GitHub
> wget --no-check-certificate https://github.com/uturuncoglu/summer_school-resm_2016/blob/master/day2/src/roms-r809.tar.gz
> tar -zxvf roms-r809.tar.gz 
```

In case of using original version of the ROMS ocean model (retrieved from subversion), you need to do minor modification in the source code (**roms-r809/ROMS/Nonlinear/bulk_flux.F**) to allow correct flux calculation (via Bulk Flux module) from *RegCM* model output. In this case, new configuration parameter  (CPP preprocessor flag, **SPECIFIC_HUMIDITY**) can be added as follows,

```
...
...
!
!-----------------------------------------------------------------------
!  Compute net longwave radiation (W/m2), LRad.
!-----------------------------------------------------------------------

# if defined LONGWAVE
!
!  Use Berliand (1952) formula to calculate net longwave radiation.
!  The equation for saturation vapor pressure is from Gill (Atmosphere-
!  Ocean Dynamics, pp 606). Here the coefficient in the cloud term
!  is assumed constant, but it is a function of latitude varying from
!  1.0 at poles to 0.5 at the Equator).
!
#  ifdef SPECIFIC_HUMIDITY
!  specific humidity in units of kg/kg
          vap_p=PairM*RH/(1.0_r8+0.378_r8*RH)             !WPB
#  else
      IF(RH.lt.2.0_r8) THEN                               !WPB
          cff=(0.7859_r8+0.03477_r8*TairC(i))/                          &
     &        (1.0_r8+0.00412_r8*TairC(i))
          e_sat=10.0_r8**cff   ! saturation vapor pressure (hPa or mbar)
          vap_p=e_sat*RH       ! water vapor pressure (hPa or mbar)
      ELSE                                                !WPB
          vap_p=0.001_r8*PairM*RH/(1.0_r8+0.000378_r8*RH) !WPB
      ENDIF                                               !WPB
#  endif
...
...
!
!  Compute specific humidity, Q (kg/kg).
!
#ifdef SPECIFIC_HUMIDITY
! Incoming humidity is specific humidity in (kg/kg)
          Q(i)=RH
#else
          IF (RH.lt.2.0_r8) THEN                       !RH fraction
            cff=cff*RH                                 !Vapor pres (mb)
            Q(i)=0.62197_r8*(cff/(PairM-0.378_r8*cff)) !Spec hum (kg/kg)
          ELSE          !RH input was actually specific humidity in g/kg
            Q(i)=RH/1000.0_r8                          !Spec Hum (kg/kg)
          END IF
#endif
...
...
```

**Also, not that this modification is already placed in the ROMS ocean model retrieved from GitHub using wget command and you don't need to do again!!!**

To install the model, user also need to edit an arcitecture specific file (found under **roms-r809/Compilers/**) according to used compiler, MPI library and NetCDF installation path. In our case, we will edit **Linux-ifort.mk** becasue we are using Intel Compiler and MPI. 

The default definition of NetCDF library in **Linux-ifort.mk**

```
...
ifdef USE_NETCDF4
        NC_CONFIG ?= nc-config
    NETCDF_INCDIR ?= $(shell $(NC_CONFIG) --prefix)/include
             LIBS := $(shell $(NC_CONFIG) --flibs)
else
    NETCDF_INCDIR ?= /usr/local/include
    NETCDF_LIBDIR ?= /usr/local/lib
             LIBS := -L$(NETCDF_LIBDIR) -lnetcdf
endif
...
ifdef USE_MPI
         CPPFLAGS += -DMPI
 ifdef USE_MPIF90
               FC := mpif90
 else
             LIBS += -lfmpi-pgi -lmpi-pgi
 endif
endif
...
```

must be modified as follows for **Adadolu@UHeM** cluster (be aware about empty spaces at the end of the directory definitions!),

```
...
ifdef USE_NETCDF4
        NC_CONFIG ?= nc-config
    NETCDF_INCDIR ?= $(shell $(NC_CONFIG) --prefix)/include
             LIBS := $(shell $(NC_CONFIG) --flibs)
else
    NETCDF_INCDIR ?= /RS/progs/workshop/netcdf-4.4.0/include
    NETCDF_LIBDIR ?= /RS/progs/workshop/netcdf-4.4.0/lib
             LIBS := -L$(NETCDF_LIBDIR) -lnetcdf -lnetcdff
endif
...
ifdef USE_MPI
         CPPFLAGS += -DMPI
 ifdef USE_MPIF90
               FC := mpiifort
 else
             LIBS += -lfmpi-pgi -lmpi-pgi
 endif
endif
...
```

Then, copy build script and edit *ROMS_APPLICATION*, *MY_ROOT_DIR*, *MY_ROMS_SRC* and *which_MPI* definitions as it indicated,

```
> cd /RS/users/$USER/workshop/day2/src
> cp roms-r809/ROMS/Bin/build.sh .
> vi build.sh

...
...
setenv ROMS_APPLICATION      BSEA
setenv MY_ROOT_DIR           /RS/projects/workshop/$USER/day2/src
setenv MY_ROMS_SRC           ${MY_ROOT_DIR}/roms-r809
...
...
setenv which_MPI             intelmpi
...
...
```

Then, the installation script (**build.sh**) can be run along with the model configuration file (**bsea.h**),  

```
> wget --no-check-certificate https://github.com/uturuncoglu/summer_school-resm_2016/raw/master/day2/bsea.h
> ./build.sh
```

This will create an executable (**oceanM**) in the same directory. If you plaining to run the model in debug or serial mode then the name of the executable changes as **oceanG** and **oceanS**.

In general, the ROMS ocean model requires a set of input files such as grid definition, initial and boundary conditions and atmospheric focing to run. In this tutorial, we will use previously created files for grid and initial conditions but atmospheric forcing will be generated by using output of RegCM simulation that is performed in last day (day1). To create atmospheric forcing for the standalone ocean model simulation and to retrive required files, the following commands can be used,

```
> cd /RS/users/$USER/workshop/day2
> mkdir input
> cd input
> wget --no-check-certificate https://github.com/uturuncoglu/summer_school-resm_2016/raw/master/day2/input.tar.gz
> tar -zxvf input.tar.gz

To create atmospheric forcing, you must edit roms_forc_bulk_ex.ncl and point out surface output of one month RegCM simulation. Then, you can run NCL script to create forcing file.

> ncl roms_forc_bulk_ex.ncl
```

After issuing previous commands, the input directory must have a file called as BSEA_forcing_20100102-20100131.nc. Also note that [NCL](http://www.ncl.ucar.edu) visualization and data analysis tool is already installed under **/RS/progs/workshop** and will be available to all the users after sourcing **env_progs** file.

The last missing file to run the model is the model parameter file (**bsea.in**). This file includes set of information about the application such as grid sizes (*Lm*, *Mm* and *N*), number of tiles in I and J direction (domain decomposition parameters, *NtileI* and *NtileJ*), model time steps and simulation lenght (*NTIMES*, *DT*, *NDTFAST*), output and restart file interval (*NRREC*, *LcycleRST*, *NRST*, *LDEFOUT*, *NHIS* and *NAVG*), diffusion and viscosity parameters (*TNU2*, *TNU4*, *VISC2* and *VISC4*), [Jerlow Water Type](https://www.myroms.org/projects/src/ticket/609) (*WTYPE*), vertical grid parameters (must be consistent with grid file, *Vtransform*, *Vstretching*, *THETA_S*, *THETA_B* and *TCLINE*), definition related with grid, initial condition and forcing files (*GRDNAME*, *ININAME* and *FRCNAME*).

To run the model, use following steps and

```
> cd /RS/users/$USER/workshop/day2
> ln -s src/oceanM .
> mkdir output
> wget --no-check-certificate https://github.com/uturuncoglu/summer_school-resm_2016/raw/master/day2/bsea.in
> cp src/roms-r809/ROMS/External/varinfo.dat .
```

edit **varinfo.dat**, which is used to define unit conversions (i.e. *scale_factor* and *add_offset*). The original definitions are

```
'Pair'                                             ! Input
  'surface air pressure'
  'millibar'                                       ! [millibar]
  'Pair, scalar, series'
  'pair_time'
  'idPair'
  'r2dvar'
  1.0d0
...
'Qair'                                             ! Input
  'surface air relative humidity'                  !  relative    or  specific
  'percentage'                                     ! [percentage  or  g/kg    ]
  'Qair, scalar, series'
  'qair_time'
  'idQair'
  'r2dvar'                                         ! relative        specific
  0.01d0  
```

and the modified definitions are

```
'Pair'                                             ! Input
  'surface air pressure'
  'millibar'                                       ! [millibar]
  'Pair, scalar, series'
  'pair_time'
  'idPair'
  'r2dvar'
  0.01d0
...
'Qair'                                             ! Input
  'surface air relative humidity'                  !  relative    or  specific
  'percentage'                                     ! [percentage  or  g/kg    ]
  'Qair, scalar, series'
  'qair_time'
  'idQair'
  'r2dvar'                                         ! relative        specific
  1.0d0  
```
edit **bsea.in** and modify parameters if it is necessary. Then, the the model can be submitted to LSF job scedular using following job submission script,

```
#!/bin/bash
#BSUB -P workshop
#BSUB -J roms 
#BSUB -q workshop 
#BSUB -m anadolu_dual 
#BSUB -o %J.out
#BSUB -e %J.err
#BSUB -a intelmpi4
#BSUB -n 32

mpirun.lsf ./oceanM bsea.in >& romsout.txt
```

and the job can be submitted using **bsub < roms.lsf** command.

## Day3: Model Coupling with Regional Earth System Model (RegESM) modeling system - Atmosphere-Ocean Example

The open source RegESM modeling system is developed by ITU and the project is maintained by [GitHub](https://github.com/uturuncoglu/RegESM) to allow version controlling and issue traking.

The basic steps to install coupled modeling system include:

1. Installation of RegCM atmosphere model in coupling mode (simply install with --enable-cpl configure option)
2. Installation of ROMS ocean model with coupling support. In this case, you need to apply patch (a file with addtional source code) to original version of ROMS ocean model to allow coupling. Then, install the model with coupling options (defined via CPP options).
3. Installation of the RegESM modeling system using previous installation of RegCM and ROMS models (step 1-2).
4. Preparing configuration files of individual model components (RegCM and ROMS) as well as configuration files of the coupiled model (namelist.rc and exfield.tbl)

### Installation of RegCM with coupling support

The RegCM model is already compatible with RegESM driver. In this case, the used can choose BATS (Biosphere Atmosphere Transfer Scheme) or CLM (Community Land Model) as land-surface model. To install RegCM with coupling support,

```
> cd /RS/projects/workshop/$USER
> mkdir -p day3/src/atm
> cd day3/src/atm
> wget --no-check-certificate https://gforge.ictp.it/gf/download/frsrelease/252/1580/RegCM-4.5.0.tar.gz
> tar -zxvf RegCM-4.5.0.tar.gz
> cd RegCM-4.5.0
> ./configure --prefix=`pwd` --enable-cpl CC=${CC} FC=${FC} MPIFC=mpiifort
> make install
```

The source code that is already installed with coupling support can be accessed from **/RS/progs/workshop/hands-on/day3/src/atm/RegCM-4.5.0** directory. It can be used to install driver (RegESM).

### Installation of ROMS with coupling support

The origical version of ROMS ocean model does not support coupling with RegESM driver. So, user need to apply small patch that includes set of modifications in the model source code to activate coupling. It basically adds extra CPP configuration options such as **REGCM_COUPLING**, **HD_COUPLING** and **MODIFIED_CALDATE**.

To retrive the ocean model and applying patch, following commands can be used,

```
> cd /RS/projects/workshop/$USER/day3
> mkdir -p src/ocn
> cd src/ocn

if you already registered and have user name and password
> svn checkout -r 809 --username [ROMS USER NAME] https://www.myroms.org/svn/src/trunk roms-r809

if not, you could download the source code from GitHub
> wget --no-check-certificate https://github.com/uturuncoglu/summer_school-resm_2016/blob/master/day2/src/roms-r809.tar.gz
> tar -zxvf roms-r809.tar.gz 
> cd roms-r809
> wget --no-check-certificate https://github.com/uturuncoglu/RegESM/raw/master/tools/ocn/roms-r809.patch
> patch -p 3 < roms_r809.patch
```

To install user needs to have a configuration file (*.h) that constains the definition of options (as CPP flags) for the simulations. To install the model, it is necessary to include extra CPP options and modify the bsea.h used in second day of the school.

The standalone ocean model simulation, the bulk flux formula is used to calculate surface fluxes from set of meteorological fields (surface air temperature, specific humidity, u and v component of wind speed, precipitation, air pressure, downwelling longwave radiation, shortwave radiaition) over the sea. 

In the coupled model, there is no need to use bulk flux package and atmospheric model provides required fields (u and v component of wind stress, net heat flux, net freshwater flux - simply E-P, shortwave radiation - used by LMD vertical mixing scheme and atmospheric pressure). To that end, **bsea.h** file is slightly different from the file used in the standalone model simulation.

```
> cd /RS/projects/workshop/$USER/day3/src/ocn 
> wget --no-check-certificate https://github.com/uturuncoglu/summer_school-resm_2016/raw/master/day3/bsea.h
> cp /RS/projects/workshop/$USER/day2/src/build.sh .

Edit MY_ROOT_DIR to specify new installation path and roms-r809/Compilers/Linux-ifort.mk file for system specific definitions

> ./build.sh
```

This will install ROMS ocean model with coupling support. Now, both atmosphere and ocean models are ready to use with RegESM driver.

### Installation of RegESM driver

To install driver, the following commands can be used,

```
> cd /RS/projects/workshop/$USER
> mkdir -p day3/src/drv
> cd day3/src/drv
> git clone https://github.com/uturuncoglu/RegESM.git
> cd RegESM
> ./bootstrap.sh
> ./configure --prefix=`pwd` --with-atm=/RS/projects/workshop/$USER/day3/src/atm/RegCM-4.5.0 --with-ocn=/RS/projects/workshop/$USER/day3/src/ocn/Build CC=${CC} FC=${FC} MPIFC=mpiifort
> make
> make install
> cd ../../../
> ln -s src/drv/RegESM/regesm.x .
```

The atmosphere and ocean model installation paths can be also replaced with **/RS/progs/workshop/hands-on/day3/src/atm/RegCM-4.5.0** and **/RS/progs/workshop/hands-on/day3/src/ocn/Build**. These paths includes installations that are done previously.

### Running fully coupled atmosphere-ocean modeling system (RegESM)

To run the model, user need to provide configuration files for atmosphere, ocean and driver (RegESM) and input files (initial and boundary conditions for the models, the atmospheric forcing for the ocean model will be provided by active atmosphere model).

To define exchange fields between model components, a special configuration file is needed (**exfield.tbl**). The following exchange field table include information for driver and the listed fields will be transferred (includes also online interpolation) between model components. This file must be placed under **/RS/projects/workshop/$USER/day3**.

```
6 atm2ocn T
taux:eastward_10m_wind_stress:bilinear:cross:u:N/m2:m2/s2:cf3:0.0:F
tauy:northward_10m_wind_stress:bilinear:cross:v:N/m2:m2/s2:cf3:0.0:F
psfc:surface_air_pressure:bilinear:cross:cross:mb:mb:1.0:0.0:F
swrd:shortwave_radiation:bilinear:cross:cross:W/m^2:Cm/s:cf2:0.0:T
sflx:water_flux_into_sea_water:bilinear:cross:cross:kg/m^2s:m/s:0.001:0.0:T
nflx:surface_heat_flux:bilinear:cross:cross:W/m^2:Cm/s:cf2:0.0:T
1 ocn2atm T
sst:sea_surface_temperature:bilinear:cross:cross:C:K:1.0:273.16:F
```

The detailed information about the **exfield.tbl** can be found in the user guide of the RegESM model that can be found in [here](https://github.com/uturuncoglu/RegESM/blob/master/docs/user_guide.pdf).

Then, we need to copy configuration files of RegCM and ROMS from the directories used in first and second day of the school.

```
> cd /RS/projects/workshop/$USER/day3
> cp ../day1/regcm.in_TR10km .
> cp ../day2/bsea.in bsea.in
> cp ../day2/varinfo.dat varinfo.dat
```

and configuration files will be modified slightly for fully coupled model simulation. Please edit directory definitions in *dirter*, *dirglob*, *dirout* and change / add following configuration parameters in **regcm.in_TR10km**.

```
...
 &physicsparam
...
 iocncpl =          1,
...
 idcsst = 0,
 /
...
...
 &cplparam
 cpldt        = 10800.,
 zomax        = 0.005,
 ustarmax     = 1.2,
 /   
```

The *cplparam* includes definitions related with model coupling. Also not that the **cpldt** parameter is the coupling time step (set as 3 hours) and must be consistent with the time step defined in driver configuration file.

Now, the driver configuration file (**namelist.rc**) can be created.

```
> cd cd /RS/projects/workshop/$USER/day3
> cp src/drv/RegESM/namelist.rc .
```

In this case, **namelist.rc** file must be modified. The detailed information about the options can be found in the user guide of the RegESM model that can be found in [here](https://github.com/uturuncoglu/RegESM/blob/master/docs/user_guide.pdf).

To create dummy ocean forcing file (full of zeros) and directories,

```
> mkdir input output
> cd input
> ln -s ../../day1/input/* .
> ln -s ../../day2/input/* .
> cd input
> wget --no-check-certificate https://github.com/uturuncoglu/summer_school-resm_2016/raw/master/day3/roms_forc_nobulk_dummy.ncl
> ncl roms_forc_nobulk_dummy.ncl
```

To run the model, following LSF script can be used,

```
#!/bin/bash
#BSUB -P workshop
#BSUB -J regesm 
#BSUB -q workshop
#BSUB -m anadolu_dual 
#BSUB -o %J.out
#BSUB -e %J.err
#BSUB -a intelmpi4
#BSUB -n 32

mpirun.lsf ./regesm.x regcm.in_TR10km bsea.in >& regesmout.txt
```
