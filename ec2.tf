name: 'NIC Association to LB'
run-name: 'NIC Association - ${{ inputs.environment }} purpose: ${{ inputs.purpose }} : ${{ inputs.requesttype }}'

on:
  workflow_dispatch:
    inputs:
      requesttype:
        type: choice
        required: true
        description: Request Type
        options:
          - NIC Association to LB
          - Remove NIC from LB
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
          - eastus2
          - uksouth
          - centralus
          - ukwest
      purpose:
        type: string
        required: true
        description: Purpose of the NIC
      purposeRG:
        type: string
        required: false
        default: "sgs"
        description: Resource Group Purpose
      nic_resource_group:
        type: string
        required: false
        description: Resource group name for NIC
      nic_names:
        type: string
        required: true
        description: "Comma-separated list of NIC names"
        default: "nic1,nic2,nic3"
      lb_name:
        type: string
        required: true
        description: "Load Balancer Name to Attach the NIC"
        default: "lb1"

jobs:
  NICAssociation:
    if: github.event.inputs.requesttype == 'NIC Association to LB'
    name: 'NIC to LB ${{ inputs.purpose }}'
    uses: ./.github/workflows/NICAssociation.yml
    secrets: inherit
    with:
      requesttype:                 '${{ inputs.requesttype }}'
      environment:                 '${{ inputs.environment }}'
      location:                    '${{ inputs.location }}'
      purpose:                     '${{ inputs.purpose }}'
      purposeRG:                   '${{ inputs.purposeRG }}'
      nic_resource_group:          '${{ inputs.nic_resource_group }}'
      nic_names:                   '${{ inputs.nic_names }}'
      lb_name:                     '${{ inputs.lb_name }}'

  RemoveNICAssociation:
    if: github.event.inputs.requesttype == 'Remove NIC from LB'
    name: 'Remove NIC from LB ${{ inputs.purpose }}'
    uses: ./.github/workflows/NICAssociation.yml
    secrets: inherit
    with:
      requesttype:                 '${{ inputs.requesttype }}'
      environment:                 '${{ inputs.environment }}'
      location:                    '${{ inputs.location }}'
      purpose:                     '${{ inputs.purpose }}'
      purposeRG:                   '${{ inputs.purposeRG }}'
      nic_resource_group:          '${{ inputs.nic_resource_group }}'
      nic_names:                   '${{ inputs.nic_names }}'
      lb_name:                     '${{ inputs.lb_name }}'
