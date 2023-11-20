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
