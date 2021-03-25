#!/usr/bin/ksh93
###########################################################################
#
#Indexes and referential constraints are not allowed on 
#tables of type raw, have to drop them before you set table
# type raw, and rebuild them after large data loaded
#
#  Author : Liru Chen
#  Date: 2015-05-13
############################################################################
set -v
set -x

delete_foreignkey () {

referencedTable=$1		# Base Table, Owner of reference
foreignKeyTable=$2		# Child Table, Owner of Foreign Key
foreignKey=$3			# Foreign Key

DATABASE $DBNAME;

BEGIN WORK;

LOCK TABLE $foreignKeyTable IN EXCLUSIVE MODE;
LOCK TABLE $referencedTable IN EXCLUSIVE MODE;
DELETE FROM  $DBNAME@$DBSERVER:$USER.$foreignKeyTable 
	WHERE $foreignKey NOT IN
	(SELECT $foreignKey from $referencedTable);

UNLOCK TABLE $foreignKeyTable;
UNLOCK TABLE $referencedTable;

COMMIT WORK;

CLOSE DATABASE;

}



