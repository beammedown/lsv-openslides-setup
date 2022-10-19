#!/bin/bash
C_DIR=echo "$PWD"
cd $C_DIR/working
docker-compose up -d
cd $C_DIR