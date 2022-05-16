# CSVQL Language

The declarative language is designed to be easy to pick up by having a syntax that closely resembles
the likes of SQL. The column selection format and file specification was modified to best accommodate
CSV tables. Our language supports different program formatting,
various syntactic sugar for the programmer’s convenience, commenting and multiple options for
merging files.

## Syntax
### SELECT Statement:
The select statement allows the user to pick which columns to display. It can either be a single
asterisk, meaning they want the entire database to be displayed or they may want:
- Individual columns, denoted as **A[1]** meaning first column from file A
- String columns, denoted as **“0”**, or **“Test”**. Any string within speech marks will be printed for
as many rows as there are in the final queried database/csv.
- Coalesce columns, denoted as **COALESCE( A[1] , B[1] )**. Our coalesce statement provides
equivalent functionality to that of IFNULL in SQL and COALESEC in SQLite, where it returns the
first non-null/empty value or null if both are null.

The user can select as many columns as they wish so long as they’re separated by a comma.
Furthermore, ordering from the SELECT statement will be applied to the final output.

### FROM Statement:
The from statement is responsible for getting the desired csv files and applying the selected join to
them. The language allows for cross and left join which can be used in conjunction.
Cross join is denoted as JOIN between 2 csv files and is syntactic sugar for SQLite’s comma join i.e.,
FROM Table1, Table2. An example of cross join in our language would be the following:
- **FROM ( A : 2) JOIN ( B : 2)**
Left join is denoted as LEFT JOIN between 2 csv files followed by an ON statement to denote which
column the left join should apply on. An example of left join in our language would be the following:
- **FROM (A : 3) LEFT JOIN (B : 4) ON A[1] = B[1]**
Our language also supports aliasing csv files through the use of the AS statement. Including this
allows the language to deal with ambiguous columns. An example of aliasing would be the following:
- **FROM (A : 3) AS tableA JOIN (A : 3) AS tableB**
Please note that once aliases have been applied, when selecting columns, the user must match it to
the alias.

### WHERE Statement:
The WHERE statement is responsible for applying certain predicates to the retrieved database.
Various predicates are supported, and the specification is the following:
- Columns can be compared to other columns (the values they store)
  - **WHERE A[1] = B[1]**               
  - **WHERE A[1] != B[1] (not equal)**
- Columns can be compared to exact values
  - **WHERE A[1] = “string”**                  
  - **WHERE A[1] = “5”**
- Columns can be checked for null values
  - **WHERE A[1] = null**                      
  - **WHERE A[1] != null**
- Multiple conditions are connected via AND
  - **WHERE A[1] != null AND A[2] = B[2]**

### Commenting:
Users can add comments by using “--" followed by the comment string. This has to be either on
separate lines or at the end of a line.

### Type Checking:
As the grammar is very strict and well defined any type errors can be identified during parsing. Thus,
if a string is used as opposed to a number for column selection or arity the user will be prompted
with a parsing error which details the exact line and column responsible for the error. An example of
such an error would be the following:
- **SELECT A[one] FROM ( A : 2) JOIN ( B : 2)**
![image-000](https://user-images.githubusercontent.com/72355656/168533731-72b4bde7-3162-4072-8a14-f6022b81e27c.png)


### Error Checking:
Several error messages have been implemented to inform the user of various issues in their query.
They are intended to give valuable feedback and point directly to which component of the query is
causing the error as will be shown below:
● If the user were to select a column name that does not match any file name or alias within
the query, then they will be prompted with the following error message:
![image-001](https://user-images.githubusercontent.com/72355656/168533777-874c174a-5f22-44ef-a8d2-6a030151e54f.png)

● If the user were to input a column index that does not exist in the given table, they will be
prompted with the following error message:
![image-002](https://user-images.githubusercontent.com/72355656/168533792-f9fa8336-9657-495f-a3ce-0b71a8e05a5a.png)

● If the user were to specify multiple files with the same name, leading to ambiguous column
selection then they will be prompted with the following error message:
![image-003](https://user-images.githubusercontent.com/72355656/168533802-7c1fa6a7-09b9-4d41-b444-9715311ff673.png)


## Interpreter
### The Database data type:
The Database data type represented as
[[[String]]], can be visualised as the image
suggests. It is returned after evaluating FROM
and WHERE statements.

![image-004](https://user-images.githubusercontent.com/72355656/168533998-40c4674e-a3f1-4634-9180-da186ed92130.png)

### Execution model:
The interpreter executes the query statements in a sequential manner (Execuction Model Figure), first evaluating
FROM, then WHERE (if applicable) and finally SELECT. The execution model of queries works as follows:
- FROM + JOIN is first evaluated, and a database is constructed to represent all CVSs and
columns. Furthermore, a list of all tables (see below) and their corresponding arity is created.
- Then the program evaluates WHERE statements. Such an evaluation takes in the database,
which was previously generated, the list of tables, and then filters out the rows/columns
which match the predicates provided in the query. This is done recursively via pattern
matching thus a new database is returned after each iteration (assuming there's more than
one predicate).
- Then the program evaluates SELECT statements. Such an evaluation takes in the same
arguments as the WHERE statement evaluator, however it returns a [[String]], as the need for
knowing table positions is removed once all required columns are returned. This [[String]]
represents all rows in the final csv document. If an asterisk is used then the entire database is
returned with rows concatenated, otherwise it recursively goes through each column and
adds it to the most recent [[String]].
- Finally, in the evalStatement Method the returned rows are intercalated with
commas and are then outputted one by one using putStrLn. This result is the final csv output
and it is what is returned from the evaluator.


### The list of tables:
To keep track of where each table appears the Get_Table_Index method is used (Execuction Model Figure). It returns
a [(String,Arity)] data structure which lists all files alongside their arity in the exact same order as
they appear in the original query. This data structure is later passed on to the evaluate WHERE and
SELECT methods, allowing them to retrieve desired tables/columns from the database. For example:
**FROM (A : 2) JOIN (B : 3) JOIN (C : 4) Would return [(A,2),(B,3),(C,4)]**.

### Program States:
- **Evaluate FROM + JOIN** - A new database alongside the list of all tables enter the program
state (Database, [[String]])
- **Evaluate WHERE** - The database in the program state is accessed and then adjusted to filter
out columns/rows which match the predicates. This is done by also accessing the list of
tables.
- **Evaluate SELECT** - The database in the program state is accessed alongside the list of tables
and a [[String]] is created inside the program.
- **EvalStatement Method** (Execuction Model Figure) - The returned [[String]] is accessed and is then returned
by the evaluator in a csv format.

### Syntax in Backus-Naur Form
![image-007](https://user-images.githubusercontent.com/72355656/168534441-1224ac4f-306d-4e97-8888-b7fd7f7c454f.png)

## Example programs
![image-013](https://user-images.githubusercontent.com/72355656/168534301-a0eaf191-69f3-4922-86b5-0df34a0e5637.png)
![image-012](https://user-images.githubusercontent.com/72355656/168534325-4271dc80-161f-45c8-9134-a4d98fc4939b.png)

## Execuction Model Figure
![image-025](https://user-images.githubusercontent.com/72355656/168534953-b2b28eb0-3331-4d18-8a87-2726fef53f27.png)
