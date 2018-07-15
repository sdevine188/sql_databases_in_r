library(dplyr)
library(dbplyr)
library(DBI)
library(RMySQL)

# https://rpubs.com/nwstephens/sql-queries-with-r
# https://cran.r-project.org/web/packages/dbplyr/vignettes/dbplyr.html
# https://www.youtube.com/watch?v=9OSB9pmlJpI
# https://www.w3schools.com/sql/

# connect to datacamp database
con <- dbConnect(MySQL(), dbname = "company", 
                        host = "courses.csrrinzqubik.us-east-1.rds.amazonaws.com",
                        port = 3306, user = "student", password = "datacamp")


###############################################################################


# use dbGetQuery function from DBI package to make query using raw SQL

# show tables
dbGetQuery(con, 'SHOW TABLES;')

# inspect tables
dbGetQuery(con, 'SELECT * FROM employees;')
dbGetQuery(con, 'SELECT * FROM products;')
dbGetQuery(con, 'SELECT * FROM sales;')

# join employees and sales
df <- dbGetQuery(con, 'SELECT * FROM employees LEFT JOIN sales ON employees.id = sales.employee_id;')
df
glimpse(df)
class(df)


##########################################################
#############################################################
###############################################################


# can also use dbplyr to translate dplyr syntax into SQL query
tbl(con, "employees") %>% left_join(., tbl(con, "sales"), by = c("id" = "employee_id")) %>%
        group_by(name) %>% summarize(order_count = n(), total_cost = sum(price, na.rm = TRUE))






