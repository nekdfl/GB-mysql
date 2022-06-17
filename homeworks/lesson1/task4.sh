#!/bin/bash

mysqldump --opt --where=1 limit 100 mysql help_keyword > task4.sql
