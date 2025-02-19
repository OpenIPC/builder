#!/bin/sh

### sd card power en ###
devmem 0x100c0058 32 0
gpio set 38
