set -v 
set -x

JAVA_HOME=/usr/java6
export JAVA_HOME
PATH=.:$JAVA_HOME/bin:$PATH
export PATH

#java -jar /home/csalas/VaxFileParser_v0.6/VAXFilesParser_v0.6.jar

#java -jar /insight/local/scripts/VaxParser/VAXFilesParser_v0.7.jar

#java -jar /insight/local/scripts/VaxParser/VAXFilesParser_v0.8.jar

#java -Xms512m -Xmx2048m -jar /insight/local/scripts/VaxParser/VAXFilesParser_v0.8.jar

java -Xms512m -Xmx2048m -jar /insight/local/scripts/VaxParser/VAXFilesParser_v1.0.jar

