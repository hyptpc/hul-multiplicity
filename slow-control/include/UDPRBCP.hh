// -*- C++ -*-

#ifndef UDP_RBCP_HH
#define UDP_RBCP_HH

#include "Uncopyable.hh"

#include <vector>
#include <algorithm>


struct RbcpHeader_t;

//_____________________________________________________________________________
class UDPRBCP : Uncopyable<UDPRBCP>
{
public:
  static const unsigned int udp_buf_size_ = 4096;
  static const unsigned int rbcp_ver_     = 0xFF;
  enum RbcpDebugMode
    {
      kDispNo,
      kDispInteractive,
      kDispDebug,
      kRbcpDebugModeSize
    };

private:
  static const unsigned int rbcp_cmd_wr_  = 0x80;
  static const unsigned int rbcp_cmd_rd_  = 0xC0;

  const char*   ipAddr_;
  unsigned int  port_;
  RbcpHeader_t* sendHeader_;

  int           length_rd_;
  char          wd_buffer_[udp_buf_size_];
  unsigned char rd_buffer_[udp_buf_size_];

  RbcpDebugMode mode_;

public:
  UDPRBCP(const char* ipAddr, unsigned int port, RbcpHeader_t* sendHeader,
	  RbcpDebugMode mode=kDispInteractive);
  virtual ~UDPRBCP();

  void SetDispMode(RbcpDebugMode mode);
  void SetWD(unsigned int address, unsigned int length, char* sendData);
  void SetRD(unsigned int address, unsigned int legnth);
  int  DoRBCP();

  void CopyRD(std::vector<unsigned char>& buffer);
};

inline void UDPRBCP::CopyRD(std::vector<unsigned char>& buffer){
  std::copy(rd_buffer_, rd_buffer_ +length_rd_,
	    back_inserter(buffer)
	    );
}

#endif
