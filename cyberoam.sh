# Copyright (C) 2013 Darshit Shah

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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# A small utility to login to Cyberoam Client.
# Author: Darshit Shah <darnir@gmail.com>

#TODO: Modularize, create functions and implement parameterized input.

#User Variables to be passed to the Cyberoam Server. These variables should be defined in ${HOME}/${FILE}
#USER=Username
#PASS=Password

#Variables defining Server Location. These variables should be defined in ${HOME}/${FILE}
#SERVER="172.16.0.30"
#PORT="8090"
#PAGE="httpclient.html"

LOGFILE=$(echo ${HOME})/.crlog
OUTPUT=/tmp/.crout
FILE=client.conf
#TODO: Use --post-file option to send data

#Assumes syntax of file is PERFECT. Does not accept comments either.
#TODO: Convert sed statements to awk and read $3 

if [ ! -f ${HOME}/${FILE} ]
then
    echo "USERNAME=Username" > ${HOME}/${FILE}
    echo "PASS=Password" >> ${HOME}/${FILE}
    echo "SERVER=Server" >> ${HOME}/${FILE}
    echo "PORT=Port" >> ${HOME}/${FILE}
    echo "PAGE=Page" >> ${HOME}/${FILE}
    echo "${HOME}/${FILE} Created with defaults. Please edit values and re-run script."
    exit 2
else
    USERNAME=`cat ${HOME}/${FILE} | sed 's/USERNAME=/&\n/;s/.*\n//;s/PASS\*/\n&/;s/\n.*//' | head -1`
    PASS=`cat ${HOME}/${FILE} | sed 's/PASS=/&\n/;s/.*\n//;s/SERVER\*/\n&/;s/\n.*//' | head -2 | tail -1`
    SERVER=`cat ${HOME}/${FILE} | sed 's/SERVER=/&\n/;s/.*\n//;s/PORT\*/\n&/;s/\n.*//' | head -3 | tail -1`
    PORT=`cat ${HOME}/${FILE} | sed 's/PORT=/&\n/;s/.*\n//;s/PAGE\*/\n&/;s/\n.*//' | tail -2 | head -1`
    PAGE=`cat ${HOME}/${FILE} | sed 's/PAGE=/&\n/;s/.*\n//;s/\*/\n&/;s/\n.*//' | tail -1`
fi

e=0

MESSAGE_LOGIN="You have successfully logged in"

if [ "$USERNAME" == "Username" -o "$PASS" == "Password" ]
then
    echo "Please enter your username and password in ${HOME}/${FILE} and restart"
    exit 2
elif [ "$SERVER" == "Server" -o "$PORT" == "Port" -o "$PAGE" == "Page" ]
then 
    #TODO: Add test to check $PORT is Numeric ONLY
    echo "Please add your server configuration in ${HOME}/${FILE} and restart"
    exit 2
fi

if [ ! -f $OUTPUT ]
then 
    ACTION=Login
    MODE=191
#TODO: Make PORT and PAGE variables optional
    wget -d --post-data="username=${USERNAME}&password=${PASS}&mode=${MODE}&btnSubmit=${ACTION}" ${SERVER}:${PORT}/${PAGE} -O ${OUTPUT} -o ${LOGFILE} 2> /dev/null
    RESPONSE=`cat ${OUTPUT} | sed 's/<message>/&\n/;s/.*\n//;s/<\/message>/\n&/;s/\n.*//'`
    if [ "$RESPONSE" == "${MESSAGE_LOGIN}" ]
    then
        echo "Logged In"
    else
	echo "Error in Logging In:"
	echo $RESPONSE
	rm ${OUTPUT}
	e=1
    fi
else
    ACTION=Logout
    MODE=193
    wget -d --post-data="username=${USERNAME}&password=${PASS}&mode=${MODE}&btnSubmit=${ACTION}" ${SERVER}:${PORT}/${PAGE} -O ${OUTPUT} -o ${LOGFILE} 2> /dev/null
    echo "Logged Out"
    rm ${OUTPUT}
fi

exit $e
