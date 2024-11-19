The error on line 129 in your workflow likely stems from an extra single quote (') in the Terraform Apply step under TF_VAR_vm_list.

Here’s the problematic line:

yaml
Copy code
TF_VAR_vm_list:             '${{ env.VM_LIST }}''
Notice the extra single quote ('') at the end of the value.

Fix:
Remove the extra single quote from TF_VAR_vm_list. Here's the corrected snippet:

yaml
Copy code
- name: 'Terraform Apply - Load Balancer'
  if: ${{ inputs.vm_list && inputs.requestType == 'Create (with New RG)' }} ||  ${{ inputs.vm_list && inputs.requestType == 'Create (with Existing RG)' }}
  run: terraform apply -auto-approve
  env:
    TF_VAR_requesttype:         '${{inputs.requestType}}'
    TF_VAR_location:            '${{inputs.location}}'
    TF_VAR_environment:         '${{inputs.environment}}'
    TF_VAR_purpose:             '${{inputs.purpose}}'
    TF_VAR_purpose_rg:          '${{inputs.purposeRG}}'
    TF_VAR_RGname:              '${{inputs.RGname}}'
    TF_VAR_subnetname:          '${{inputs.subnetname}}'
    TF_VAR_sku_name:            '${{inputs.sku_name}}'
    TF_VAR_private_ip_address:  '${{inputs.private_ip_address}}'
    TF_VAR_vm_list:             '${{ env.VM_LIST }}'
Additional Recommendations:
YAML Linting: Use a YAML linter to catch such errors early. Tools like YAML Lint can validate your syntax.
Environment Variable Debugging: Add a debugging step to verify the contents of VM_LIST:
yaml
Copy code
- name: Debug VM List
  run: echo "VM_LIST=$VM_LIST"
Let me know if you encounter any further issues!












