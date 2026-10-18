# Walmart Data Engineering Project

An end-to-end data engineering project that ingests Walmart retail data, transforms it using dbt and Databricks, and orchestrates the entire workflow with Apache Airflow.

## Overview

This project demonstrates how raw retail data can be processed into structured, analytics-ready datasets using a medallion architecture. It combines cloud data processing, SQL transformations, data quality checks, historical change tracking, and workflow orchestration.

## Tech Stack

- **Python** — Data loading and orchestration logic
- **PostgreSQL** — Source data storage
- **Databricks** — Data ingestion and Delta table processing
- **dbt Core** — Data transformations, testing, and snapshots
- **dbt-databricks** — dbt integration with Databricks
- **Apache Airflow** — Workflow orchestration and task scheduling
- **Docker Compose** — Containerized Airflow environment
- **uv** — Python project and dependency management

## Architecture

The project follows a Bronze–Silver–Gold medallion architecture.

```text
Walmart CSV Datasets
        |
        v
   PostgreSQL
   (Raw Tables)
        |
        v
Databricks Ingestion Job
        |
        v
 Bronze Layer (Delta Tables)
        |
        v
 Silver Technical Layer
 Data Cleaning and Validation
        |
        v
 Silver Business Layer
 Metadata-Driven OBT
        |
        v
    Gold Layer
 Ephemeral Models and Facts
        |
        v
 Dimension Snapshots
 Historical Change Tracking

 Apache Airflow orchestrates
 the end-to-end workflow.
```

## Project Features

### 1. Data Ingestion

The project includes six Walmart datasets:

- Customers
- Employees
- Orders
- Order Items
- Products
- Stores

The CSV files can be loaded into PostgreSQL raw tables using the provided Python loading script. A Databricks ingestion job then handles the ingestion workflow into the Bronze layer.

### 2. Bronze Layer

The Bronze layer stores ingested data as Delta tables in Databricks. It acts as the initial data layer for downstream transformations.

### 3. Silver Technical Layer

The Silver Technical layer contains individual dbt models for customers, employees, orders, order items, products, and stores.

This layer focuses on preparing data for further processing, applying transformation logic, and checking data quality.

Data tests include uniqueness and non-null checks for key columns, along with custom positive-value validation for fields such as price and quantity.

### 4. Silver Business Layer — Metadata-Driven OBT

The Silver Business layer contains a metadata-driven One Big Table (OBT) model implemented with dbt and Jinja.

The model combines data from multiple Silver Technical tables using configurable table metadata, column selections, aliases, and join conditions.

This approach reduces repetitive SQL, makes the model easier to maintain, and simplifies the addition or modification of selected fields and joins.

### 5. Gold Layer

The Gold layer contains downstream models intended for analytics and reporting.

- **Ephemeral models:** Reusable SQL logic that dbt incorporates into downstream models instead of creating separate database tables or views.
- **Fact models:** Models designed to support analytical queries and reporting.

### 6. Dimension Snapshots

The project includes five dbt snapshots:

- `dim_customers`
- `dim_employees`
- `dim_orders`
- `dim_products`
- `dim_stores`

These snapshots track changes in source records over time according to their configured snapshot strategies.

### 7. Data Quality and Freshness

The pipeline includes dbt data tests for the Silver Technical and Silver Business layers, along with source freshness checks.

These checks help identify data quality issues and stale source data before downstream processing continues.

### 8. Apache Airflow Orchestration

Apache Airflow coordinates the workflow through a DAG named `orchestrate`.

The workflow includes the following stages:

1. Trigger the Databricks ingestion job and monitor its status.
2. Clean generated dbt artifacts.
3. Check source freshness.
4. Run Silver Technical transformations and tests.
5. Run Silver Business transformations and tests.
6. Execute Gold ephemeral-related dbt commands.
7. Execute dimension snapshots.
8. Run Gold fact models.

Task dependencies enforce the intended execution order, so downstream tasks wait for their upstream tasks to complete successfully.

Docker Compose runs the Airflow services and their supporting PostgreSQL and Redis services in a local development environment.

## Repository Structure

```text
DE-Walmart-Project/
├── dags/
│   └── orchestrate_example.py
├── config/
├── docker-compose.yaml
├── Dockerfile
├── requirements.txt
├── pyproject.toml
├── uv.lock
├── walmart_dataset/
│   ├── data/
│   │   ├── customers.csv
│   │   ├── employees.csv
│   │   ├── order_items.csv
│   │   ├── orders.csv
│   │   ├── products.csv
│   │   └── stores.csv
│   ├── ddl/
│   └── load_data.py
└── walmart_project/
    ├── dbt_project.yml
    ├── models/
    │   ├── bronze/
    │   ├── silver_technical/
    │   ├── silver_business/
    │   └── gold/
    │       ├── ephemeral/
    │       └── fact/
    ├── snapshots/
    ├── macros/
    ├── seeds/
    └── tests/
```

## Prerequisites

Before running the project, ensure you have:

- Docker Desktop with Docker Compose
- A Databricks workspace and a configured ingestion job
- PostgreSQL for the initial source datasets
- Python and uv for local Python project management
- A configured dbt profile for Databricks connectivity

## Setup and Execution

### 1. Clone the repository

```bash
git clone https://github.com/Vinayak820/DE-Walmart-Project.git
cd DE-Walmart-Project
```

### 2. Configure credentials

Create a local `.env` file containing the environment variables required by Docker Compose and your Databricks integration.

Configure your Databricks workspace URL, access token, job ID, and other required settings. Configure dbt's profile with the appropriate Databricks connection details.

Keep credentials and passwords out of source control. Do not commit `.env` files, access tokens, or database passwords.

### 3. Load the source datasets

Configure the PostgreSQL connection used by `walmart_dataset/load_data.py`, then run the script from the appropriate working directory after creating the required raw tables.

### 4. Build and start Airflow

```bash
docker compose up -d --build
```

Check the services:

```bash
docker compose ps
```

### 5. Open the Airflow UI

Open:

`http://localhost:8080`

Use the administrator credentials configured in your local Airflow environment.

Enable and trigger the `orchestrate` DAG to execute the pipeline. Check task logs in the Airflow UI to monitor execution and troubleshoot failures.

## Useful dbt Commands

Run these commands from the dbt project directory with the required profile and dependencies configured.

```bash
# Check dbt project configuration
dbt debug

# Check source freshness
dbt source freshness

# Run Silver Technical models
dbt run --select silver_technical

# Test Silver Technical models
dbt test --select silver_technical

# Run Silver Business models
dbt run --select silver_business

# Test Silver Business models
dbt test --select silver_business

# Run dimension snapshots
dbt snapshot

# Run Gold fact models
dbt run --select gold/fact
```

For a local uv-managed environment, prefix the dbt commands with `uv run`. In the Airflow containers, use the command appropriate to the dependencies installed in the container.

## Final Status

The project has been executed successfully in the local development environment, including the Airflow orchestration workflow and the dbt transformation stages. Individual tasks and snapshots should be verified through the Airflow task states and execution logs for each run.

This repository represents the working project version after integrating data ingestion, layered transformations, data quality checks, historical snapshots, and Airflow orchestration.

## Future Improvements

- Add automated CI checks for dbt parsing and testing.
- Improve retry handling and notifications for failed pipeline tasks.
- Add monitoring and operational metrics.
- Extend analytical models with additional retail KPIs and reporting use cases.

## Author

**Vinayak Singh**

GitHub: [Vinayak820](https://github.com/Vinayak820)