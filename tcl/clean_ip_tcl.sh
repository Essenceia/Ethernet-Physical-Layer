#!/bin/bash

# relax qsys requirement
sed -i 's/package require -exact qsys.*/package require qsys/' $1

# remove `set_project_property: BOARD`
sed -i 's/set_project_property BOARD .*//' $1

