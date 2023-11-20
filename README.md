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
- configure your aws_profile to connect to the correct aws_account and use the correct credentials. You can then use AWS_PROFILE=... before executing your python code
- write the files to your own path on the s3 bucket (integrated-exercise-resources). Prefix the path on the s3 bucket with your first name like: niels-data/...
3. create a aws batch job definition that allows you to run your job using AWS batch. Use the AWS role with name: integrated-exercise-batch-job-role. 
- Try wether you can get this working using Terraform: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_definition
- You will need to create an ecr repository for the docker image that will be used in AWS batch. In order to push images, make sure you are logged into the private ecr repository:
`aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-west-1.amazonaws.com`
- you can use any python base image to start from
- trigger a job from the AWS batch definition using the AWS console UI 
4. create the Airflow dag for ingesting the data every day at midnight. For this I have setup MWAA in the AWS account, which you will all share together. Make sure you prefix your dag with your firstname. Use the AWS console and the MWAA UI to accomplish this step
5. (bis) make sure you handle timezones correctly
6. (bis) You can also write integration tests with the API and or s3 using localstack

Note: 1 is required before moving along to the next task. 2-3-4 can be done at a later time if you want to combine it with Task 2 or you did not have the respective training session.

## Task 2: clean and tranform the output data using pyspark
In this step we will use pyspark to read the raw json files and transform them to the required output and write the results in our clean layer.
The following transformations are required:
- add a datetime column that converts the epoch millis to a datatime (string representation)
- Calculate the average of the measurements for a given station by day

You can write the output as parquet to S3 as clean/aggregate_station_by_day partitioned by (what is the most logic partitioning?)

### Steps for development
1. Start from the Raw data of Task 1 and read it into a spark dataframe using pyspark. Write the output data as parquet. Start locally on your laptop as this is the quickest for iterating
- to read from s3 with pyspark, make sure you configure the spark_session with the following config: "fs.s3a.aws.credentials.provider":"com.amazonaws.auth.DefaultAWSCredentialsProviderChain"
The full config could look as follows:
```
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
)
.getOrCreate()
```
- to specify the filesystem with Spark: use s3a://<bucket>/<firstname-data>/clean/<path> as filepath 
Note: we add the extra hadoop-aws package to make sure it is downloaded before Spark starts. This is the quickest way to set it up for both the local and the remote execution environment.
Note2: export the AWS environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN) instead of the profile to have the least chance of credentials errors with the spark/hadoop-aws packages.
2. (bis): you can write a couple of unit tests that verifies the output of the transformation function. To make it simple, you can add the following code in a test class:
```
import pytest
from pyspark import SparkConf
from pyspark.sql import SparkSession
@pytest.fixture(scope="session")
def spark(request):
    """Fixture for creating a SparkSession."""
    conf = {}
    conf = SparkConf().setAll(pairs=conf.items())
    builder = SparkSession.builder.master("local[*]").config(conf=conf)
    session = builder.getOrCreate()
    request.addfinalizer(session.stop)

    return session
```
 which contains a fixture for running your Spark job locally. The goal is to create a dataframe with your test data, call your aggregate function and validate whether it produces the correct average depending on the situation (e.g. different timestamps within 1 day, different parameters,...)
3. create a aws batch job definition that allows you to run your job using AWS batch. Use the AWS role with name integrated-exercise-batch-job-role. 
- Try wether you can get this working using Terraform. You will need to create an ecr repository for your docker image that will be used in AWS batch, it can be the same as in Task1 where you just use a different entrypoint.
- Use a similar Dockerfile as a starting point:
```
FROM public.ecr.aws/dataminded/spark-k8s-glue:v3.2.1-hadoop-3.3.1

ENV PYSPARK_PYTHON python3
WORKDIR /opt/spark/work-dir

USER 0

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt --no-cache-dir
COPY . .

RUN pip install --no-cache-dir -e .
```
4. create the Airflow dag for ingesting the data every day at midnight. For this I have setup MWAA in the AWS account, which you will all share together. Make sure you prefix your dag with your firstname. Use the AWS console and the MWAA UI to accomplish this step
- upload file: `aws s3 cp raw_customers.csv s3://datafy-demo-data/coffee-data/raw/raw_customers.csv`

Troubleshooting typical issues:
- If you get some weird error while running Spark with s3a, like: `py4j.protocol.Py4JJavaError: An error occurred while calling o42.json.`
Make sure all hadoop jars have the same version as is specified in the hadoop-aws config (3.3.1 normally). This can be found under venv_root/lib/python3.10/site-packages/pyspark/jars/hadoop-*.jar
