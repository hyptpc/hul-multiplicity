// -*- C++ -*-

#include "UDPRBCP.hh"

#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <netinet/in.h>

#include "BitDump.hh"
#include "RbcpHeader.hh"

//_____________________________________________________________________________
UDPRBCP::UDPRBCP(const char* ipAddr,
                 unsigned int port,
                 RbcpHeader_t* sendHeader,
		 RbcpDebugMode mode)
  : ipAddr_(ipAddr),
    port_(port),
    sendHeader_(sendHeader),
    length_rd_(0),
    mode_(mode)
{
}

//_____________________________________________________________________________
UDPRBCP::~UDPRBCP(void)
{
}

//_____________________________________________________________________________
void
UDPRBCP::SetDispMode(RbcpDebugMode mode)
{
  mode_ = mode;
}

//_____________________________________________________________________________
void
UDPRBCP::SetWD(unsigned int address, unsigned int length, char* sendData)
{
  sendHeader_->command = rbcp_cmd_wr_;
  sendHeader_->length  = length;
  sendHeader_->address = htonl(address);
  std::memcpy(wd_buffer_, sendData, length);
}

//_____________________________________________________________________________
void
UDPRBCP::SetRD(unsigned int address, unsigned int length)
{
  sendHeader_->command = rbcp_cmd_rd_;
  sendHeader_->length  = length;
  sendHeader_->address = htonl(address);
}

//_____________________________________________________________________________
int
UDPRBCP::DoRBCP(void)
{
  struct sockaddr_in sitcpAddr;
  int sock;

  struct timeval timeout;
  fd_set setSelect;

  int sndDataLen;
  int cmdPckLen;

  unsigned char sndBuf[udp_buf_size_];
  int i, j = 0;
  int rcvdBytes;
  unsigned char rcvdBuf[udp_buf_size_];
  int numReTrans =0;

  /* Create a Socket */
  if(mode_ == kDispInteractive) {printf("Create socket...\n");}

  sock = socket(AF_INET, SOCK_DGRAM, 0);

  sitcpAddr.sin_family      = AF_INET;
  sitcpAddr.sin_port        = htons(port_);
  sitcpAddr.sin_addr.s_addr = inet_addr(ipAddr_);

  sndDataLen = (int)sendHeader_->length;

  if(mode_ == kDispDebug) { printf(" Length = %d", sndDataLen); }

  /* Copy header data */
  memcpy(sndBuf,sendHeader_, sizeof(struct RbcpHeader_t));

  if(sendHeader_->command == rbcp_cmd_wr_){
    memcpy(sndBuf+sizeof(struct RbcpHeader_t), wd_buffer_, sndDataLen);
    cmdPckLen=sndDataLen + sizeof(struct RbcpHeader_t);
  }else{
    cmdPckLen=sizeof(struct RbcpHeader_t);
  }

  if(mode_ == kDispDebug){
    for(i = 0; i< cmdPckLen;i++){
      if(j==0) {
        printf("\t[%.3x]:%.2x ",i,(unsigned char)sndBuf[i]);
        j++;
      }else if(j==3){
        printf("%.2x\n",(unsigned char)sndBuf[i]);
        j=0;
      }else{
        printf("%.2x ",(unsigned char)sndBuf[i]);
        j++;
      }
    }
    if(j!=3) printf("\n");
  }

  /* send a packet*/

  sendto(sock, sndBuf, cmdPckLen, 0, (struct sockaddr *)&sitcpAddr, sizeof(sitcpAddr));
  if(mode_ == kDispDebug) { printf("The packet have been sent!\n"); }

  /* Receive packets*/
  if(mode_ == kDispDebug) { printf("Wait to receive the ACK packet...\n"); }

  while(numReTrans<3){

    FD_ZERO(&setSelect);
    FD_SET(sock, &setSelect);

    timeout.tv_sec  = 1;
    timeout.tv_usec = 0;

    if(select(sock+1, &setSelect, NULL, NULL,&timeout)==0){
      /* time out */
      printf("***** Timeout ! *****\n");
      sendHeader_->id++;
      memcpy(sndBuf,sendHeader_, sizeof(struct RbcpHeader_t));
      sendto(sock, sndBuf, cmdPckLen, 0, (struct sockaddr *)&sitcpAddr, sizeof(sitcpAddr));
      numReTrans++;
      FD_ZERO(&setSelect);
      FD_SET(sock, &setSelect);
    } else {
      /* receive packet */
      if(FD_ISSET(sock,&setSelect)){
        rcvdBytes = recvfrom(sock, rcvdBuf, udp_buf_size_, 0, NULL, NULL);

        if((unsigned int)rcvdBytes<sizeof(struct RbcpHeader_t)){
	  fprintf(stderr, "#E UDPRBCP::DoRBCP ACK packet is too short\n");
          close(sock);
          return -1;
        }

        if((0x0f & rcvdBuf[1])!=0x8){
	  fprintf(stderr, "#E UDPRBCP::DoRBCP Detected bus error\n");
          close(sock);
          return -1;
        }

        rcvdBuf[rcvdBytes]=0;

        if(sendHeader_->command == rbcp_cmd_rd_){
          memcpy(rd_buffer_, rcvdBuf+sizeof(struct RbcpHeader_t),rcvdBytes-sizeof(struct RbcpHeader_t));
	  length_rd_ = rcvdBytes-sizeof(struct RbcpHeader_t);
        }

        if(mode_ == kDispDebug){
	  printf("***** A pacekt is received ! *****.\n");
	  printf("Received data:\n");

          j=0;

          for(i=0; i<rcvdBytes; i++){
            if(j==0) {
              printf("\t[%.3x]:%.2x ",i, (unsigned char)rcvdBuf[i]);
              j++;
            }else if(j==3){
              printf("%.2x\n",(unsigned char)rcvdBuf[i]);
             j=0;
            }else{
              printf("%.2x ",(unsigned char)rcvdBuf[i]);
              j++;
            }
            if(i==7) printf("\n Data:\n");
          }

          if(j!=3) puts(" ");
        }else if(mode_ == kDispInteractive){
          if(sendHeader_->command == rbcp_cmd_rd_){
            j=0;
            puts(" ");

            for(i=8; i<rcvdBytes; i++){
              if(j==0) {
                printf(" [0x%.8x] %.2x ",ntohl(sendHeader_->address)+i-8,(unsigned char)rcvdBuf[i]);
                j++;
              }else if(j==7){
                printf("%.2x\n",(unsigned char)rcvdBuf[i]);
                j=0;
              }else if(j==4){
                printf("- %.2x ",(unsigned char)rcvdBuf[i]);
                j++;
              }else{
                printf("%.2x ",(unsigned char)rcvdBuf[i]);
                j++;
              }

	      hddaq::BitDump dump;
	      dump((unsigned int)rcvdBuf[i]);
            }

            if(j!=15) puts(" ");
          }else{
            printf(" 0x%x: OK\n",ntohl(sendHeader_->address));
          }
        }
        numReTrans = 4;
        close(sock);
        return(rcvdBytes);
      }
    }
  }
  close(sock);

  return -3;
}
