import argparse
import logging
import sys

from pyspark.sql.functions import date_format, col, avg, to_utc_timestamp, lit
from pyspark.sql import SparkSession, DataFrame

logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.WARN)


def main():
    logging.basicConfig(stream=sys.stdout, level=logging.WARN)
    parser = argparse.ArgumentParser(description="integrated_exercise")
    parser.add_argument(
        "-d", "--date", dest="date", help="date in format YYYY-mm-dd", required=True
    )
    parser.add_argument(
        "-e", "--env", dest="env", help="environment we are executing in", required=True
    )
    parser.add_argument(
        "-p", "--path", dest="path", help="Root path to read or write data from", required=True
    )
    args = parser.parse_args()
    logging.info(f"Using args: {args}")

    run(args.env, args.date, args.path)


def read_raw_data(date: str, root_path: str) -> DataFrame:
    spark = get_spark_session('normalize')
    json_files = f"s3a://{root_path}/niels-data/raw/{date}/*.json"
    spark.sparkContext.setLogLevel("DEBUG")

    df = spark.read.option('multiline', 'true').json(json_files)
    return df


def get_spark_session(name: str = None) -> SparkSession:
    return (
        SparkSession.builder.config(
            "spark.jars.packages",
            ",".join(
                [
                    "org.apache.hadoop:hadoop-aws:3.3.1",
                ]
            ),
        )
        .config(
            "fs.s3a.aws.credentials.provider",
            "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        ).config(
            "fs.s3.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem"
        ).config(
            "spark.sql.session.timeZone", "UTC"
        )
        .appName(name)
        .getOrCreate()
    )


def aggregate_station_by_day(df) -> DataFrame:
    df_with_datetime = df.withColumn(f'datetime', to_utc_timestamp((col('timestamp') / 1000).cast("timestamp"), 'Z'))
    df_with_day = df_with_datetime.withColumn(f'day', date_format('datetime', 'yyyy-MM-dd'))

    grouping_keys = ('station_id', 'latitude', 'longitude', 'parameter_name', 'day')
    aggregated_df = df_with_day.groupby(*grouping_keys).agg(avg(col('value')).alias('daily_average'))
    return aggregated_df


def aggregate_city_by_hour(df) -> DataFrame:
    df_with_datetime = df.withColumn(f'datetime', to_utc_timestamp((col('timestamp') / 1000).cast("timestamp"), 'Z'))
    df_with_day = df_with_datetime.withColumn(f'day', date_format('datetime', 'yyyy-MM-dd'))

    grouping_keys = ('city_name', 'parameter_name', 'day', 'datetime')
    aggregated_df = df_with_day.groupby(*grouping_keys).agg(avg(col('value')).alias('average'))
    return aggregated_df


def run(env: str, date: str, root_path: str):
    """Main ETL script definition.

    :return: None
    """
    # execute ETL pipeline
    logger.info("Reading raw data from S3...")
    df = read_raw_data(date, root_path)
    aggregate_by_station = aggregate_station_by_day(df)
    logger.info(f"{aggregate_by_station.count()} entries for aggregates by station...")
    logger.info("Writing parquet data for station aggregate by day...")
    aggregate_by_station.write.partitionBy('day').mode('append').parquet(
        f's3a://{root_path}/niels-data/clean/aggregate_station_by_day/')
    aggregate_by_city = aggregate_city_by_hour(df)
    logger.info(f"{aggregate_by_city.count()} entries for aggregates by city...")
    logger.info("Writing parquet data for city aggregate by hour...")
    aggregate_by_city.write.partitionBy('day').mode('append').parquet(
        f's3a://{root_path}/niels-data/clean/aggregate_city_by_hour/')


if __name__ == "__main__":
    main()
