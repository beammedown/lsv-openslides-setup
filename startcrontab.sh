#!/bin/bash
C_DIR=echo "$PWD"
cd os4
docker-compose up -d
cd $C_DIR
