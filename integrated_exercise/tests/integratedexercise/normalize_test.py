import datetime

from integratedexercise.normalize import aggregate_station_by_day, aggregate_city_by_hour


def to_measurement(parameter_name, station_id, timestamp, value=1, city='antwerp'):
    return [
        station_id,
        51.236,
        4.385,
        'parameter_id',
        parameter_name,
        'station_name',
        timestamp,
        value,
        city,
    ]


def createDf(spark, data):
    columns = [
        'station_id',
        'latitude',
        'longitude',
        'parameter_id',
        'parameter_name',
        'station_name',
        'timestamp',
        'value',
        'city'
    ]
    return spark.createDataFrame(data, columns)


def test_aggregate_station_by_day_one_value(spark):
    parameter_name = 'pm10'
    station_id = '10000'
    # epoch millis
    timestamp = datetime.datetime(2023, 11, 1, 10, 0, 0,0).timestamp() * 1000

    df = createDf(spark, [to_measurement(parameter_name, station_id, timestamp, 1)])
    df.show()
    aggregate = aggregate_station_by_day(df)

    assert aggregate.count() == 1
    collected_df = aggregate.collect()
    assert collected_df[0]["day"] == '2023-11-01'
    assert collected_df[0]["daily_average"] == 1
    assert collected_df[0]["station_id"] == station_id
    assert collected_df[0]["parameter_name"] == parameter_name

def test_aggregate_station_by_day_two_values_same_day(spark):
    parameter_name = 'pm10'
    station_id = '10000'
    # epoch millis
    timestamp = datetime.datetime(2023, 11, 1, 10, 0, 0,0).timestamp() * 1000
    timestamp2 = datetime.datetime(2023, 11, 1, 11, 0, 0,0).timestamp() * 1000

    df = createDf(spark, [to_measurement(parameter_name, station_id, timestamp, 1),
                          to_measurement(parameter_name, station_id, timestamp2, 3)])
    aggregate = aggregate_station_by_day(df)

    assert aggregate.count() == 1
    collected_df = aggregate.collect()
    assert collected_df[0]["day"] == '2023-11-01'
    assert collected_df[0]["daily_average"] == 2
    assert collected_df[0]["station_id"] == station_id
    assert collected_df[0]["parameter_name"] == parameter_name

def test_aggregate_station_by_day_two_values_different_day(spark):
    parameter_name = 'pm10'
    station_id = '10000'
    # epoch millis
    timestamp = datetime.datetime(2023, 11, 1, 10, 0, 0,0).timestamp() * 1000
    timestamp2 = datetime.datetime(2023, 11, 2, 10, 0, 0,0).timestamp() * 1000

    df = createDf(spark, [to_measurement(parameter_name, station_id, timestamp, 1),
                          to_measurement(parameter_name, station_id, timestamp2, 1)])
    aggregate = aggregate_station_by_day(df)

    assert aggregate.count() == 2
    collected_df = aggregate.collect()
    assert collected_df[0]["day"] == '2023-11-01'
    assert collected_df[0]["daily_average"] == 1
    assert collected_df[1]["day"] == '2023-11-02'
    assert collected_df[1]["daily_average"] == 1

def test_aggregate_station_by_day_two_values_different_params(spark):
    parameter_name = 'pm10'
    parameter_name2 = 'pm25'
    station_id = '10000'
    # epoch millis
    timestamp = datetime.datetime(2023, 11, 1, 10, 0, 0,0).timestamp() * 1000
    timestamp2 = datetime.datetime(2023, 11, 1, 11, 0, 0,0).timestamp() * 1000

    df = createDf(spark, [to_measurement(parameter_name, station_id, timestamp, 1),
                          to_measurement(parameter_name2, station_id, timestamp2, 3)])
    aggregate = aggregate_station_by_day(df)

    assert aggregate.count() == 2
    collected_df = aggregate.collect()
    assert collected_df[0]["day"] == '2023-11-01'
    assert collected_df[0]["daily_average"] == 1
    assert collected_df[0]["parameter_name"] == parameter_name
    assert collected_df[1]["day"] == '2023-11-01'
    assert collected_df[1]["daily_average"] == 3
    assert collected_df[1]["parameter_name"] == parameter_name2

def test_aggregate_city_by_hour_one_value(spark):
    parameter_name = 'pm10'
    station_id = '10000'
    antwerp = 'antwerp'
    # epoch millis
    timestamp = datetime.datetime(2023, 11, 1, 10, 0, 0,0).timestamp() * 1000

    df = createDf(spark, [to_measurement(parameter_name, station_id, timestamp, 1, city=antwerp)])
    df.show()
    aggregate = aggregate_city_by_hour(df)

    assert aggregate.count() == 1
    collected_df = aggregate.collect()
    assert collected_df[0]["day"] == '2023-11-01'
    assert collected_df[0]["average"] == 1
    assert collected_df[0]["city"] == antwerp

def test_aggregate_city_by_hour_two_values_different_stations(spark):
    parameter_name = 'pm10'
    station_id = '10000'
    antwerp = 'antwerp'
    # epoch millis
    timestamp = datetime.datetime(2023, 11, 1, 10, 0, 0,0).timestamp() * 1000

    df = createDf(spark, [to_measurement(parameter_name, station_id, timestamp, 1, city=antwerp),
                          to_measurement(parameter_name, '2000', timestamp, 3, city=antwerp)])
    df.show()
    aggregate = aggregate_city_by_hour(df)

    assert aggregate.count() == 1
    collected_df = aggregate.collect()
    assert collected_df[0]["day"] == '2023-11-01'
    assert collected_df[0]["average"] == 2
    assert collected_df[0]["city"] == antwerp

def test_aggregate_city_by_hour_two_values_different_hours(spark):
    parameter_name = 'pm10'
    station_id = '10000'
    antwerp = 'antwerp'
    # epoch millis
    timestamp = datetime.datetime(2023, 11, 1, 10, 0, 0,0).timestamp() * 1000
    timestamp2 = datetime.datetime(2023, 11, 1, 11, 0, 0,0).timestamp() * 1000

    df = createDf(spark, [to_measurement(parameter_name, station_id, timestamp, 1, city=antwerp),
                          to_measurement(parameter_name, '2000', timestamp2, 3, city=antwerp)])
    df.show()
    aggregate = aggregate_city_by_hour(df)

    assert aggregate.count() == 2
    collected_df = aggregate.collect()
    assert collected_df[0]["day"] == '2023-11-01'
    assert collected_df[0]["average"] == 1
    assert collected_df[0]["city"] == antwerp
    assert collected_df[1]["day"] == '2023-11-01'
    assert collected_df[1]["average"] == 3
    assert collected_df[1]["city"] == antwerp