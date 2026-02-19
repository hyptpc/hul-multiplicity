// -*- C++ -*-

#include "FPGAModule.hh"

#include <iostream>

#include "UDPRBCP.hh"
#include "RbcpHeader.hh"

//_____________________________________________________________________________
FPGAModule::FPGAModule(const std::string& ip_addr,
                       uint32_t port,
                       RbcpHeader_t* send_header,
                       UDPRBCP::RbcpDebugMode disp_mode)
  : m_ip_addr(ip_addr.c_str()),
    m_port(port),
    m_disp_mode(disp_mode)
{
  if (!send_header) {
    send_header = new RbcpHeader_t;
    send_header->type = UDPRBCP::rbcp_ver_;
    send_header->id = 0;
  }
  m_send_header = send_header;
}

//_____________________________________________________________________________
FPGAModule::FPGAModule(const char* ip_addr,
                       uint32_t port,
                       RbcpHeader_t* send_header,
                       UDPRBCP::RbcpDebugMode disp_mode)
  : m_ip_addr(ip_addr),
    m_port(port),
    m_disp_mode(disp_mode)
{
  if (!send_header) {
    send_header = new RbcpHeader_t;
    send_header->type = UDPRBCP::rbcp_ver_;
    send_header->id = 0;
  }
  m_send_header = send_header;
}

//_____________________________________________________________________________
FPGAModule::~FPGAModule(void)
{
}

//_____________________________________________________________________________
int
FPGAModule::WriteModule(uint32_t module_id,
                        uint32_t local_address,
                        uint32_t write_data)
{
  uint32_t udp_addr
    = ((module_id & module_id_mask) << module_id_shift)
    + ((local_address & address_mask) << address_shift)
    + ((write_data & exdata_mask) >> exdata_shift);
  char udp_wd = static_cast<char>(write_data & data_mask);
  UDPRBCP udpMan(m_ip_addr, m_port, m_send_header, m_disp_mode);
  udpMan.SetWD(udp_addr, 1, &udp_wd);
  return udpMan.DoRBCP();
}

//_____________________________________________________________________________
uint32_t
FPGAModule::ReadModule(uint32_t module_id,
                       uint32_t local_address,
                       int n_cycle)
{
  if (n_cycle > 4) {
    std::cerr << "#E :FPGAModule::ReadModule, too many cycle "
              << n_cycle << std::endl;
    return 0xeeeeeeee;
  }

  uint32_t data = 0;
  for (int i=0; i<n_cycle; ++i) {
    if ( this->ReadModule_nByte(module_id, local_address+i, 1) > -1) {
      uint32_t tmp = (uint32_t)m_rd_data[0];
      data += (tmp & 0xff) << 8*i;
    } else {
      return 0xeeeeeeee;
    }
  }

  m_rd_word = data;
  return m_rd_word;
}

//_____________________________________________________________________________
int
FPGAModule::ReadModule_nByte(uint32_t module_id,
                             uint32_t local_address,
                             uint32_t length)
{
  m_rd_data.clear();
  uint32_t udp_addr
    = ((module_id & module_id_mask) << module_id_shift)
    + ((local_address & address_mask) << address_shift);

  UDPRBCP udpMan(m_ip_addr, m_port, m_send_header, m_disp_mode);
  udpMan.SetRD(udp_addr, length);
  int ret = udpMan.DoRBCP();
  if (ret > -1){ udpMan.CopyRD(m_rd_data); }
  return ret;
}
