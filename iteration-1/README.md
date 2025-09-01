## Iteration 1

This iteration focuses on basic web app creation and configuration.

1) Create an Azure App Service and Web App ✅
2) Deploy a simple web application that connects to a database ✅

These are the most essential fundamentals for creating and configuring Azure Web Apps with proper security settings.

### How to run
Simply run the `up.sh` script. It will provision everything needed in correct order.


### Step 2 ( testing ): Deploy a simple web application that connects to a database
For this to work, just provision necessary infrastructure: Resource Group, Service Plan and Web app. 
Simply zip the app.py and requirements.txt and run the following command: 
`az webapp deploy --resource-group tiny-flask-resource-group --name tiny-flask-web-app --src-path app.zip --type zip`

For this demonstration I chose to use a PostgresSql Flexible Server and Database. 
For connecting from local machine install the required software for python to connect to the Postgres server. 
`pip install psycopg2 `
If you are running a macOS, you might have to install the binary version instead: 
`pip install psycopg2-binary`

❗NOTE ❗: I have configured the Postgres Flexi Server to accept traffic from **ANY** source. Do NOT use this firewall rule in production, or if storing sensitive data!
Environment variables for database connection is passed through `app_settings` in Terraform, and read by the Python application.

```
# Create an App Service Plan (the compute resource that hosts your web apps) 

    az appservice plan create \
    --name tiny-flask-asp \
    --resource-group flask-webapp-resource-group \
    --sku B1 \
    --is-linux
    
# Create a web app within the App Service Plan
    az webapp create \
    --resource-group flask-webapp-resource-group \
    --plan tiny-flask-asp \
    --name tiny-flask-webapp \
    --runtime "python3" 
    
# Push a zipped archive file to Azure Web App.
   az webapp deploy \
   --resource-group tiny-flask-resource-group \
   --name tiny-flask-web-app \
   --src-path app.zip 
   --type zip

```

### What are the major differences between the service tiers (SKU's):

| Feature Category             | Free (F1)     | Shared (D1)   | Basic (B1/B2/B3)       | Standard (S1/S2/S3)    | Premium v3 (P1v3/P2v3/P3v3) | Isolated (I1/I2/I3)              |
|------------------------------|---------------|---------------|------------------------|------------------------|-----------------------------|----------------------------------|
| **Compute Type**             | Shared VM     | Shared VM     | Dedicated VM           | Dedicated VM           | Dedicated VM                | Dedicated VM in isolated network |
| **Custom Domains**           | ❌             | ✅ (5)         | ✅ (Unlimited)          | ✅ (Unlimited)          | ✅ (Unlimited)               | ✅ (Unlimited)                    |
| **SSL Certificates**         | ❌             | ❌             | SNI SSL only           | SNI & IP SSL           | SNI & IP SSL                | SNI & IP SSL                     |
| **Auto-Scale**               | ❌             | ❌             | ❌                      | ✅ (up to 10 instances) | ✅ (up to 30 instances)      | ✅ (up to 100 instances)          |
| **Deployment Slots**         | ❌             | ❌             | ❌                      | ✅ (5 slots)            | ✅ (20 slots)                | ✅ (20 slots)                     |
| **Daily Backups**            | ❌             | ❌             | ❌                      | ✅ (10/day)             | ✅ (50/day)                  | ✅ (50/day)                       |
| **WebJobs/Background Tasks** | ❌             | ❌             | ✅ (Always On required) | ✅                      | ✅                           | ✅                                |
| **VNet Integration**         | ❌             | ❌             | ❌                      | ❌                      | ✅                           | ✅ (with isolation)               |
| **Private Endpoints**        | ❌             | ❌             | ❌                      | ❌                      | ✅                           | ✅                                |
| **Hybrid Connections**       | ❌             | ❌             | ❌                      | ✅ (5)                  | ✅ (25)                      | ✅ (Unlimited)                    |
| **Traffic Manager**          | ❌             | ❌             | ✅                      | ✅                      | ✅                           | ✅                                |
| **SLA**                      | None          | None          | 99.95%                 | 99.95%                 | 99.95%                      | 99.95%                           |
| **Disk Space**               | 1 GB          | 1 GB          | 10 GB                  | 50 GB                  | 250 GB                      | 1 TB                             |
| **CPU Minutes/Day**          | 60            | 240           | Unlimited              | Unlimited              | Unlimited                   | Unlimited                        |
| **Memory**                   | 1 GB (shared) | 1 GB (shared) | 1.75-7 GB              | 1.75-7 GB              | 3.5-14 GB                   | 3.5-14 GB                        |

The jump from **Basic** to **Standard** is significant because it unlocks deployment slots. This is where App Services start to rival sophisticated deployment patterns achieved in my
**azure-containerized-solutions** repository. 


### How to create database 
1) Need resource group 
2) Need a SQL database to run on `azurerm_postgresql_server`
   3) Use SQL login
3) Now set up a database table with `azurerm_postgresql_database`
4) 