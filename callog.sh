#!/bin/bash
#
# mistletoe
# A quick and dirty shell script to log the calls from Aastra/Mitel
# communication server to MySQL.
#
# Copyright (C) 2018  Evil.2000
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

#####
# MySQL settings
#
# Username
MYSQLUSER="calllogger"

# Password
MYSQLPASS="mysupersecretpassword"

# Database name
MYSQLDB="telephone"

# Table name
MYSQLTABLE="callog"

#####
# Network settings
#
# IP to listen on
LISTENIP="127.0.0.1"

# Port to listen on
LISTENPORT=1080

# settings end
#####

logger -t "Callog" "Logger starting up"

nc -l -k ${LISTENIP} ${LISTENPORT} | while read line; do
	IFS=';' read -r -a CSV <<< "$(echo "$line" | tr '\t' ';')"
	echo "=== New Call: ===================="
	echo "Type     : ${CSV[0]}"
	echo "Serial#  : ${CSV[1]}"
	echo "Extension: ${CSV[2]}"
	echo "Unknown  : ${CSV[3]}"
	echo -n "Direction: "
	case ${CSV[4]} in
		0)
		echo "Outgoing to the public network"
		CALL_DIR=out
		;;
		1)
		echo "Outgoing to the PISN"
		CALL_DIR=out
		;;
		3)
		echo "Incoming from the public network"
		CALL_DIR=in
		;;
		4)
		echo "Incoming from the PISN"
		CALL_DIR=in
		;;
	esac
	echo -n "Call Type: "
	case ${CSV[5]} in
		0)
		echo "Business network access, transferred"
		;;
		1)
		echo "Business network access, self dialing"
		;;
		2)
		echo "Incoming (appears only at the destination PINX)"
		;;
		3)
		echo "Incoming to ACD destination (placed in ACD queue)"
		;;
		4)
		echo "PISN trans"
		;;
		6)
		echo "Network access with cost center selection, transferred"
		;;
		7)
		echo "Network access with cost center selection, self dialing"
		;;
		8)
		echo "Private network access, transferred"
		;;
		9)
		echo "Private network access, self dialing"
		;;
	esac
	echo -n "Call Info: "
	case ${CSV[6]} in
		0)
		if [ $CALL_DIR == "in" ]; then
			echo "Incoming call, transferred";
		else
			echo "Normal call";
		fi
		;;
		1)
		if [ $CALL_DIR == "in" ]; then
			echo "Incoming call, answered directly";
		else
			echo "-";
		fi
		;;
		2)
		if [ $CALL_DIR == "in" ]; then
			echo "Unanswered call";
		else
			echo "-";
		fi
		;;
		3)
		if [ $CALL_DIR == "in" ]; then
			echo "Answered call.";
		else
			echo "-";
		fi
		;;
		4)
		if [ $CALL_DIR == "in" ]; then
			echo "Incoming call connection, transferred to the network";
		else
			echo "Transfer call, set up through CFU / CFNR / CD into the network";
		fi
		;;
		5)
		if [ $CALL_DIR == "in" ]; then
			echo "-";
		else
			echo "Transfer call, transferred by internal user";
		fi
		;;
		6)
		if [ $CALL_DIR == "in" ]; then
			echo "Incoming data service connection";
		else
			echo "Outgoing data service connections";
		fi
		;;
		7)
		if [ $CALL_DIR == "in" ]; then
			echo "-";
		else
			echo "Outgoing connections on phone booth extensions";
		fi
		;;
		8)
		if [ $CALL_DIR == "in" ]; then
			echo "-";
		else
			echo "Outgoing connections on room extensions";
		fi
		;;
		9)
		if [ $CALL_DIR == "in" ]; then
			echo "Rejected connection with ACD destination (ACD queue)";
		else
			echo "-";
		fi
		;;
	esac
	CSV[7]=$(echo "${CSV[7]}" | tr '.' '-')
	echo "Date     : ${CSV[7]}"
	echo "Time     : ${CSV[8]}"
	echo "Duration : ${CSV[9]}"
	echo "Charge   : ${CSV[10]}"
	echo "#Impulses: ${CSV[11]}"
	echo "ChanGroup: ${CSV[12]}"
	echo "Unknown  : ${CSV[13]}"
	echo "TrunkCard: ${CSV[14]}"
	echo "Interface: ${CSV[15]}"
	echo "Orig From: ${CSV[16]}"
	echo "From     : ${CSV[17]}"
	echo "Orig To  : ${CSV[18]}"
	echo "To       : ${CSV[19]}"
	echo "Time2Answ: ${CSV[20]:=0}"
	echo "Sequence#: ${CSV[21]}"
	echo "Device-ID: ${CSV[22]}"
	
	MYSQL_PWD="${MYSQLPASS}" mysql --user="${MYSQLUSER}"  --database="${MYSQLDB}" --execute "\
	INSERT INTO ${MYSQLTABLE} \
	(\
	serialno,\
	extension,\
	direction,\
	calltype,\
	callinfo,\
	datetime,\
	duration,\
	from_orig,\
	from_shown,\
	to_orig,\
	to_shown,\
	time_to_answer,\
	device\
	) VALUES (\
	'${CSV[1]}',\
	'${CSV[2]}',\
	'${CSV[4]}',\
	'${CSV[5]}',\
	'${CSV[6]}',\
	'${CSV[7]} ${CSV[8]}',\
	'${CSV[9]}',\
	'${CSV[16]}',\
	'${CSV[17]}',\
	'${CSV[18]}',\
	'${CSV[19]}',\
	'${CSV[20]}',\
	'${CSV[22]}'\
	);"
done | logger -t "Callog"

