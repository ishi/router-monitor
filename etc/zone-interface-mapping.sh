#!/usr/bin/env bash

read zone
if [ "$zone" ]; then echo $zone; exit 0; fi
exit 1
