workflow "Terraform" {
  resolves = "terraform-plan"
  on = "push"
}

action "terraform-fmt" {
  uses = "hashicorp/terraform-github-actions/fmt@v0.1.1"
  secrets = ["GITHUB_TOKEN"]
  env = {
    TF_ACTION_WORKING_DIR = "./terraform/example1"
  }
}

action "terraform-init" {
  uses = "hashicorp/terraform-github-actions/init@v0.1.1"
  needs = "terraform-fmt"
  secrets = ["GITHUB_TOKEN"]
  env = {
    TF_ACTION_WORKING_DIR = "./terraform/example1"
  }
}

action "terraform-validate" {
  uses = "hashicorp/terraform-github-actions/validate@v0.1.1"
  needs = "terraform-init"
  secrets = ["GITHUB_TOKEN"]
  env = {
    TF_ACTION_WORKING_DIR = "./terraform/example1"
  }
}

action "terraform-plan" {
  uses = "hashicorp/terraform-github-actions/plan@v0.1.1"
  needs = "terraform-validate"
  secrets = ["GITHUB_TOKEN"]
  env = {
    TF_ACTION_WORKING_DIR = "./terraform/example1"

    # If you're using Terraform workspaces, set this to the workspace name.
    # TF_ACTION_WORKSPACE = "default"
  }
}
