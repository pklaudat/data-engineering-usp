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
        polars.col("Nome").str.rstrip() # remove the trailing spaces in the end of the string
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
    
    claims_df = claims_df.with_columns(
        polars.col("Nome").str.replace_all("(conglomerado)", "")
    )

    # ************************************************************************************************ #
    #                               Employees Data Transformation                                      #
    # ************************************************************************************************ #
    for string_replacement_action in [
        polars.col("Nome").str.replace_all("(\.+|\/+|\-+)", ""),
    ]:
        employee_df = employee_df.with_columns(string_replacement_action)

    # ************************************************************************************************ #
    #                                       Join Data Sources                                          #
    # ************************************************************************************************ #

    # make join of employee_df and claims_df using the CNPJ and Nome columns
    bank_claims_df = bank_df.join(claims_df, on=["Nome", "CNPJ"], how="left")
    # make join of bank_claims_df and employee_df using the CNPJ and Nome columns
    bank_claims_employee_df = bank_claims_df.join(employee_df, on=["Nome", "Segmento", "CNPJ"], how="left")

    bank_claims_employee_df = bank_claims_employee_df.select([
        "Nome", 
        "CNPJ", 
        "Segmento", 
        "Índice", # Indice de reclamações 
        "Quantidade total de reclamações", # Quantidade de reclamações
        "Recomendam para outras pessoas(%)", # Indice de satisfação dos funcionários dos bancos
      #  "Satisfação com salários e benefícios(%)", # Índice de satisfação com salários dos funcionários dos bancos.
    ])

    for rename_column_action in [
        {"Índice": "Índice de reclamações"},
        {"Quantidade total de reclamações": "Quantidade de reclamações"},
        {"Recomendam para outras pessoas(%)": "Índice de satisfação dos funcionários dos bancos"},
    ]:
        bank_claims_employee_df = bank_claims_employee_df.rename(rename_column_action)

    breakpoint()
    
    # Nome do Banco
    # CNPJ
    # Classificação do Banco
    # Quantidade de Clientes do Bancos
    # Índice de reclamações
    # Quantidade de reclamações
    # Índice de satisfação dos funcionários dos bancos
    # Índice de satisfação com salários dos funcionários dos bancos.

    
    # employee_claims_df = employee_claims_df.rename({"Quantidade total de clientes % CSS e SCR": "Quantidade Clientes dos Bancos"})
    # print(employee_claims_df.schema.keys())
    # # employee_claims_df = employee_claims_df.select(["Nome", "CPF", "Categoria"])
    # print(employee_claims_df.head(10))


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