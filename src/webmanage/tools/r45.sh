#!/bin/bash

sed -i 's/<Url>2\./<Url>5./g' $1
sed -i 's/9\.134\.144\.153/9.134.144.100/g' $1
