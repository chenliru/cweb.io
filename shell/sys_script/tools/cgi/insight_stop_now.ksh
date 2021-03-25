echo "Stop locus services..."
su - ipgown -c "/cgi/bin/cgi.stoplocus" >> /cgi/log/stop_insight.log
echo "Stop informix service..."
su - informix -c "/cgi/bin/cgi.stopids" >> /cgi/log/stop_insight.log
