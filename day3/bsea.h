/*
** svn $Id: upwelling.h 323 2009-03-06 23:58:50Z arango $
*******************************************************************************
** Copyright (c) 2002-2009 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.txt                                                    **
*******************************************************************************
**
*/
#define REGCM_COUPLING
#define MODIFIED_CALDATE
#define PERFECT_RESTART
#define AVERAGES
#define AVERAGES_FLUX

/*
** Options associated with momentum equations:
*/

#define UV_ADV
#define UV_COR
#define UV_VIS2
#define UV_QDRAG

/*
** Options associated with tracers equations:
*/

#define TS_U3HADVECTION
#define TS_C4VADVECTION
#define TS_DIF2
#define SALINITY
#define NONLIN_EOS
#define SOLAR_SOURCE

/*
** Options for pressure gradient algorithm:
*/

#define DJ_GRADPS
#define ATM_PRESS

/*
** Options for atmospheric boundary layer:
*/

#define SHORTWAVE

/*
** Options for model configuration:
*/

#define SOLVE3D
#define MASKING
#undef  SPLINES

/*
** Options for analytical fields configuration:
*/

#define ANA_BSFLUX
#define ANA_BTFLUX

/*
** Options for horizontal mixing of momentum:
*/

#define MIX_S_UV
#define MIX_GEO_TS 

/*
** Options for vertical mixing momentum and tracers:
*/

#define LMD_MIXING

#ifdef LMD_MIXING
# define LMD_RIMIX
# define LMD_CONVEC
# define LMD_SKPP
# define LMD_BKPP
# define LMD_NONLOCAL
# undef  LMD_DDMIX
#endif

/*
** Options for close boundary conditions:
*/

#define EASTERN_WALL
#define NORTHERN_WALL
#define SOUTHERN_WALL
#define WESTERN_WALL

