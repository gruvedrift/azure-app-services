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


