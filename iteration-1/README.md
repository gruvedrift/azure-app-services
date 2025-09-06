## Iteration 1

This iteration focuses on basic web app creation and configuration.

1) Create an Azure App Service and Web App ✅
2) Deploy a simple web application that connects to a database ✅
3) Configure application settings and connection strings securely ✅ 
4) Enable HTTPS and configure custom domain with TLS certificate ✅ 
5) Set up API settings for external service integration ✅ 

These are the most essential fundamentals for creating and configuring Azure Web Apps with proper security settings.

### How to run
Simply run the `up.sh` script. It will provision everything needed in correct order.
Unfortunately zipping and uploading the application code through the azure CLI is a bit janky and might time out with the following message: 
```
An error occurred during deployment. Status Code: 502,  Please visit https://tiny-flask-web-app.scm.azurewebsites.net/api/deployments/latest to get more information about your deployment
```
Fret not❗ Simply navigate to the `/src` directory and upload it again with the following command: 

```bash
az webapp deploy --resource-group tiny-flask-resource-group --name tiny-flask-web-app --src-path app.zip --type zip
```

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
Basic tier is the minimum for dedicated compute but lacks enterprise features like deployment slots, while Standard tier is where production-ready capabilities begin.


### Securely storing connection string to database 
In this iteration I have chosen to use an Azure Keyvault for securely storing the connection string for my postgres database.
For granting access to the keyvault I have chosen to use `Access Policies`. This is fine for this demonstration, but I am aware that `RBAC` is the preferred choice, and indeed in the future,
the only supported option.

In my Terraform file I have for my web app created an identity block. 
```terraform
identity {
    type = "SystemAssigned" 
  }
```
This effectively create a `Service Principal` for my web application. 
I can later grant access to whatever Access Policies I chose, through that *principal id*.
I chose to do a hybrid approach where some of the database connection properties are still injected as environment variables. 
However, the database password, which is auto generated, is very sensitive and is therefore stored in the keyvault.

The application uses the **DefaultAzureCredential** and **SecretClient** modules provided by Azure in order to authenticate and read the secret. 

### HTTPS and TLS
#### Browser -> Azure App Service
When using azures `*.azurewebsites.net` domains, Azure already issues and manages a TLS certificate. The certificate is already signed by a public
Certificate Authority (**CA**) that all browsers trust. If one would opt for a custom domain one would have to: 
1) Upload a TLS certificate, which can be bought through DigiCert etc. or 
2) Use Azure's **App Service Managed Certificate**

#### Azure Database 
The Postgres Flexi server is configured by Azure to enforce SSL/TLS connections. It uses a server side certificate issued by Microsoft's internal 
CA for Azure DB service. Clients, like `psycopg2` verify the certificate by setting `sslmode=require` in the connection properties. 

#### Azure Keyvault
Keyvault endpoints are protected by Azure's HTTPS infrastructure. Again, the TLS certificate is issued by a trusted public CA, just like with the web application.
The SDKs, like `azure-identity` which is used in this project, automatically validates the certificate using the underlying systems trusted CA bundle.

### CORS  ( Setting up API settings for external service integration)
CORS, or Cross-Origin Resource Sharing, is a browser security mechanism. When enabling CORS on the Linux Web App, it packs headers on the response.
If the receiving browser does not see the correct CORS headers, the response is blocked.
To run the provided `dune-quote-consumer.html` file, simply run: 
```bash
python3 -m http.server 3000
```
and visit : `http://localhost:3000/dune-quote-consumer.html`
If CORS are not enabled on server, one would se an error like this in the browser when attempting a fetch:  
```
Access to fetch at 'https://tiny-flask-web-app.azurewebsites.net/dune-quotes' from origin 'http://localhost:3000'
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
```