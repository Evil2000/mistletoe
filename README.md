# mistletoe
A quick and dirty shell script to log the calls from Aastra/Mitel Office 400 (or any other Aastra/Mitel communication server which reports calls in OIP format) to MySQL.

## How it works.
The communication server (CS) has to be configured to send call information in OIP format to a this script which listens on TCP port 1080 (default) and inserts the information into a MySQL table.

## Setup
1. Create a MySQL table `callog` with the following rows:
	```sql
	CREATE TABLE callog (
	  pk bigint(20) UNSIGNED NOT NULL,
	  serialno bigint(20) UNSIGNED NOT NULL,
	  extension tinyint(3) UNSIGNED NOT NULL,
	  direction tinyint(3) UNSIGNED NOT NULL,
	  calltype tinyint(3) UNSIGNED NOT NULL,
	  callinfo tinyint(3) UNSIGNED NOT NULL,
	  datetime timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	  duration int(10) UNSIGNED NOT NULL,
	  from_orig varchar(64) NOT NULL,
	  from_shown varchar(64) NOT NULL,
	  to_orig varchar(64) NOT NULL,
	  to_shown varchar(64) NOT NULL,
	  time_to_answer int(10) UNSIGNED NOT NULL,
	  device int(10) UNSIGNED NOT NULL
	) ENGINE=InnoDB DEFAULT CHARSET=latin1;

	ALTER TABLE callog
	  ADD PRIMARY KEY (pk),
	  ADD UNIQUE KEY serialno (serialno),
	  ADD KEY extension (extension),
	  ADD KEY direction (direction),
	  ADD KEY datetime (datetime),
	  ADD KEY duration (duration),
	  ADD KEY from_orig (from_orig),
	  ADD KEY to_orig (to_orig),
	  ADD KEY from_shown (from_shown) USING BTREE,
	  ADD KEY to_shown (to_shown) USING BTREE;

	ALTER TABLE callog
	  MODIFY pk bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;
	```

2. Copy the callog.sh script to the machine which will receive the call infos from the CS.
3. Edit the callog.sh and change the variables at the top to fit your needs.
4. Run the script
	```
	user@host:~$ . ./callog.sh
	```
5. Configure the Aastra/Mitel CS:
	1. Login to the WebAdmin.
	2. Go to Charges -> General -> Call logging.
	3. Change the 'Service active' dropdown box to *Outgoing + incoming call logging (OCL + ICL)*.
	4. Enter the IP and Port which the callog.sh script is running on into the *IP address / host name* and *TCP port* fields.
	5. Select the value *OIP* in the *OCL format* and *ICL format* dropdown box.
	6. Hit the *Apply* button.
	7. Go to Routing -> List view -> Call distribution and select the entry on which you want to enable the call logging.
	8. Expand *Settings* and set the *Enter ICL data* checkbox and hit the *Apply* button.
6. Done.

From now on the CS connects to the listening calloh.sh script and sends the data. The script writes the data into the MySQL table and logs it to syslog also.