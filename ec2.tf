name: 'Load Balancer Deployment'
run-name: '${{github.actor}} - Deploy Load Balancer'

on:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        description: 'Environment to deploy to'
        required: true
        options:
          - dev
          - staging
          - prod

jobs:
  deploy-lb:
    name: Deploy Load Balancer
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Select backend file based on environment
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
        if: ${{ inputs.requestType == 'Create' }}
        run: terraform apply -auto-approve -var="environment=${{ inputs.environment }}"
