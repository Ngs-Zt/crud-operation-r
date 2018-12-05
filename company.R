
library(RMySQL)
library(DBI)

# create connection
con = dbConnect(RMySQL::MySQL(), user = 'root', 
                password = 'root_password', host = 'localhost')


#create database
dbSendQuery(con,"CREATE DATABASE company;")

#use database
dbSendQuery(con, "USE company;")

#create employees table
dbSendQuery(con, "CREATE TABLE employees( 
            employee_id INT NOT NULL AUTO_INCREMENT, 
            first_name VARCHAR(30) NOT NULL, 
            last_name VARCHAR(30) NOT NULL, 
            started_at DATE NOT NULL,
            PRIMARY KEY(employee_id));")


#create product table
dbSendQuery(con, "CREATE TABLE product( 
            product_id INT NOT NULL AUTO_INCREMENT,
            product_name VARCHAR(50) NOT NULL,
            contract enum('yes', 'no') NOT NULL, 
            PRIMARY KEY(product_id));")


#create sales table
dbSendQuery(con, "CREATE TABLE sales( 
            sales_id INT NOT NULL AUTO_INCREMENT, 
            employee_id INT, 
            product_id INT, 
            date DATE NOT NULL, 
            price DECIMAL(10, 2) NOT NULL, 
            PRIMARY KEY(sales_id), 
            FOREIGN KEY(employee_id) REFERENCES employees(employee_id),
            FOREIGN KEY(product_id) REFERENCES product(product_id));")


#Insert values into the tables

dbSendQuery(con, "INSERT INTO employees VALUES
            (NULL,'Alex','Sanchez', '2011-08-08'),
            (NULL,'Lionel','Messi', '2011-08-09'),
            (NULL,'Abebe','Kebede', '2011-08-08'),
            (NULL,'Chala','Tuma', '2011-08-08'),
            (NULL,'Hagos','Nure', '2011-08-08'),
            (NULL,'Yahya','Sharef', '2011-08-08'),
            (NULL,'Galan','Bedry', '2011-08-08'),
            (NULL,'Azeb','Abiy', '2011-08-08'),
            (NULL,'Helina','Getu', '2011-08-08')")

dbSendQuery(con, "INSERT INTO product VALUES 
            (NULL, 'milk', 'yes'),
            (NULL, 'honey', 'no'),
            (NULL, 'cholocate', 'yes'),
            (NULL, 'water', 'no'),
            (NULL, 'biscuit', 'yes'),
            (NULL, 'coffee', 'yes');")

dbSendQuery(con, "INSERT INTO sales VALUES
            (NULL, 8, 3, Now(), 27.00),
            (NULL, 5, 2, Now(), 10.50),
            (NULL, 3, 6, Now(), 42.76),
            (NULL, 1, 5, Now(), 23.50),
            (NULL, 2, 2, Now(), 17.25),
            (NULL, 7, 5, Now(), 12.25),
            (NULL, 6, 1, Now(), 09.66),
            (NULL, 4, 2, Now(), 2.75);
            ")


dbSendQuery(con, "UPDATE product SET product_name ='Pepsi'
            WHERE product_id = 4;")

dbReadTable(con, 'product')

dbGetQuery(con, "SELECT first_name, last_name FROM employees;")



dbSendQuery(con, "DELETE FROM sales WHERE
             sales_id = 8;")

dbReadTable(con, 'sales')


temp <- dbSendQuery(con, "SELECT first_name, last_name FROM employees;")
names <- dbFetch(temp, n= 5)

email <- c('alex_sanchez@gmail.com','lionel_messi@gmail.com', 'abebe_kebede@gmail.com',
           'chala_tuma@gmail.com', 'hagos_nure@gmail.com')
email_colomn <- data.frame(email)

personal_info <- cbind(names, email_colomn)

dbSendQuery(con, "CREATE TABLE score(
            english INT NOT NULL,
            mathematics INT NOT NULL,
            history INT NOT NULL,
            geography INT NOT NULL,
            civics INT NOT NULL,
            physics INT NOT NULL,
            chemistry INT NOT NULL,
            biology INT NOT NULL);")

dbSendQuery(con, "INSERT INTO score VALUES
            (75, 99, 88, 97, 80, 72, 60, 95),
            (95, 95, 89, 96, 81, 73, 61, 96),
            (83, 100, 90, 95, 82, 92, 95, 100),
            (87, 72, 76, 83, 94, 91, 53, 90),
            (81, 85, 92, 93, 83, 90, 60, 73),
            (84, 99, 88, 97, 80, 72, 60, 95),
            (63, 90, 88, 95, 92, 88, 84, 81),
            (94, 75, 93, 97, 90, 92, 80, 95),
            (99, 84, 88, 87, 80, 72, 60, 90),
            (92, 79, 94, 67, 89, 91, 62, 95);")

dbRemoveTable(con, 'score')
dbListTables(con)
temp_2 <- dbSendQuery(con, "SELECT * FROM score")
score <- dbFetch(temp_2, n= 5)


student <- cbind(personal_info, score)

#Insert calculated column to student

student$total <- as.double(rowSums(Filter(is.numeric, student)))
student$average <- as.double(rowMeans(Filter(is.numeric, student[1:length(student) - 1])))

print(student$total)

print(student)

student_table <- dbCreateTable(con, 'student', student)
#dbClearResult(student_table)
dbListTables(con)

dbClearResult(dbListResults(con)[[1]])





  
sql <- "INSERT INTO student (first_name, last_name, email, english,mathematics, history, geography, civics, physics, chemistry, biology, total, average) VALUES "
  
sql <- paste0(sql, paste(sprintf("('%s', '%s','%s','%d','%d','%d','%d','%d','%d','%d','%d', '%g', '%g')", 
                                     student$first_name, student$last_name, student$email, student$english
                                   , student$mathematics, student$history, student$geography
                                   , student$civics, student$physics, student$chemistry
                                   , student$biology, student$total,student$average), collapse = ","))
  
print(sql)
query <-dbSendQuery(con, sql)

dbReadTable(con, 'student')
