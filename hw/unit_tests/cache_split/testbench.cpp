#include "cachesim.h"
#include <iostream>
#include <fstream>
#include <iomanip>

#define VCD_OUTPUT 1


int REQ_RSP(CacheSim *sim){ //verified
  unsigned int addr[4] = {0x12222222, 0xabbbbbbb, 0xcddddddd, 0xe4444444};
  unsigned int data[4] = {0xffffffff, 0x11111111, 0x22222222, 0x33333333};
  unsigned int rsp[4] = {0,0,0,0};
  char responded = 0;
  //write req
  core_req_t* write = new core_req_t;
  write->valid = 0xf;
  write->rw = 0xf;
  write->byteen = 0xffff;
  write->addr = addr;
  write->data = data;
  write->tag = 0xff;

  //read req
  core_req_t* read = new core_req_t;
  read->valid = 0xf;
  read->rw = 0;
  read->byteen = 0xffff;
  read->addr = addr;
  read->data = addr;
  read->tag = 0xff;

  // reset the device
  sim->reset();

  //queue reqs
  sim->send_req(write);
  sim->send_req(read);

  sim->run();

  bool check = sim->assert_equal(data, write->tag);

  return check;
}

int HIT_1(CacheSim *sim){
  unsigned int addr[4] = {0x12222222, 0xabbbbbbb, 0xcddddddd, 0xe4444444};
  unsigned int data[4] = {0xffffffff, 0x11111111, 0x22222222, 0x33333333};
  unsigned int rsp[4] = {0,0,0,0};
  char responded = 0;
  //write req
  core_req_t* write = new core_req_t;
  write->valid = 0xf;
  write->rw = 0xf;
  write->byteen = 0xffff;
  write->addr = addr;
  write->data = data;
  write->tag = 0x11;

  //read req
  core_req_t* read = new core_req_t;
  read->valid = 0xf;
  read->rw = 0;
  read->byteen = 0xffff;
  read->addr = addr;
  read->data = addr;
  read->tag = 0x22;

  // reset the device
  sim->reset();

  //queue reqs
  sim->send_req(write);
  sim->send_req(read);

  sim->run();

  bool check = sim->assert_equal(data, write->tag);

  return check;
}

int MISS_1(CacheSim *sim){
  unsigned int addr1[4] = {0x12222222, 0xabbbbbbb, 0xcddddddd, 0xe4444444};
  unsigned int addr2[4] = {0x12244444, 0xabb0bbbb, 0xcddd0ddd, 0xe0444444};
  unsigned int addr3[4] = {0x12888888, 0xa0bbbbbb, 0xcddddd0d, 0xe4444440};
  unsigned int data[4] = {0xffffffff, 0x11111111, 0x22222222, 0x33333333};
  unsigned int rsp[4] = {0,0,0,0};
  char responded = 0;
  //write req
  core_req_t* write = new core_req_t;
  write->valid = 0xf;
  write->rw = 0xf;
  write->byteen = 0xffff;
  write->addr = addr1;
  write->data = data;
  write->tag = 0xff;

  //read req
  core_req_t* read1 = new core_req_t;
  read1->valid = 0xf;
  read1->rw = 0;
  read1->byteen = 0xffff;
  read1->addr = addr1;
  read1->data = data;
  read1->tag = 0xff;

  //read req
  core_req_t* read2 = new core_req_t;
  read2->valid = 0xf;
  read2->rw = 0;
  read2->byteen = 0xffff;
  read2->addr = addr2;
  read2->data = data;
  read2->tag = 0xff;

  //read req
  core_req_t* read3 = new core_req_t;
  read3->valid = 0xf;
  read3->rw = 0;
  read3->byteen = 0xffff;
  read3->addr = addr3;
  read3->data = data;
  read3->tag = 0xff;

  // reset the device
  sim->reset();

  //queue reqs
  //sim->send_req(write);
  sim->send_req(read1);
  sim->send_req(read2);
  sim->send_req(read3);


  sim->run();

  bool check = sim->assert_equal(data, write->tag);

  return check;
}

int FLUSH(CacheSim *sim){
  unsigned int addr[4] = {0x12222222, 0xabbbbbbb, 0xcddddddd, 0xe4444444};
  unsigned int data[4] = {0xffffffff, 0x11111111, 0x22222222, 0x33333333};
  unsigned int rsp[4] = {0,0,0,0};
  char responded = 0;
  //write req
  core_req_t* write = new core_req_t;
  write->valid = 0xf;
  write->rw = 0xf;
  write->byteen = 0xffff;
  write->addr = addr;
  write->data = data;
  write->tag = 0xff;

  //read req
  core_req_t* read = new core_req_t;
  read->valid = 0xf;
  read->rw = 0;
  read->byteen = 0xffff;
  read->addr = addr;
  read->data = addr;
  read->tag = 0xff;

  // reset the device
  sim->reset();

  //queue reqs
  sim->send_req(write);
  sim->send_req(read);

  sim->run();

  bool check = sim->assert_equal(data, write->tag);

  return check;
}

int BACK_PRESSURE(CacheSim *sim){
  unsigned int addr[4] = {0x12222222, 0xabbbbbbb, 0xcddddddd, 0xe4444444};
  unsigned int data[4] = {0xffffffff, 0x11111111, 0x22222222, 0x33333333};
  unsigned int rsp[4] = {0,0,0,0};
  char responded = 0;

  //write req
  core_req_t* write = new core_req_t;
  write->valid = 0xf;
  write->rw = 0xf;
  write->byteen = 0xffff;
  write->addr = addr;
  write->data = data;
  write->tag = 0xff;

  //read req
  core_req_t* read = new core_req_t;
  read->valid = 0xf;
  read->rw = 0;
  read->byteen = 0xffff;
  read->addr = addr;
  read->data = addr;
  read->tag = 0xff;

  // reset the device
  sim->reset();

  //queue reqs
  for (int i = 0; i < 10; i++){
    sim->send_req(write);
  }
  sim->send_req(read);

  sim->run();

  bool check = sim->assert_equal(data, write->tag);

  return check;
}


int main(int argc, char **argv)
{
  //init
  RAM ram;
	CacheSim cachesim;
  cachesim.attach_ram(&ram);

  // enable cache-split
  cachesim.set_split(true);
  std::cout << "split_en:" << cachesim.get_split() << std::endl;

  int check = REQ_RSP(&cachesim);
  if(check){
    std::cout << "PASSED" << std::endl;
  } else {
    std::cout << "FAILED" << std::endl;
  }

	return 0;
}
