building account: could not acquire access token to parse claims: clientCredentialsToken: received HTTP status 401 with response: {"error":"invalid_client","error_description":"AADSTS7000215: Invalid client secret provided. Ensure the secret being sent in the request is the client secret value, not the client secret ID, for a secret added to app '***'. Trace ID: fbb7ed89-43df-4f91-af62-ccb0520f0e00 Correlation ID: c89c7789-3570-41ef-88fe-8619d3d2d984 Timestamp: 2025-03-10 20:12:22Z","error_codes":[7000215],"timestamp":"2025-03-10 20:12:22Z","trace_id":"fbb7ed89-43df-4f91-af62-ccb0520f0e00","correlation_id":"c89c7789-3570-41ef-88fe-8619d3d2d984","error_uri":"https://login.microsoftonline.com/error?code=7000215"}
34│
35│   with provider["registry.terraform.io/hashicorp/azurerm"],
36│   on main.tf line 9, in provider "azurerm":
37│    9: provider "azurerm" {
 
