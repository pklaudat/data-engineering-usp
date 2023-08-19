from enum import Enum
from abc import ABC, abstractclassmethod
from pyspark.sql.dataframe import DataFrame

class DataSource(Enum):
    S3 = 1
    STORAGE_ACCOUNT = 2
    LOCAL = 3

class Data(ABC):
    def __init__(self, data_source: DataSource, data_path) -> None:
        self.__frame = None
        self.__source = data_source
        self.__path = data_path

    def extract(self) -> None:
        if (self.__source == DataSource.S3):
            pass
        elif (self.__source == DataSource.STORAGE_ACCOUNT):
            pass
        else:
            try:
                open('')
            except:
                pass

    def load(self) -> None:
        pass

    @abstractclassmethod
    def transform(self, steps) -> None:
        pass

    @property
    def frame(self) -> DataFrame:
        return self.__frame
    
    @property
    def source(self) -> DataSource:
        return self.__source
