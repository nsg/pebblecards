from flask import Flask, jsonify, request
from datetime import datetime
import urllib2
import json
import re

app = Flask(__name__)

@app.route('/')
def index():
    return 'Index'

@app.route('/data', methods=['POST'])
def names():

    lat = float(request.form['latitude']);
    lon = float(request.form['longitude']);
    msg = ""
    vibr = 0

    if datetime.utcnow().hour in [6]:
        upd = 20
    else:
        upd = 60

    # It's morning and we are home
    if datetime.utcnow().hour in [7,8]:
        upd = 10
        if 59.34 <= lat <= 59.36:
            if 17.96 <= lon <= 17.98:
                upd = 1
                station_url = "http://sl.se/api/sv/RealTime/GetDepartures/9326"
                jd = urllib2.urlopen(station_url).read()
                j = json.loads(jd)
                for dest in j['data']['MetroBlueGroups']:
                    for dep in dest['Departures']:
                        if re.match("Kungstr.*", dep['Destination']) is not None:
                            if dep['DisplayTime'] == "Nu":
                                vibr = 1
                            msg = "Next: %s " % dep['DisplayTime']
                            break

    data = {
        "content" : "%s\n%s\n%s" % (lat, lon, msg),
        "refresh_frequency" : upd,
        "vibrate": vibr
        }

    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0',debug=True)
