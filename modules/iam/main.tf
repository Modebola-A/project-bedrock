# Create the bedrock-dev-view IAM user
resource "aws_iam_user" "dev_view" {
  name = "bedrock-dev-view"
  path = "/"

  tags = {
    Name = "bedrock-dev-view"
  }
}

# Console login profile (password for AWS Console access)
resource "aws_iam_user_login_profile" "dev_view" {
  user                    = aws_iam_user.dev_view.name
  password_reset_required = false
  password_length         = 16
}

# Access keys (for CLI/programmatic access - grader uses these to upload to S3)
resource "aws_iam_access_key" "dev_view" {
  user = aws_iam_user.dev_view.name
}

# Attach AWS managed ReadOnlyAccess policy (for Console access)
resource "aws_iam_user_policy_attachment" "dev_view_readonly" {
  user       = aws_iam_user.dev_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Kubernetes RBAC binding - maps IAM user to k8s view ClusterRole
# This is done via aws-auth ConfigMap in the EKS module
# The actual ClusterRoleBinding is created in the k8s manifests

# Store dev user credentials in Secrets Manager for safe retrieval
resource "aws_secretsmanager_secret" "dev_credentials" {
  name                    = "${var.cluster_name}/dev-user/credentials"
  description             = "bedrock-dev-view IAM user credentials"
  recovery_window_in_days = 0

  tags = {
    Name = "bedrock-dev-view-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "dev_credentials" {
  secret_id = aws_secretsmanager_secret.dev_credentials.id
  secret_string = jsonencode({
    username          = aws_iam_user.dev_view.name
    access_key_id     = aws_iam_access_key.dev_view.id
    secret_access_key = aws_iam_access_key.dev_view.secret
    console_password  = aws_iam_user_login_profile.dev_view.password
    console_url       = "https://${var.account_id}.signin.aws.amazon.com/console"
  })
}

# aws-auth ConfigMap update to give the IAM user EKS access
resource "aws_eks_access_entry" "dev_view" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_user.dev_view.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "dev_view" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_user.dev_view.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["retail-app"]
  }

  depends_on = [aws_eks_access_entry.dev_view]
}
