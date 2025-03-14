ContentAux Integration 


Source 

https://github.wdf.sap.corp/Ariba-Catalog-Service/contentaux 


Deployment Docs 

https://pages.github.tools.sap/Ariba-infra/docs/applications/buyer_service/contentAuxDeployment/ 


Integration Doc 

https://wiki.ariba.com/pages/viewpage.action?pageId=277285865 


Jenkins Deploy 

https://34.136.36.143/job/Tools/job/AppDeploy/916/execution/node/3/ws/workarea/ariba-catalog-service/v-372fde1-18/service/src/main/resources/ 

Login to SAP side and navigate to cobalt GitHub repo and check the k8s config file for NS2PreProd env. 

https://github.wdf.sap.corp/ariba-cobalt-cs/k8sconfigs/tree/master/buyer/sspns2preprod 

Validate ContentAux incoming server URL and FedRamp internal URL are set correctly as follows respectively: 

https://procurement.ariba.preprod.sapns2.us/content-aux 

http://contentaux-content-aux.family-contentaux.svc:9020 

Validate the app and front door URLs in the deployed resources (Jenkins -> AppDeploy). Below is the execution checked for the currently deployed version. 

https://34.136.36.143/job/Tools/job/AppDeploy/916/execution/node/3/ws/workarea/ariba-catalog-service/v-372fde1-18/service/src/main/resources/ 

app: url: https://procurement.ariba.preprod.sapns2.us/Buyer 

frontDoorUrl: buyer: "https://procurement.ariba.preprod.sapns2.us" 
