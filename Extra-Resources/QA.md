## Exam relevant questions for Azure App Services

> **Question 1:** Which App Service Plan SKUs support deployment slots?  
> **Answer 1:** Standard, Premium, Premium v2, Premium v3, and Isolated SKUs support deployment slots. Free,
> Shared, and Basic SKUs do not support this feature.
---
> **Question 2:** What happens during a deployment slot swap operation?  
> **Answer 2:** Azure applies production slot settings to the staging slot, warms up all instances with the new
> configuration, then atomically redirects production traffic to the staging slot. The former production slot becomes
> the  new staging slot. Slot-specific settings remain  with their respective slots.
---
> **Question 3:** Your web application experiences predictable traffic spikes every weekday at 9 AM. How should you configure scaling?  
> **Answer 3:** Use schedule auto-scaling to proactively scale out before the traffic spike, combined with metric-based scaling for unexpected load variations.
> This prevents performance degradation during predicable high-traffic periods.
---
> **Question 4:** You need to ensure scripts run before a slot swap completes. Which solution works?  
> **Answer 4:** Update the web.config file to include the `applicationInitialization` configuration element with custom initialization actions. 
> This ensures your application is properly warmed up before traffic is directed to it.
---
> **Question 5:** What's the difference between scale up and scale out in App Service?  
> **Answer 5** Scale up changes the SKU to get more CPU,  memory, and features on the same instances.
> Scale out increases the number of instances running your app. Scale up affects capacity per instance; scale out affects total capacity.
---
> **Question 6:** You have four customers, each needing a singleton WebJob instance. Which App Service Plan configuration minimizes costs?  
> **Answer 6:** Use Isolated SKU with 4 instances. Isolated provides network isolation required for the scenario, 
>  and each WebJob instance can run on a separate VM instance to maintain singleton behavior.
---
> **Question 7:** How do you configure automatic slot swaps?  
> **Answer 7:** Enable auto swap on the source slot (typically staging), then set the target slot (typically production). 
> After each deployment to the source slot, Azure automatically swaps it to the target slot after warming up.
---
> **Question 8:** What's the maximum number of deployment slots available in Standard SKU?  
> **Answer 8:** Standard SKU supports up to 5 deployment slots (including production). Premium  SKUs support up to 20 slots.
---
> **Question 9:** You need to route 10% of traffic to a staging slot for testing. How do you configure this?  
> **Answer 9:** Use traffic routing in deployment slots. Set the staging slot routing rule to 10% in the Azure portal 
> or use `az webapp traffic-routing set --distribution staging=10`.
---
> **Question 10:** Which configuration elements follow content during slot swaps?  
> **Answer 10:** General settings, application settings (unless marked as slot-specific), connection strings (unless marked as slot-specific),
> handler mappings, and publicly available certificates. Slot-specific settings stay with their respective slots.
---
> **Question 11:** You need to enable HTTPS for a custom domain. What steps are required? 
> **Answer 11:** Add the custom domain to your App Service, then upload an SSL certificate or use a free App Service managed certificate. 
> Bind the certificate to the domain and configure HTTPS-only redirection if needed.
---
> **Question 12:** How do you configure App Service to scale based on HTTP queue length?  
> **Answer 12:** Create an autoscale rule with HTTP queue length metric. Set the threshold (e.g., > 100 queued requests) 
> and the scale action (add X instances). This provides more responsive scaling than CPU-based scaling.
---
> **Question 13:** Your app needs access to an on-premises database. Which networking feature should you use?  
> **Answer 13:** Hybrid  Connections. This allows your App Service to securely  connect to on-premises resources without requiring VPN 
> configuration or changes to your on-premises network infrastructure.
---
> **Question 14:** What happens if you delete an App Service Plan that has multiple web apps?  
> **Answer 14:** You cannot delete an App Service  Plan that contains web apps. You must first move or delete all web apps in the plan before you can delete the plan itself.
---
> **Question 15:** How do you configure continuous deployment from a private Git repository?  
> **Answer 15:** Set up deployment credentials in the Deployment Center, configure the Git repository URL with authentication,
> and enable continuous deployment. For private repos, use access tokens or SSH keys for authentication.
---
> **Question 16:** You need to run background tasks in your web app. What options are available?  
> **Answer 16:** WebJobs (continuous or triggered), Azure Functions (if tasks can be serverless), or background services within your application code. 
> WebJobs run in the same App Service Plan as your web app.
---
> **Question 17:** How do you implement IP restrictions for your App Service?  
> **Answer 17:** Configure access restrictions in the Networking section. You can allow/deny traffic based on IP addresses, IP ranges,
> virtual networks, or service tags. Rules are evaluated in priority order.
---
> **Question 18:** What's the difference between application settings and connection strings in App Service?  
> **Answer 18:** Application settings become environment variables accessible to your app.  
> Connection strings receive special handling for database connectivity, including framework-specific formatting and encryption at rest.
---
> **Question 19:** You need to diagnose why your web app is slow. Which diagnostic tools should you use?  
> **Answer 19:** Enable Application Insights for application performance monitoring, use App Service diagnostics and solve problems, 
> enable diagnostic logging, and use the Kudu console for advanced troubleshooting.
---
> **Question 20:** How do you configure a staging slot to use a different database than production?  
> **Answer 20:** Mark the database connection string as a "slot setting" / "sticky" so it doesn't swap with content.
> Configure different connection strings for production and staging slots that point to their respective databases.
---