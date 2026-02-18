// -*- C++ -*-

// Author: Tomonori Takahashi

#ifndef HDDAQ__BIT_DUMP_H
#define HDDAQ__BIT_DUMP_H

#include <functional>

namespace hddaq
{

//_____________________________________________________________________________
class BitDump
  : public std::unary_function<unsigned int, void>
{
private:
  int m_count;

public:
  BitDump(void);
  ~BitDump(void);

  void operator ()(unsigned int data);
  void operator ()(unsigned short data);

};

}
#endif
