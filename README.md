# Faasos SQL Data Analysis

This repository contains the code and documentation for an Exploratory Data Analysis (EDA) of Faasos data using SQL queries in Python via the *mysql-connector* module. The data is stored in a MySQL database.

## Dataset: [Link](Faasos_dataset.txt)

The dataset comprises multiple tables in the database. Here are the details of the tables used for this analysis:

### Table: driver

- **driver_id**: Driver ID.
- **reg_date**: Date when the driver registered.

### Table: ingredients

- **ingredients_id**: Ingredient ID.
- **ingredients_name**: Name of the ingredient.

### Table: rolls

- **roll_id**: Roll ID.
- **roll_name**: Name of the roll.

### Table: rolls_recipes

- **roll_id**: Roll ID.
- **ingredients**: Ingredients associated with the roll.

### Table: driver_order

- **order_id**: Order ID.
- **driver_id**: Driver ID.
- **pickup_time**: Pickup time for the order.
- **distance**: Distance for delivery.
- **duration**: Duration for delivery.
- **cancellation**: Cancellation status for the order.

### Table: customer_orders

- **order_id**: Order ID.
- **customer_id**: Customer ID.
- **roll_id**: Roll ID.
- **not_include_items**: Items not included in the order.
- **extra_items_included**: Extra items included in the order.
- **order_date**: Date of the order.

## EDA File

[Faasos.ipynb](Faasos.ipynb): Jupyter Notebook containing the Python code for the exploratory data analysis of Faasos data using SQL queries.

[Faasos solution (SQL Code).sql](Faasos%20solution%20(SQL%20code).sql): MySQL script containing the queries for the exploratory data analysis of the Faasos data.

## Usage

You can clone this repository to your local machine and run the Jupyter Notebook to perform the SQL-based EDA. Ensure you have a MySQL server set up with the necessary database containing the required tables.

```bash
git clone https://github.com/HloHarshit/Faasos-SQL-EDA.git
cd Faasos-SQL-EDA
jupyter notebook Faasos.ipynb
```
