# Axxes integrated exercise

Welcome to the integrated exercise. Everything that you will learn over the 2 week course can be applied on this realistic pipeline.
In short what you will do is:
1. Ingest irceline open air quality data to S3 using their REST API using python
2. Clean and transform the input data using pyspark and write the output to S3, Snowflake
3. Run and schedule the application code using Docker, AWS Batch and Airflow

## Getting started

We've set up a Gitpod environment containing all the tools required to complete this exercise (awscli, python, vscode, ...). You can access this environment by clicking the button below:

https://gitpod.io/#https://github.com/...

NOTE: When you fork the code repo to your own remote make sure to change the Gitpod URL to reflect your account in this README!

This is an ubuntu-based environment pre-installed with:

- VSCode
- A Python3 virtual environment: we recommend you always work inside this environment.
- The AWS CLI
Before you start data crunching, set up your $HOME/.aws/credentials file. This is required to access AWS services through the API. To do so, run aws configure in the terminal and enter the correct information:

```
AWS Access Key ID [None]: [YOUR_ACCESS_KEY]
AWS Secret Access Key [None]: [YOUR_SECRET_KEY]
Default region name [None]: eu-west-1
Default output format [None]: json
```
IMPORTANT: Create a new branch and periodically push your work to the remote. After 30min of inactivity this environment shuts down and you will likely lose unsaved progress. As stated before, change the Gitpod URL to reflect your remote.

## Task 1: extract weather data

As mentioned, we will load open air quality data from irceline using their REST API. For detailed documentation about their endpoints take a look at their [website](https://www.irceline.be/en/documentation/open-data). In this step we will query the REST API and write the relevant information in our raw datalake using json files using plain json.

### Rest API information
We will use plain python to call the REST API and load hourly values for their stations. We will start from their raw data and build up our own dataset for it on our own.
The parameters we are interested in are:
- ppm10 (5)
- ppm25 (6001)
- no2 (8)
- co2 (71)
- so2 (1)

The root endpoint of their Rest API is: https://geo.irceline.be/sos/api/v1/

They have 2 interesting endpoints that you will need to combine:
- query stations: here you can query all stations or start by only looking at stations in a city of your choice (e.g. Antwerp). Note: use expanded=true to get the timeseries_ids which you will need for the next API call.
- query timeseries: for every station, you get a list of timeseries (containing values for every supported parameter of that station). Fetch the data for the parameters we are interested in, the others you can ignore for now

Endpoints:
- stations: https://geo.irceline.be/sos/api/v1/api/v1/stations maybe the near query parameter can be useful initially?
- timeseries: https://geo.irceline.be/sos/api/v1/timeseries look at the query parameters to see what can be useful here

Extra tips:
Think about the lessons you have learned about ingesting data for data pipelines like:
- make sure to include all relevant data in the raw input as that will be the starting point for all our subsequent queries
- idempotency: rerunning the same job should yield the same result
- reproducability: read/write the raw data (example: json files using data coming from the API). Only afterwards transform this to a structure we need...

### Steps for development

1. Start by experimenting with the API and getting the results you want locally. This ensures a fast feedback cycle. Write the raw data as json to 1 or more files.
2. If you are confident in your solution, you may test the integration with AWS. For this you would need to make the following changes:
- get AWS credentials using the boto3 python client
- write the files to your own newly created s3 bucket (prefix it with your first name). You can create the s3 bucket through the AWS console if you want
3. create a aws batch job definition that allows you to run your job using AWS batch. Use the following AWS role: <TODO>. Try wether you can get this working using Terraform
4. create the Airflow dag for ingesting the data every day at midnight. For this I have setup MWAA in the AWS account, which you will all share together. Make sure you prefix your dag with your firstname. Use the AWS console and the MWAA UI to accomplish this step
5. (bis) You can also write integration tests with the API and or s3 using localstack

Note: 1 is required before moving along to the next task. 2-3-4 can be done at a later time if you want to combine it with Task 2 or you did not have the respective training session.

## Task 2: clean and tranform the output data using pyspark
In this step we will use pyspark to read the raw json files and transform them to the required output and write the results in our clean layer.
The following transformations are required:
- add a datetime column that converts the epoch millis to a datatime (string representation)
- Calculate the average of the measurements for a given station by day

You can write the output as parquet to S3 as clean/aggregate_station_by_day partitioned by (what is the most logic partitioning?)

### Steps for development
1. Start from the Raw data of Task 1 and read it into a spark dataframe using pyspark. Write the output data as parquet. Start locally on your laptop as this is the quickest for iterating
2. (bis): you can write a couple of unit tests that verifies the output of the transformation function. In this repo you can find the conftest.py (<TODO>), which contains a spark fixture that you can use in your python tests. The goal is to create a dataframe with your test data, call your aggregate function and validate whether it produces the correct average depending on the situation (e.g. different timestamps within 1 day, different parameters,...)
3. create a aws batch job definition that allows you to run your job using AWS batch. Use the following AWS role: <TODO>. Try wether you can get this working using Terraform
4. create the Airflow dag for ingesting the data every day at midnight. For this I have setup MWAA in the AWS account, which you will all share together. Make sure you prefix your dag with your firstname. Use the AWS console and the MWAA UI to accomplish this step

