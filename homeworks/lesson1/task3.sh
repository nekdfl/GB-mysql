#!/bin/bash

mysqldump example >exampledump.sql
mysql -e "CREATE DATABASE sample" ;
mysql -Dsample < exampledump.sql;


