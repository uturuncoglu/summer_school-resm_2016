;-----------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;-----------------------------------------------------------
;***********************************************************
;*** This script is used to create dummy forcing file ******
;*** for the coupled RegCM-ROMS model **********************
;***********************************************************
;***********************************************************
;*** Ufuk Turuncoglu ***************************************
;*** Send bug reports to turuncu@be.itu.edu.tr *************
;***********************************************************
begin
  ;--- parameters ---
  dstr = "2010-01-02"
  clen = 2
  cval = 0.0d0 ;1.0d20
  
  if (clen .eq. 365) then
    time = fspan(0,364.75,365*4)
  else
    time = fspan(0,clen-0.25,tointeger(clen)*4)
  end if

  ;--- open grid file --- 
  grid = addfile("BSEA_grd_v4.nc", "r")

  ;--- read variables ---
  x_rho = grid->x_rho
  y_rho = grid->y_rho
  x_u = grid->x_u
  y_u = grid->y_u
  x_v = grid->x_v
  y_v = grid->y_v

  ;--- get dimension sizes ---
  dims = dimsizes(x_rho)
  eta_rho = dims(0)
  xi_rho = dims(1)
  dims = dimsizes(x_u)
  eta_u = dims(0)
  xi_u = dims(1)
  dims = dimsizes(x_v)
  eta_v = dims(0)
  xi_v = dims(1)
  ocean_time = dimsizes(time)

  ;--- get variables ---
  x_rho = grid->x_rho
  y_rho = grid->y_rho
  x_u = grid->x_u
  y_u = grid->y_u
  x_v = grid->x_v
  y_v = grid->y_v

  ;--- create forcing file ---
  fname = "BSEA_forcing_dummy.nc"
  system("/bin/rm -f "+fname)
  fout = addfile(fname, "c")

  ;--- define mode on ---
  setfileoption(fout, "DefineMode", True)

  ;--- add global attributes ---
  attr = True
  attr@title = "RegCM-ROMS dummy forcing file"
  attr@source_file = "roms_dummy.ncl"
  attr@creation_date = systemfunc ("date")
  fileattdef(fout, attr)
  delete(attr)

  ;--- define dimensions ---
  dimNames = (/ "xi_rho"   , "xi_u"     , "xi_v"     , "eta_rho"  , \
                "eta_v"    , "eta_u"    , "sms_time" , "srf_time" , \
                "shf_time" , "swf_time" , "pair_time" /)
  dimSizes = (/ xi_rho, xi_u, xi_v, eta_rho, eta_v, eta_u, ocean_time, \
                ocean_time, ocean_time, ocean_time, ocean_time /)
  dimUnlim = (/ False, False, False, False, False, False, False, \
                False, False, False, False /)
  filedimdef(fout, dimNames, dimSizes, dimUnlim)

  filevardef(fout, "sustr" , typeof(x_rho), (/ "sms_time", "eta_u"  , "xi_u"   /))
  filevardef(fout, "svstr" , typeof(y_rho), (/ "sms_time", "eta_v"  , "xi_v"   /))
  filevardef(fout, "Pair" , typeof(y_rho), (/ "pair_time", "eta_rho", "xi_rho" /))
  filevardef(fout, "swrad" , typeof(y_rho), (/ "srf_time", "eta_rho", "xi_rho" /))
  filevardef(fout, "shflux" , typeof(y_rho), (/ "shf_time", "eta_rho", "xi_rho" /))
  filevardef(fout, "swflux" , typeof(y_rho), (/ "swf_time", "eta_rho", "xi_rho" /))
  filevardef(fout, "sms_time" , typeof(x_rho), "sms_time" )
  filevardef(fout, "pair_time", typeof(x_rho), "pair_time" )
  filevardef(fout, "srf_time" , typeof(x_rho), "srf_time" )
  filevardef(fout, "shf_time" , typeof(x_rho), "shf_time" )
  filevardef(fout, "swf_time" , typeof(x_rho), "swf_time" )

  ;--- add attributes ---
  ;--- time dimensions ---
  attr = True
  attr@long_name = "surface momentum stress time"
  attr@units = "days since "+dstr+" 00:00:00" 
  attr@calendar = "standard"
  if (clen .gt. 0) then
  attr@cycle_length = clen
  end if
  attr@field = "sms_time, scalar, series" ;
  filevarattdef(fout, "sms_time", attr)
  delete(attr)

  attr = True
  attr@long_name = "solar shortwave radiation time"
  attr@units = "days since "+dstr+" 00:00:00"
  attr@calendar = "standard"
  if (clen .gt. 0) then
  attr@cycle_length = clen
  end if
  attr@field = "srf_time, scalar, series" ;
  filevarattdef(fout, "srf_time", attr)
  delete(attr)

  attr = True
  attr@long_name = "surface pressure time"
  attr@units = "days since "+dstr+" 00:00:00"
  attr@calendar = "standard"
  if (clen .gt. 0) then
  attr@cycle_length = clen
  end if
  attr@field = "pair_time, scalar, series" ;
  filevarattdef(fout, "pair_time", attr)
  delete(attr)

  attr = True
  attr@long_name = "surface heat flux time"
  attr@units = "days since "+dstr+" 00:00:00"
  attr@calendar = "standard"
  if (clen .gt. 0) then
  attr@cycle_length = clen
  end if
  attr@field = "shf_time, scalar, series" ;
  filevarattdef(fout, "shf_time", attr)
  delete(attr)

  attr = True
  attr@long_name = "surface freshwater flux time"
  attr@units = "days since "+dstr+" 00:00:00"
  attr@calendar = "standard"
  if (clen .gt. 0) then
  attr@cycle_length = clen
  end if
  attr@field = "swf_time, scalar, series" ;
  filevarattdef(fout, "swf_time", attr)
  delete(attr)

  ;--- variables ---
  attr = True
  attr@long_name = "surface u-momentum stress"
  attr@units = "Newton meter-2"
  attr@time = "sms_time"
  filevarattdef(fout, "sustr", attr)
  delete(attr)

  attr = True
  attr@long_name = "surface v-momentum stress"
  attr@units = "Newton meter-2" 
  attr@time = "sms_time"
  filevarattdef(fout, "svstr", attr)
  delete(attr)

  attr = True
  attr@long_name = "surface air pressure"
  attr@units = "pascal"
  attr@time = "pair_time"
  filevarattdef(fout, "Pair", attr)
  delete(attr)

  attr = True
  attr@long_name = "solar shortwave radiation"
  attr@units = "Watts meter-2"
  attr@time = "srf_time"
  filevarattdef(fout, "swrad", attr)
  delete(attr)

  attr = True
  attr@long_name = "surface net heat flux"
  attr@units = "Watts meter-2"
  attr@time = "shf_time"
  filevarattdef(fout, "shflux", attr)
  delete(attr)

  attr = True
  attr@long_name = "surface freshwater flux (E-P)"
  attr@units = "centimeter day-1"
  attr@time = "swf_time"
  filevarattdef(fout, "swflux", attr)
  delete(attr)

  ;--- fill data ---
  fout->sms_time  = (/ time /)
  fout->pair_time = (/ time /)
  fout->srf_time  = (/ time /)
  fout->shf_time  = (/ time /)
  fout->swf_time  = (/ time /)

  zeros_u = new((/ ocean_time, eta_u, xi_u /), typeof(x_u), 1.0d20)
  zeros_u = cval
  fout->sustr = (/ zeros_u /)

  zeros_v = new((/ ocean_time, eta_v, xi_v /), typeof(x_v), 1.0d20)
  zeros_v = cval
  fout->svstr = (/ zeros_v /)

  zeros_r = new((/ ocean_time, eta_rho, xi_rho /), typeof(x_rho), 1.0d20)
  zeros_r = cval
  fout->Pair = (/ zeros_r /)
  fout->swrad  = (/ zeros_r /)
  fout->shflux  = (/ zeros_r /)
  fout->swflux  = (/ zeros_r /)
end
