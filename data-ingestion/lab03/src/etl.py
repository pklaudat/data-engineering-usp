import os
import logging as log
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *





def main() -> None:
    spark = (
        SparkSession.builder
        .master('local')
        .appName('ETL_LAB03')
        .getOrCreate()
    )

    
    df = spark.read.csv('../data/banks/')
    breakpoint()

main()


