echo "Start informix service..."
su - informix -c "/insight/ifx01/bin/startids.ksh" >> /insight/ifx01/log/start_insight.log
echo "Start locus services..."
su - ipgown -c "/insight/ifx01/bin/startlocus.ksh" >> /insight/ifx01/log/start_insight.log

