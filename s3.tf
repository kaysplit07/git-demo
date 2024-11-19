name: 'Deploy Load Balancer'
run-name: 'Load Balancer - ${{ inputs.environment }} Purpose: ${{ inputs.purpose }} : ${{ inputs.requesttype }}'
on:
  workflow_dispatch:
    inputs:
      requesttype:
        type: choice
        required: true
        description: Request Type
        options:
          - Create (with New RG)
          - Create (with Existing RG)
          - Remove
        default: "Create (with New RG)"
      environment:
        type: choice
        required: true
        description: Environment
        options:
          - DEV
          - UAT
          - QA
          - PROD
      location:
        type: choice
        required: true
        description: Deployment Location
        options:
          - Select the location
          - eastus2
          - uksouth
          - centralus
          - ukwest
      sku_name:
        type: choice
        required: false
        description: SKU for Load Balancer
        options:
          - Standard
          - Basic
        default: "Standard"
      purpose:
        type: string
        required: true
        description: Purpose of the Load Balancer
      RGname:
        type: string
        required: false
      purposeRG:
        type: string
        required: true
        description: Resource Group Purpose (hyphen designates an existing RG)
      subnetname:
        type: string
        required: true
        description: Subnet name for Load Balancer
      private_ip_address:
        type: string
        required: false
        description: Private IP address for Load Balancer frontend configuration
      vm_list:
        type: string
        required: false
        description: "List of VMs for NIC IP configuration (as JSON)"
jobs:
  resource_group:
    if: ${{ inputs.requesttype == 'Create (with New RG)' }}
    name: 'Resource Group ${{ inputs.purposeRG }}'
    uses: ./.github/workflows/CreateResourceGroup.yml
    secrets: inherit
    with:
      name: 'resource-group'
      subscription: 'Subscription Input'
      environment: '${{ inputs.environment }}'
      location: '${{ inputs.location }}'
      purpose: '${{ inputs.purposeRG }}'

  load_balancer:
    if: ${{ inputs.requesttype != 'Remove' }}
    name: 'Load Balancer ${{ inputs.purpose }}'
    uses: ./.github/workflows/LBCreate.yml
    needs: resource_group
    secrets: inherit
    with:
      requesttype: '${{ inputs.requesttype }}'
      environment: '${{ inputs.environment }}'
      location: '${{ inputs.location }}'
      sku_name: '${{ inputs.sku_name }}'
      purpose: '${{ inputs.purpose }}'
      RGname: '${{ inputs.RGname }}'
      purposeRG: '${{ inputs.purposeRG }}'
      subnetname: '${{ inputs.subnetname }}'
      private_ip_address: '${{ inputs.private_ip_address }}'
      vm_list: >
        [{"vm_name": "VM1", "nic_name": "NIC1"}, {"vm_name": "VM2", "nic_name": "NIC2"}]

  load_balancer_remove:
    if: ${{ inputs.requesttype == 'Remove' }}
    name: 'Remove Load Balancer ${{ inputs.purpose }}'
    uses: ./.github/workflows/LBCreate.yml
    secrets: inherit
    with:
      requesttype: '${{ inputs.requesttype }}'
      environment: '${{ inputs.environment }}'
      location: '${{ inputs.location }}'
      sku_name: '${{ inputs.sku_name }}'
      purpose: '${{ inputs.purpose }}'
      RGname: '${{ inputs.RGname }}'
      purposeRG: '${{ inputs.purposeRG }}'
      subnetname: '${{ inputs.subnetname }}'
      private_ip_address: '${{ inputs.private_ip_address }}'
      vm_list: >
        [{"vm_name": "VM1", "nic_name": "NIC1"}, {"vm_name": "VM2", "nic_name": "NIC2"}]
