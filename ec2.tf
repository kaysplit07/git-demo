name: '- Deploy Windows VM'
run-name: 'Windows VM - ${{ inputs.environment }} purpose: ${{ inputs.purpose }} : ${{ inputs.requesttype }}'
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
        - Update (Data Disk)
        - Update (OS Disk)
        - Remove (Not Available - upcoming functionality)
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
      vmsize:
        type: string
        required: true
        default: "Standard_D2s_v3"
        description: VM Size (SKU Designation)
      purpose:
        type: string
        required: true
        description: Role/Sequence for VM (RRRR/SSS). Hyphen designate an existing VM
      purposeRG:
        type: string
        required: true
        description: Resource Group Purpose.......... Hyphen designate an existing RG
      projectou:
        type: string
        required: true
        description: Ignored on Update............. Organizational Unit (OU) for Domain Join.
      subnetInfo:
        type: string
        required: false
        description: Combined subnet details in JSON format
        default: '{"subnetNameWVM": "", "subnetNameWVM2": ""}'
      diskSizeGB:
        type: string
        required: false
        description: Disk Size in GB................. Data Disk on Create............. Update specifies Data or OS Disk. On Update use "Same" retain size.
        default: "32"
      diskStorageAccountType:
        type: choice
        required: false
        description: Disk Storage Account Type....... Data Disk on Create............. Update specifies Data or OS Disk. Blank on Update to retain size.
        options:
        - Standard_LRS
        - StandardSSD_LRS
        - StandardSSD_ZRS
        - Premium_LRS
        - Premium_ZRS
        - " "
jobs:
  parse_inputs:
    runs-on: ubuntu-latest
    steps:
    - name: Parse Subnet Information
      id: parse_subnet
      run: |
        subnetNameWVM=$(jq -r '.subnetNameWVM' <<< '${{ inputs.subnetInfo }}')
        subnetNameWVM2=$(jq -r '.subnetNameWVM2' <<< '${{ inputs.subnetInfo }}')
        echo "::set-output name=subnetNameWVM::${subnetNameWVM}"
        echo "::set-output name=subnetNameWVM2::${subnetNameWVM2}"

  resource_group:
    if: ${{ github.event.inputs.requesttype == 'Create (with New RG)' }}
    needs: parse_inputs
    name: 'Resource Group ${{ inputs.purposeRG }}'
    uses: ./.github/workflows/CreateResourceGroup.yml
    secrets:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    with:
      name: 'resource-group'
      subscription: 'SNow Input'
      environment: '${{ inputs.environment }}'
      location: '${{ inputs.location }}'
      purpose: '${{ inputs.purposeRG }}'

  windows_vm_new_rg:
    if: ${{ github.event.inputs.requesttype == 'Create (with New RG)' }}
    needs: [parse_inputs, resource_group]
    name: 'Windows VM ${{ inputs.purpose }}'
    uses: ./.github/workflows/zWindowsVMCall.yml
    secrets:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    with:
      requestType: '${{ inputs.requesttype }}'
      environment: '${{ inputs.environment }}'
      location: '${{ inputs.location }}'
      vmsize: '${{ inputs.vmsize }}'
      purpose: '${{ inputs.purpose }}'
      purposeRG: '${{ inputs.purposeRG }}'
      projectou: '${{ inputs.projectou }}'
      subnetNameWVM: '${{ needs.parse_inputs.outputs.subnetNameWVM }}'
      subnetNameWVM2: '${{ needs.parse_inputs.outputs.subnetNameWVM2 }}'
      diskSizeGB: '${{ inputs.diskSizeGB }}'
      diskStorageAccountType: '${{ inputs.diskStorageAccountType }}'

  windows_vm_existing_rg:
    if: ${{ github.event.inputs.requesttype == 'Create (with Existing RG)' }}
    needs: parse_inputs
    name: 'Windows VM ${{ inputs.purpose }}'
    uses: ./.github/workflows/zWindowsVMCall.yml
    secrets:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    with:
      requestType: '${{ inputs.requesttype }}'
      environment: '${{ inputs.environment }}'
      location: '${{ inputs.location }}'
      vmsize: '${{ inputs.vmsize }}'
      purpose: '${{ inputs.purpose }}'
      purposeRG: '${{ inputs.purposeRG }}'
      projectou: '${{ inputs.projectou }}'
      subnetNameWVM: '${{ needs.parse_inputs.outputs.subnetNameWVM }}'
      subnetNameWVM2: '${{ needs.parse_inputs.outputs.subnetNameWVM2 }}'
      diskSizeGB: '${{ inputs.diskSizeGB }}'
      diskStorageAccountType: '${{ inputs.diskStorageAccountType }}'

  windows_vm_maintain:
    if: ${{ github.event.inputs.requesttype == 'Update (Data Disk)' || github.event.inputs.requesttype == 'Update (OS Disk)' }}
    needs: parse_inputs
    name: 'Maintain Windows VM ${{ inputs.purpose }}'
    uses: ./.github/workflows/zWindowsVMCall.yml
    secrets:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    with:
      requestType: '${{ inputs.requesttype }}'
      environment: '${{ inputs.environment }}'
      location: '${{ inputs.location }}'
      vmsize: '${{ inputs.vmsize }}'
      purpose: '${{ inputs.purpose }}'
      purposeRG: '${{ inputs.purposeRG }}'
      diskSizeGB: '${{ inputs.diskSizeGB }}'
      diskStorageAccountType: '${{ inputs.diskStorageAccountType }}'
