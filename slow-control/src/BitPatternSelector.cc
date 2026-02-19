// -*- C++ -*-

#include "BitPatternSelector.hh"

#include <iostream>
#include <vector>

//_____________________________________________________________________________
BitPatternSelector::BitPatternSelector( void )
{
}

//_____________________________________________________________________________
BitPatternSelector::~BitPatternSelector( void )
{
}

//_____________________________________________________________________________
uint32_t
BitPatternSelector::Ctrl( const std::vector<int>& val )
{
  std::bitset<kMaxInputs> reg_ctrl;
  for( int i=0, n=val.size(); i<n; ++i ){
    if( val[i] == 0 || val[i] == 1 ){ // VETO or ON
      reg_ctrl.set( n-1-i );
    }
  };
  return reg_ctrl.to_ulong();
}

//_____________________________________________________________________________
uint32_t
BitPatternSelector::Coin( const std::vector<int>& val )
{
  std::bitset<kMaxInputs> reg_coin;
  for( int i=0, n=val.size(); i<n; ++i ){
    if( val[i] == 1 ){ // ON
      reg_coin.set( n-1-i );
    }
  }
  return reg_coin.to_ulong();
}
