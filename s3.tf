Update workflow_call Input for vm_list
Change the vm_list input type from array to string:

yaml
Copy code
on:
  workflow_call:
    inputs:
      vm_list:
        type: string
        required: false
2. Parse the vm_list String into an Array
Add a step to parse the vm_list string into an array in the workflow. For example:

yaml
Copy code
- name: Parse VM List
  id: parse_vm_list
  run: |
    if [ -n "${{ inputs.vm_list }}" ]; then
      echo "VM_LIST=$(echo '${{ inputs.vm_list }}' | jq -c '.')" >> "$GITHUB_ENV"
    else
      echo "VM_LIST=[]" >> "$GITHUB_ENV"
    fi
  env:
    VM_LIST: '${{ inputs.vm_list }}'
This step ensures that the vm_list string (which might be a JSON-formatted array) is converted to a usable JSON array using jq.

3. Use the Parsed VM_LIST in Terraform
Pass the parsed VM_LIST to Terraform:

yaml
Copy code
env:
  TF_VAR_vm_list: '${{ env.VM_LIST }}'
Example of Providing vm_list as JSON
When calling the workflow, ensure vm_list is passed as a JSON-formatted string. For example:

yaml
Copy code
with:
  vm_list: '[{"vm_name": "VM1", "nic_name": "NIC1"}, {"vm_name": "VM2", "nic_name": "NIC2"}]'
Benefits
This workaround makes the vm_list input compatible with GitHub Actions by using a string type and parsing it into an array.
Allows you to continue working with structured data for your Terraform configuration.
Let me know if further clarification is needed!
