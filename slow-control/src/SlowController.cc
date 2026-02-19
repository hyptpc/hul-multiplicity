// -*- C++ -*-

#include "SlowController.hh"

#include <algorithm>
#include <iostream>
#include <sstream>
#include <string>

#include "FPGAModule.hh"

//_____________________________________________________________________________
SlowController::SlowController( void )
  : m_param_name(),
    m_param_map(),
    m_out_name( "/dev/null" ),
    m_out_stream( m_out_name ),
    m_fpga_module( nullptr ),
    m_verbose( false )
{
}

//_____________________________________________________________________________
SlowController::~SlowController( void )
{
  if( m_fpga_module )
    delete m_fpga_module;
  if( m_out_stream.is_open() )
    m_out_stream.close();
}

//_____________________________________________________________________________
int
SlowController::Get( std::string key ) const
{
  for( auto& c : key )
    c = std::toupper( c );
  auto itr = m_param_map.find( key );
  if( itr == m_param_map.end() ){
    std::cerr << "No such key! " << key << std::endl ;
    std::exit( EXIT_FAILURE );
  } else {
    return itr->second;
  }
}

//_____________________________________________________________________________
void
SlowController::SetFPGAModule( FPGAModule* module )
{
  if( m_fpga_module )
    delete m_fpga_module;
  m_fpga_module = module;
}

//_____________________________________________________________________________
void
SlowController::SetParamFile( const std::string& name )
{
  m_param_name = name;

  std::ifstream ifs( m_param_name.c_str() );
  if( !ifs.is_open() ){
    std::cerr << "No such file : " << m_param_name << std::endl;
    std::exit( EXIT_FAILURE );
  }
  if( m_verbose )
    std::cout << "Param   : " << m_param_name << std::endl;
  std::string line;
  while( ifs.good() && std::getline( ifs, line ) ){
    if( line.empty() || line[0] == '#' )
      continue;
    std::stringstream ss( line );
    std::string key;
    uint32_t value;
    ss >> key >> value;
    if( key.empty() || key[0] == '#' )
      continue;
    for( auto& c : key )
      c = std::toupper( c );
    m_param_map[key] = value;
    if( m_verbose )
      std::cout << "   key = " << key << ", value = " << value << std::endl;
  }
}

//_____________________________________________________________________________
void
SlowController::SetOutFile( const std::string& name )
{
  m_out_name = name;
  m_out_stream.close();
  m_out_stream.open( name.c_str() );
  m_out_stream << m_out_name << std::endl << std::endl;
  if( m_verbose )
    std::cout << "OutFile : " << m_out_name << std::endl;
}

//_____________________________________________________________________________
int
SlowController::Read( uint32_t module_id, uint32_t local_address,
                      const std::string& label, uint32_t n_read )
{
  if( !m_fpga_module )
    return -1;
  int ret = m_fpga_module->ReadModule( module_id, local_address, n_read );
  return ret;
}

//_____________________________________________________________________________
int
SlowController::Write( uint32_t module_id, uint32_t local_address,
                       const std::string& label )
{
  return Write( module_id, local_address, label, Get( label ) );
}

//_____________________________________________________________________________
int
SlowController::Write( uint32_t module_id, uint32_t local_address,
                       const std::string& label,
                       uint32_t write_data, uint32_t n_read )
{
  if( !m_fpga_module )
    return -1;
  int ret = m_fpga_module->WriteModule( module_id, local_address, write_data );
  if( ret < 0 ){
    std::cerr << "Something is wrong" << std::endl;
    std::exit( EXIT_FAILURE );
  }
  if( n_read > 0 )
    ret = m_fpga_module->ReadModule( module_id, local_address, n_read );
  else
    ret = 0;
  m_out_stream << std::left << std::setw(30) << label
               << std::right << std::setw(8) << ret << std::endl;
  if( m_verbose ){
    if( ret != write_data && n_read > 0 ){
      std::cout << "\033[1;33m";
    }
    std::cout << std::left << std::setw(30) << label
              << "W/R = " << write_data << "/" << ret
              << "\033[0m" << std::endl;
  } else {
    if( ret != write_data )
      std::cout << std::left << std::setw(30) << label
                << "W/R = " << write_data << "/" << ret
                << "\033[0m" << std::endl;
  }
  return ret;
}
