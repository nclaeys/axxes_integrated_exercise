import argparse
import json
import logging
import boto3
import urllib
import sys

import requests
from typing import Optional


class Measurement:
    def __init__(self, longitude: float, latitude: float, station_id: str, station_name: str,
                 series_id: str, parameter_id: str, parameter_name: str, city_name: str):
        self.longitude = longitude
        self.latitude = latitude
        self.timeseries_id = series_id
        self.station_id = station_id
        self.station_name = station_name
        self.parameter_id = parameter_id
        self.parameter_name = parameter_name
        self.city_name = city_name

    def set_measurements(self, measurements: list[any]):
        self.measurements = measurements

    def to_json(self):
        result = []
        for measurement in self.measurements:
            result.append({'longitude': self.longitude, 'latitude': self.latitude, 'timeseries_id': self.timeseries_id,
                           'station_id': self.station_id, 'station_name': self.station_name,
                           'city_name': self.city_name,
                           'parameter_id': self.parameter_id, 'parameter_name': self.parameter_name,
                           'timestamp': measurement['timestamp'], 'value': measurement['value']})
        return result


def main():
    logging.basicConfig(stream=sys.stdout, level=logging.INFO)
    parser = argparse.ArgumentParser(description="integrated_exercise")
    parser.add_argument(
        "-d", "--date", dest="date", help="date in format YYYY-mm-dd", required=True
    )
    parser.add_argument(
        "-e", "--env", dest="env", help="environment we are executing in", required=True
    )
    parser.add_argument(
        "-p", "--path", dest="path", help="Bucket path to read or write data from", required=True
    )
    args = parser.parse_args()
    logging.info(f"Using args: {args}")
    process_raw_data(args.path, args.date)


def write_timeseries_for(date: str, series_id: str, station_id: str, s3_bucket: str, measurement: Measurement):
    request_timeseries = f"https://geo.irceline.be/sos/api/v1/timeseries/{series_id}/getData?timespan=PT24H/{date}T00:00:00Z"

    response = requests.get(request_timeseries)
    if response.status_code == 200:
        values_json = response.json()['values']
        measurement.set_measurements(values_json)
        s3 = boto3.resource('s3')
        s3.Object(f"{s3_bucket}", f'niels-data/raw/{date}/{str(station_id)}-{series_id}.json').put(
            Body=json.dumps(measurement.to_json()).encode('utf-8'))
    else:
        raise response.raise_for_status()


def process_raw_data(s3_bucket: str, date: str) -> Optional[str]:
    """
    Gets the data from the open weather map api and returns the result.
    :return: The weather data
    """
    interested_parameter_ids = [5, 6001, 8, 71, 1]
    interested_parameter = {5: 'ppm10', 6001: 'ppm25', 8: 'N02', 71: 'CO2', 1: 'S02'}
    # Stations around antwerp: coordinates: 4.40346, 51.21989
    antwerp_stations = '{"center":{"type":"Point","coordinates":[4.40346, 51.21989]},"radius":10}'

    url_encoded_stations = urllib.parse.quote_plus(antwerp_stations)
    request_url = "https://geo.irceline.be/sos/api/v1/stations/?expanded=true&near={}".format(url_encoded_stations)
    result = requests.get(request_url)
    content = result.json()
    for entry in content:
        station_id = entry['properties']['id']
        station_name = entry['properties']['label']
        long_coord = entry['geometry']['coordinates'][0]
        lat_coord = entry['geometry']['coordinates'][1]
        timeseries = entry['properties']['timeseries']
        for tKey in timeseries:
            tVal = timeseries[tKey]
            parameter_id = int(tVal['phenomenon']['id'])
            if parameter_id in interested_parameter_ids:
                measurement = Measurement(longitude=long_coord, latitude=lat_coord, station_id=station_id,
                                          station_name=station_name, series_id=tKey, parameter_id=tKey,
                                          parameter_name=interested_parameter[parameter_id], city_name='Antwerp')
                write_timeseries_for(date, tKey, station_id, s3_bucket, measurement)


if __name__ == "__main__":
    main()
