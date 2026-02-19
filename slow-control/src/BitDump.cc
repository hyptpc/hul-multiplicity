// -*- C++ -*-

// Author: Tomonori Takahashi

#include "BitDump.hh"

#include <bitset>

#include <iostream>

namespace hddaq
{

//_____________________________________________________________________________
BitDump::BitDump(void)
  : m_count(0)
{
  std::cout << "#D n-th  : data (MSB --- LSB)" << std::hex << std::endl;
}

//_____________________________________________________________________________
BitDump::~BitDump(void)
{
  std::cout << std::dec << std::endl;
}

//_____________________________________________________________________________
void
BitDump::operator ()(unsigned int data)
{
  std::bitset<32> bits(data);
  //   std::cout << std::hex;
  std::cout.width(8);
  std::cout.fill('0');
  std::cout << m_count << " : ";// << std::dec;

  std::cout << bits << "   ";
  std::cout.width(8);
  std::cout.fill('0');
  std::cout << data << "\n";
  ++m_count;
  return;
}

//_____________________________________________________________________________
void
BitDump::operator ()(unsigned short data)
{
  std::bitset<16> bits(data);
  std::cout.width(8);
  std::cout.fill('0');
  std::cout << m_count << " : ";

  std::cout << bits << "   ";
  std::cout.width(4);
  std::cout.fill('0');
  std::cout << data << "\n";
  return;
}

}
