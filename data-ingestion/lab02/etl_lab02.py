import os
import polars
import logging as log


def transform(bank_df: polars.DataFrame, employee_df: polars.DataFrame, claims_df: polars.DataFrame) -> polars.DataFrame:
    """
    This function will transform the data frames to be used in the analysis
    :param bank_df: the data frame with the banks data
    :param employee_df: the data frame with the employees data
    :param claims_df: the data frame with the claims data
    """
    # ************************************************************************************************ #
    #                                Employee Data Transformation                                      #
    # ************************************************************************************************ #
    for string_replacement_action in [
        polars.col("Nome").str.replace_all("PRUDENCIAL", ""), # remove the word PRUDENCIAL from the name
        polars.col("Nome").str.replace_all("(\.+|\/+|\-+)", ""), # remove the special characters
        polars.col("Nome").str.replace_all("SA", ""), # remove the word SA from the name
        polars.col("Nome").str.rstrip(), # remove the trailing spaces in the end of the string
    ]:
        bank_df = bank_df.with_columns(string_replacement_action)
    
    # ************************************************************************************************ #
    #                                  Claims Data Transformation                                      #
    # ************************************************************************************************ #
    for rename_column_action in [
        {"CNPJ IF": "CNPJ"},
        {"Instituição financeira": "Nome"}
    ]:
        claims_df = claims_df.rename(rename_column_action)
    
    for replace_column_action in [
        polars.col("Nome").str.replace_all("\(conglomerado\)", ""),
        polars.col("Nome").str.replace_all("(\.+|\/+|\-+)", ""), # remove the special characters
        polars.col("Nome").str.replace_all("Ô", "O"),
        polars.col("Nome").str.replace_all("SA", ""), # remove the word SA from the name
        polars.col("Nome").str.rstrip() # remove the trailing spaces in the end of the string
    ]:
        claims_df = claims_df.with_columns(replace_column_action)
    
    # drop null values in the Índex column
    claims_df = claims_df.drop_nulls(subset=["Índice", "CNPJ"])

    #  average claims by same year and bank
    claims_df = claims_df.groupby(["Nome", "Ano", "CNPJ"]).agg([
        polars.col("Quantidade total de reclamações").mean().alias("Quantidade total de reclamações"),
        polars.col("Tipo").first().alias("Tipo"), # Classificação do Banco
        # average of the index of claims removing the null values
        polars.col("Índice").max().alias("Índice"),
        polars.col("Quantidade total de clientes – CCS e SCR").mean().alias("Quantidade total de clientes – CCS e SCR")
    ])
    
    claims_df.write_csv("data/output/claims.csv")
    # ************************************************************************************************ #
    #                               Employees Data Transformation                                      #
    # ************************************************************************************************ #
    for string_replacement_action in [
        polars.col("Nome").str.replace_all("(\.+|\/+|\-+)", ""),
        polars.col("Nome").str.replace_all("SA", ""), # remove the word SA from the name
    ]:
        employee_df = employee_df.with_columns(string_replacement_action)

    # ************************************************************************************************ #
    #                                       Join Data Sources                                          #
    # ************************************************************************************************ #

    # make join of employee_df and claims_df using the CNPJ and Nome columns
    bank_claims_df = claims_df.join(bank_df, on=["Nome","CNPJ"], how="left")
                
    # make join of bank_claims_df and employee_df using the CNPJ and Nome columns
    bank_claims_employee_df = bank_claims_df.join(employee_df, on=["Nome", "CNPJ"], how="cross")

    bank_claims_employee_df = bank_claims_employee_df.select([
        "Nome", 
        "CNPJ", 
        "Tipo", # Classificação do Banco
        "Índice", # Indice de reclamações 
        # "Quantidade total de clientes – CCS e SCR", # Quantidade de Clientes do Bancos
        "Quantidade total de reclamações", # Quantidade de reclamações
        "Recomendam para outras pessoas(%)", # Indice de satisfação dos funcionários dos bancos
        "Remuneração e benefícios", # Índice de satisfação com salários dos funcionários dos bancos.
    ])

    for rename_column_action in [
        {"Índice": "Índice de reclamações"},
        {"Quantidade total de reclamações": "Quantidade de reclamações"},
        {"Tipo": "Classificação do Banco"},
        # {"Quantidade total de clientes - CCS e SCR": "Quantidade de Clientes do Banco"},
        {"Recomendam para outras pessoas(%)": "Índice de satisfação dos funcionários dos bancos"},
        {"Remuneração e benefícios": "Índice de satisfação com salários dos funcionários dos bancos"}
    ]:
        bank_claims_employee_df = bank_claims_employee_df.rename(rename_column_action)

    # remove duplicated lines by the columns Nome and CNPJ
    bank_claims_employee_df = bank_claims_employee_df.unique(subset=["Nome", "CNPJ"])

    # Final Table must contain the following columns:
    # Nome do Banco
    # CNPJ
    # Classificação do Banco
    # Quantidade de Clientes do Bancos
    # Índice de reclamações
    # Quantidade de reclamações
    # Índice de satisfação dos funcionários dos bancos
    # Índice de satisfação com salários dos funcionários dos bancos.


def extract_data(path_name: str, separator: str) -> polars.DataFrame:
    """
    This function will extract the data from the blob containers
    :param path_name: the path name of the blob
    :param separator: the separator of the file
    :return: a data frame with the data from the blob
    """
    dfs = []
    for file in os.listdir(f"data/{path_name}"):
        if file.endswith(".csv") or file.endswith(".tsv"):
            # discard empty files
            if os.stat(f"data/{path_name}/{file}").st_size > 0:
                dfs.append(polars.read_csv(f"data/{path_name}/{file}", separator=separator))
    return polars.concat(dfs, how="diagonal")    


def main() -> None:

    # retrieve the banks data frame from the banks blob
    bank_df = extract_data("banks", "\t")
    log.info('Bank Data Frame:\n', bank_df)

    # retrieve a list of all the employees data frames in the employees blob
    employee_df = extract_data("employees", "|")
    log.info('Employee Data Frame:\n', employee_df)

    # retrieve a list of all the claims data frames in the claims blob
    claims_df = extract_data("claims", ",")
    log.info('Claims Data Frame:\n', claims_df)

    transform(bank_df, employee_df, claims_df)

main()