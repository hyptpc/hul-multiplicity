// -*- C++ -*-

#ifndef REGISTER_MAP_HH
#define REGISTER_MAP_HH

#include <string>

//_____________________________________________________________________________
namespace RGN1
{
static const uint32_t mid = 0x1;
static const uint32_t NumOfSegDet = 64;
static const uint32_t kDataWidth = 8;
static const uint32_t kNumOfRegisters = NumOfSegDet/kDataWidth;
enum ELocalAddress
{
  kSELECTOR_01_08 = 0x000, // W/R, [7:0], select segment
  kSELECTOR_09_16 = 0x010, // W/R, [7:0], select segment
  kSELECTOR_17_24 = 0x020, // W/R, [7:0], select segment
  kSELECTOR_25_32 = 0x030, // W/R, [7:0], select segment
  kSELECTOR_33_40 = 0x040, // W/R, [7:0], select segment
  kSELECTOR_41_48 = 0x050, // W/R, [7:0], select segment
  kSELECTOR_49_56 = 0x060, // W/R, [7:0], select segment
  kSELECTOR_57_64 = 0x070, // W/R, [7:0], select segment
  kIN_WIDTH       = 0x080, // W/R, [6:0], select segment
  kOUT_WIDTH      = 0x090, // W/R, [6:0], select segment
  kMULTIPLICITY_1  = 0x110, // W/R, [6:0], select segment
  kMULTIPLICITY_2  = 0x120, // W/R, [6:0], select segment
  kMULTIPLICITY_3  = 0x130, // W/R, [6:0], select segment
  kMULTIPLICITY_4  = 0x140  // W/R, [6:0], select segment
};
}

//_____________________________________________________________________________
namespace BCT
{
static const uint32_t mid = 0xe;
enum ELocalAddress{
  Reset    = 0x000, // W/-, assert reset signal from BCT
  Version  = 0x010, // -/R, [31:0]
  ReConfig = 0x020  // W/-, Reconfig FPGA by SPI
};
static const uint32_t kVersionLen = 4;
}

#endif
