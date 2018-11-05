library(dplyr)
library(dbplyr)
library(DBI)
library(RMySQL)
library(RODBC)
library(stringr)

# database task

# setwd
setwd("H:/R/sql_databases_in_r")

# connect to access database
database_name <- "customer_orders_database.accdb"
channel <- odbcConnectAccess2007(database_name)

# get top 5 customer names based on dollar amount ordered
sqlQuery(channel, str_c("SELECT TOP 3 customers.first_name, SUM(orders.item_cost) FROM orders 
                        LEFT JOIN customers ON orders.customer_id = customers.customer_id
                        GROUP BY first_name ORDER BY SUM(orders.item_cost) DESC"))

close(channel)
