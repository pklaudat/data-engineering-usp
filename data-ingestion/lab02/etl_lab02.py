import os
import polars
import logging as log


def retrieve_df(path_name: str, separator: str) -> polars.DataFrame:
    dfs = []
    for file in os.listdir(f"data/{path_name}"):
        if file.endswith(".csv") or file.endswith(".tsv"):
            # discard empty files
            if os.stat(f"data/{path_name}/{file}").st_size > 0:
                dfs.append(polars.read_csv(f"data/{path_name}/{file}", separator=separator))
    return polars.concat(dfs, how="diagonal")    

def main() -> None:

    # retrieve the banks data frame from the banks blob
    bank_df = retrieve_df("banks", "\t")
    log.info('Bank Data Frame:\n', bank_df)
    print(bank_df)

    # retrieve a list of all the employees data frames in the employees blob
    employee_df = retrieve_df("employees", "|")
    log.info('Employee Data Frame:\n', employee_df)
    print(employee_df)

    # retrieve a list of all the claims data frames in the claims blob
    claims_df = retrieve_df("claims", ",")
    log.info('Claims Data Frame:\n', claims_df)
    print(claims_df)
