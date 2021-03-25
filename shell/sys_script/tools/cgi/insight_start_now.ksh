echo "Start informix service..."
su - informix -c "/cgi/bin/cgi.startids" >> /cgi/log/start_insight.log
echo "Start locus services..."
su - ipgown -c "/cgi/bin/cgi.startlocus" >> /cgi/log/start_insight.log

