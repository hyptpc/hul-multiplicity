// -*- C++ -*-

#ifndef RBCP_HEADER_HH
#define RBCP_HEADER_HH

#include <cstdint>

/*************************************************
*                                                *
* SiTCP Remote Bus Control Protocol              *
* Header file                                    *
*                                                *
* 2010/05/31 Tomohisa Uchida                     *
*                                                *
*************************************************/

//_____________________________________________________________________________
struct RbcpHeader_t
{
  uint8_t  type;
  uint8_t  command;
  uint8_t  id;
  uint8_t  length;
  uint32_t address;
};

#endif
