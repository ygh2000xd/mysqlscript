#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Usage: client_start.sh <ip_address> <username> <userpassword>"
    echo "As a default, it will connect 3306 port"
    exit 0
fi

######################################################################################
# Notes:
#  To start client tests
#  Usage: client_start.sh <mysql_server_ip> <username> <passwd> {inital}
#####################################################################################

if [ $4 ] ; then
    #Step 1: Prepare data
    sysbench --test=~/apptests/sysbench/sysbench/tests/db/parallel_prepare.lua \
        --oltp-test-mode=complex  \
        --mysql-host=$1 --mysql-db=sysbench \
        --mysql-password=$3 \
        --max-time=7200 --max-requests=0 --mysql-user=$2 \
        --mysql-table-engine=innodb --oltp-table-size=1000000 \
        --oltp-tables-count=100 --rand-type=special --rand-spec-pct=100 \
        --num-threads=10 prepare
        
    #Step 2: Initialize tables
    sysbench --test=~/apptests/sysbench/sysbench/tests/db/parallel_prepare.lua \
        --oltp-test-mode=complex  \
        --mysql-host=$1 --mysql-db=sysbench \
        --mysql-password=$3 \
        --max-time=7200 --max-requests=0 --mysql-user=$2 \
        --mysql-table-engine=innodb --oltp-table-size=1000000 \
        --oltp-tables-count=100 --rand-type=special --rand-spec-pct=100 \
        --num-threads=10 run
fi

#Step 3: Run test case
${APP_ROOT}/applications/mysql/cases/percona_ali_test/scripts/readall.sh $1 $2 $3 100 3306
${APP_ROOT}/applications/mysql/cases/percona_ali_test/scripts/sysbench.sh $1 $2 $3 on 50 450 $1 sysbench 100 1000000 select6 20000

echo "**********************************************************************************"
echo "start tcprstat completed"

