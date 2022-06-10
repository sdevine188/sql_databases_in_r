library(tidyverse)
library(dbplyr)
library(DBI)
library(RSQLite)

# https://dbplyr.tidyverse.org/
# https://dbi.r-dbi.org/

# Create an ephemeral in-memory RSQLite database
con <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")

dbListTables(con)
#> character(0)
dbWriteTable(con, "mtcars", mtcars)
dbListTables(con)
#> [1] "mtcars"

dbListFields(con, "mtcars")
#>  [1] "mpg"  "cyl"  "disp" "hp"   "drat" "wt"   "qsec" "vs"   "am"   "gear"
#> [11] "carb"
dbReadTable(con, "mtcars")
#>    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
#> 1 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
#> 2 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
#> 3 22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
#> 4 21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
#> 5 18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
#> 6 18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
#> 7 14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
#> 8 24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2
#> 9 22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2
#>  [ reached 'max' / getOption("max.print") -- omitted 23 rows ]

# You can fetch all results:
res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
dbFetch(res)
#>    mpg cyl  disp hp drat    wt  qsec vs am gear carb
#> 1 22.8   4 108.0 93 3.85 2.320 18.61  1  1    4    1
#> 2 24.4   4 146.7 62 3.69 3.190 20.00  1  0    4    2
#> 3 22.8   4 140.8 95 3.92 3.150 22.90  1  0    4    2
#> 4 32.4   4  78.7 66 4.08 2.200 19.47  1  1    4    1
#> 5 30.4   4  75.7 52 4.93 1.615 18.52  1  1    4    2
#> 6 33.9   4  71.1 65 4.22 1.835 19.90  1  1    4    1
#> 7 21.5   4 120.1 97 3.70 2.465 20.01  1  0    3    1
#> 8 27.3   4  79.0 66 4.08 1.935 18.90  1  1    4    1
#> 9 26.0   4 120.3 91 4.43 2.140 16.70  0  1    5    2
#>  [ reached 'max' / getOption("max.print") -- omitted 2 rows ]
dbClearResult(res)

# Or a chunk at a time
res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
while(!dbHasCompleted(res)){
        chunk <- dbFetch(res, n = 5)
        print(nrow(chunk))
}
#> [1] 5
#> [1] 5
#> [1] 1
dbClearResult(res)

dbDisconnect(con)



#//////////////////////////////////////////////////////////////////////////


# retrieve table
mtcars2 <- tbl(con, "mtcars")
mtcars2


# lazily generates query
summary <- mtcars2 %>% 
        group_by(cyl) %>% 
        summarise(mpg = mean(mpg, na.rm = TRUE)) %>% 
        arrange(desc(mpg))
summary
summary %>% class()

# see query
summary %>% show_query()
#> <SQL>
#> SELECT `cyl`, AVG(`mpg`) AS `mpg`
#> FROM `mtcars`
#> GROUP BY `cyl`
#> ORDER BY `mpg` DESC

# execute query and retrieve results
summary %>% collect()
#> # A tibble: 3 × 2
#>     cyl   mpg
#>   <dbl> <dbl>
#> 1     4  26.7
#> 2     6  19.7
#> 3     8  15.1

# can use the SQL directly
res <- dbSendQuery(con, "SELECT cyl, AVG(mpg) AS mpg
                  FROM mtcars
                  GROUP BY cyl
                  ORDER BY mpg DESC")
dbFetch(res)



