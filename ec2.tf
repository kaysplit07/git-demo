name: 'Terraform Load Balancer Deployment'

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Choose environment'
        required: true
        type: choice
        options:
          - dev
          - staging
          - prod

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      # Step to copy the correct backend config file to main.tf
      - name: Set up Terraform backend for environment
        run: |
          case "${{ inputs.environment }}" in
            dev) cp backend-dev.tf main.tf ;;
            staging) cp backend-staging.tf main.tf ;;
            prod) cp backend-prod.tf main.tf ;;
          esac

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -var="environment=${{ inputs.environment }}"

      - name: Terraform Apply
        if: ${{ github.event.inputs.requestType == 'apply' }}
        run: terraform apply -auto-approve -var="environment=${{ inputs.environment }}"
