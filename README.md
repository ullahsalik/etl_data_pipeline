# etl_data_pipeline

This repo consists of ETL Pipeline designed using AWS services for transforming store purchase history for different categories of products from different customers. The data is loaded from csv files loaded on S3 bucket and perform aggregation over store purchase history. The transformed data is then saved on data ware house, here I have used Postgres DB on AWS arura.

##walking through repo code for setting up ETL pipeline over aws environment:
- Terraform directory contains directories base-infra for setting up all networking components for private network on AWS, terraform modules and resource creation terraform files.
- In transformation_code dir contains the python code for performing transformation of the input files from S3 data.
