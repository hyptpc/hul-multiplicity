// -*- C++ -*-

#include "FPGAModule.hh"
#include "RegisterMap.hh"

//_____________________________________________________________________________
int
main(int argc, char** argv)
{
  FPGAModule module("192.168.10.69");
  int ret = module.WriteModule(BCT::mid, BCT::ReConfig, 0);
  return ret;
}
