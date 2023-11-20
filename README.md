# Openapi

https://github.com/irceline/open_data/blob/master/readme.md

Rest API: https://geo.irceline.be/sos/api/v1/

## Station list
Raw stations:

curl -X GET https://geo.irceline.be/sos/api/v1/api/v1/stations

Stations near antwerp:

curl -X GET -G https://geo.irceline.be/sos/api/v1/stations/ --data-urlencode "expanded=true" --data-urlencode "near={\"center\":{\"type\":\"Point\",\"coordinates\": [res]},\"radius\":10}" > nearAntwerp.json

### expanded

expanded = true returns timeseries id and information about what it contains

## timeseries 

curl -X GET https://geo.irceline.be/sos/api/v1/timeseries/6152/getData?PT24H/2023-11-07

Timespan: period/end-date allows to get hourly values for a given day