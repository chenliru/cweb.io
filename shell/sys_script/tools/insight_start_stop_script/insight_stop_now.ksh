echo "Stop locus services..."
su - ipgown -c "/insight/ifx01/bin/stoplocus.ksh" >> /insight/ifx01/log/stop_insight.log
echo "Stop informix service..."
su - informix -c "/insight/ifx01/bin/stopids.ksh" >> /insight/ifx01/log/stop_insight.log
