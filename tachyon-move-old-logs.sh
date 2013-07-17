#!/bin/bash

mkdir -p ~/work/tachyon/logs/old
find ~/work/tachyon/logs -maxdepth 1 -type f -mmin +720 -exec mv {} ~/work/tachyon/logs/old \;
