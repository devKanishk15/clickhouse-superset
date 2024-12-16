# ClickHouse and Superset Setup Guide

This guide provides instructions on how to set up ClickHouse on a Minikube cluster and connect it with Apache Superset for visualizing and querying the data.

## Tools Used:
- **Minikube**: A local Kubernetes cluster
- **Terraform**: Infrastructure as code tool to set up ClickHouse on Minikube
- **Helm**: Package manager for Kubernetes to install Superset
- **Kubectl**: Command-line tool for interacting with Kubernetes
- **Superset**: Open-source data exploration and visualization tool

### Step 1: Set up ClickHouse on Minikube

To deploy ClickHouse on your Minikube cluster using Terraform:

1. Navigate to the `clickhouse/` directory where the Terraform configuration files are stored.

```bash
cd clickhouse/
```

2. Initialize Terraform to set up the environment:

```bash
terraform init
```

3. Run a Terraform plan to see the resources that will be created:

```bash
terraform plan
```

4. Apply the Terraform configuration to create the ClickHouse setup:

```bash
terraform apply
```

This will deploy ClickHouse on the Minikube cluster.

### Step 2: Verify ClickHouse Deployment

Once the deployment is complete, verify that ClickHouse is running correctly on the Minikube cluster:

```bash
kubectl get all -n clickhouse
```

This command will list all the ClickHouse pods and resources in the `clickhouse` namespace.

---

### Step 3: Install Apache Superset using Helm

To install Apache Superset using Helm:

1. Install Superset by running the following command. It will create a namespace called `superset` and deploy Superset in that namespace.

```bash
helm install superset ./ -n superset --create-namespace -f values.yaml
```

2. Once the deployment is complete, verify the Superset deployment:

```bash
kubectl get all -n superset
```

This will list all the resources in the `superset` namespace.

---


### Step 4: Access the Superset Dashboard

To access the Superset UI in your web browser:

1. Use `kubectl port-forward` to forward the Superset service port to your local machine:

```bash
kubectl port-forward service/superset 8088:8088 --namespace superset
```

2. Open your web browser and navigate to:

```
http://localhost:8088
```


### Step 5: Login to Superset

Use the following default credentials to log in to the Superset UI:

- **Username**: `admin`
- **Password**: `admin`

Once logged in, you can proceed to connect Superset to ClickHouse.

---

### Step 6: Add ClickHouse as a Data Source in Superset

1. After logging in, go to **Sources** > **Databases** and click on **+ Database** to add a new database connection.

2. Choose **ClickHouse** from the list of available connectors.

3. Fill in the following connection details:

   - **Host**: Your Minikube host IP
   - **Port**: Your ClickHouse NodePort
   - **Database**: `default`
   - **Password**: Leave it blank (by default, ClickHouse has no password)

Here’s an example of the login details for ClickHouse:

![Login details to clickhouse](<screenshots/Login details to clickhouse.png>)

Once connected, you should see a success message:

![Login success](<screenshots/Clickhouse connected.png>)

---

### Step 7: Create a Table in Superset

1. Navigate to **SQL Lab** > **SQL Editor**.
2. Select **ClickHouse** as the data source.
3. Create a table using the following SQL command:

```sql
CREATE TABLE dz_test (B Int64, T String, D Date) 
ENGINE = MergeTree PARTITION BY D ORDER BY B;
```

Here’s a screenshot of the table creation:

![Create table](<screenshots/Create table Statement.png>)

---



### Step 8: Grant Permissions if Required

If you encounter an error related to DDL/DML commands not working, you may need to grant appropriate permissions to the ClickHouse user:

1. Go to the database connection settings in Superset.
2. Grant necessary permissions to the user to allow table creation and manipulation.

Here's how to allow permissions:

![Allow permissions](<screenshots/Allow table creation.png>)

---

### Step 9: Insert Data into the Table

Insert sample data into the newly created table using the following SQL command:

```sql
insert into dz_test 
select number, number, '2023-01-01' from numbers(1e4);
```

Here’s a screenshot of the insert statement:

![Inret statement](<screenshots/Insert Statement.png>)

---

### Step 10: Query Data in Superset

Once the data is inserted, you can query the table using:

```sql
select * from dz_test;
```

Here’s a screenshot of the select query:

![select command](<screenshots/Select Statement.png>)

