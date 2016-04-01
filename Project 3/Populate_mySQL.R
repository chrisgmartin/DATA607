########################################################################################
# R Code snippet for loading URL and Skills into the MySQL database.
#
########################################################################################


# load the RODBC library for access to MySQL server
library(RODBC)

# Read the URL and Skill data from github and skip the first 2 lines.  
URL_list <- read.csv("https://raw.githubusercontent.com/RobertSellers/SlackProjects/master/data/webpages.csv", stringsAsFactors = FALSE)

skill_list <- read.csv("https://raw.githubusercontent.com/RobertSellers/SlackProjects/master/data/skills.csv", stringsAsFactors = FALSE)


# establish connection to local MySQL server
# NOTE: Be sure to set the server reference appropriately to conform with your own local 
# computing environment. On my machine the server is referenced by "local_server", but the
# reference term on your machine might be different
con <- odbcConnect("local_server")

# select a database to use - in this case, the 'ds_skills' database
sqlQuery(con, "use ds_skills")

# load each item from the 'URL_list' data frame into the documents table
for(i in 1:nrow(URL_list)) {
  
  # format the required INSERT statement
  sql_stmt <- sprintf("INSERT INTO documents (dc_id, doc_path, doc_title ) VALUES (2, '%s', '%s')",
                      as.character(URL_list$WebpageURL[i]), as.character(URL_list$Title[i]))
  
  sqlQuery(con, sql_stmt)

}


# load each item from the 'skill_list' data frame into the skills table
for(i in 1:nrow(skill_list)) {
  
  # make sure all skill types are trimmed of white space and in lower case
  skill_type <- str_trim(as.character(tolower(skill_list$Type[i]) ))
                             
  # get the skill category unique ID from the skill_category table
  sql_stmt <- sprintf("SELECT sc_id FROM skill_category WHERE skill_cat = '%s'", 
                      skill_type)
  
  sc_id <-  as.numeric(sqlQuery(con, sql_stmt))
  
  # make sure all skill names are trimmed of white space and in lower case
  skill_name <- str_trim(as.character(tolower(skill_list$Skill[i]) ))
  
  # format the required INSERT statement
  sql_stmt <- sprintf("INSERT INTO skills (sc_id, skill_name ) VALUES (%d, '%s')",
                      sc_id, skill_name)
  
  # print(sql_stmt)
  
  
  res <- sqlQuery(con, sql_stmt)
  # print(res)
}


# close the database connection
odbcClose(con)

