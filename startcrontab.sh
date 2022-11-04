#!/bin/bash
C_DIR=echo "$PWD"
cd working
docker-compose up -d
cd $C_DIR
