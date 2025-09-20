## Iteration 2 



1. Enable Application Insights integration
2. Configure application logging levels and destinations
3. Implement custom telemetry and performance counters
4. Set up automated alerts for errors and performance degradation
5. Create dashboards for monitoring application health
6. Practice troubleshooting using logs and metrics

### This iteration is mostly about App Insights and logging. 


## Application Insights
App Insights is a feature of **Azure Monitor** that helps monitor, diagnose and understand an application's behaviour. 
It is like a "black box recorder" for an application that collects telemetry ( requests, errors, performance or custom events ) 
Typical telemetry are:
- **Request tracking:** Response times, status codes and failure rates
- **Error tracking:** Exceptions like DB connection errors, Python 
- **Dependency tracking:** Outgoing calls (SQL, Key Vault, APIs)
- **Performance metrics:** CPU, Memory usage, request rates.
- **Custom telemetry:** Create custom events to track, like when someone hits some special endpoint.
- **Dashboard and alerts:** Visualize trends with **Azure Monitor** and **Power BI**. Get notified on errors, slow response times, or spikes in traffic. 

For this iteration I have decided to create a stripped-down stack in order to focus on the learning objective at hand:

*Implement comprehensive monitoring, logging, and diagnostics for applications.*

### Iteration 2 
Due to immense deployment overhead and deployment delay, I have chosen to move away from zip deployments and back to docker images. 
NOTE: When you provision an Azure Application Insights, Azure will automatically create a Managed Log Analytics Workspace ( unless you create on yourself )

### 1. Enable Application Insights integration

Since we are using a custom container for our Flask application, we need to include the Application Insights SDK in our Docker image.
The modern approach to monitoring and reporting telemetry is the `azure-monitor-opentelemetry` package. It handles all the configuration, automatically tracks 
all HTTP requests, response times, and exceptions without having to explicitly add logging statements manually. 
I have also chosen to use the `opentelemetry-instrumentation-flask` library, which extends the Open Telemetry middleware for tracking web requests in Flask applications.

More information on the [Open Telemetry SKD / API](https://opentelemetry.io/)

What is needed: 
1) Application Insights resource in Azure 
2) Connection string in the applications environment variables, or other way of obtaining it. 
3) An application which runs and serves requests ( duh )
4) SDK for telemetry collection and sending.


Now it is possible to see and query for every event that happens within the application. Everything is captured, but you have 
to know what to query for when trying to retrieve useful and valuable information. 
### TODO add more info about what we can observe in Application Insights and in the log analytics workspace. 

### 2. Configure application logging levels and destinations 
Telemetry data is great for understanding application behavior at a high level. 
However, application logging is about capturing specific events and debug information that you explicitly want to track.

