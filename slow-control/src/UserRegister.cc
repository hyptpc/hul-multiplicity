// -*- C++ -*-

#include <bit>
#include <iostream>
#include <numeric>
#include <libgen.h>

#include "BitPatternSelector.hh"
#include "DetectorID.hh"
#include "FPGAModule.hh"
#include "RegisterMap.hh"
#include "SlowController.hh"

enum EArgv { kProcess, kParamFile, kArgc };

//_____________________________________________________________________________
int
main(int argc, char** argv)
{
  if (argc != kArgc) {
    std::cout << "Usage " << ::basename(argv[kProcess])
              << " [param file]" << std::endl;
    return 0;
  }

  SlowController controller;
  controller.SetVerbose();
  controller.SetParamFile(argv[kParamFile]);
  controller.SetOutFile("last.log");
  controller.SetFPGAModule(new FPGAModule("192.168.10.69"));

  { // Region1 ________________________________________________________________
    using namespace RGN1;
    for (int i=0; i<kNumOfRegisters; ++i) {
      std::bitset<kDataWidth> det_bit;
      for (int j=0; j<kDataWidth; ++j) {
        det_bit[j] = controller.Get("SELECTOR_" +
                                    std::to_string(i*kDataWidth + j + 1));
      }
      controller.Write(mid, i*0x010, "SELECTOR_" + std::to_string(i),
                       det_bit.to_ulong());
    }
    controller.Write(mid, kIN_WIDTH, "IN_WIDTH");
    controller.Write(mid, kOUT_WIDTH, "OUT_WIDTH");
    controller.Write(mid, kMULTIPLICITY_1, "MULTIPLICITY_1");
    controller.Write(mid, kMULTIPLICITY_2, "MULTIPLICITY_2");
    controller.Write(mid, kMULTIPLICITY_3, "MULTIPLICITY_3");
    controller.Write(mid, kMULTIPLICITY_4, "MULTIPLICITY_4");
  }
  std::cout << "Successfully finished!" << std::endl;
  return EXIT_SUCCESS;
}
