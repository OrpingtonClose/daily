import ntplib
from time import ctime

#http://www.pool.ntp.org/en/
#https://tf.nist.gov/tf-cgi/servers.cgi

servers_to_try = ["time-a-g.nist.gov",
                  "time.nist.gov",
                  "ut1-time.colorado.edu",
                  "3.europe.pool.ntp.org",
                  "3.de.pool.ntp.org",
                  "3.hu.pool.ntp.org",
                  "3.uk.pool.ntp.org",
                  "3.africa.pool.ntp.org"]

ntp_client = ntplib.NTPClient()
for server in servers_to_try:
  try:
    response = ntp_client.request(server)
    print("{} --> {}".format(server, ctime(response.tx_time)))
  except:
    print("{} --> could not sync with time server.".format(server))
