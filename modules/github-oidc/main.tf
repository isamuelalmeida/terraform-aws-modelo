data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

  tags = merge(
    var.tags,
    {
      Name = "${var.env}-${var.name}-github-oidc"
    }
  )
}

data "aws_iam_policy_document" "github_assume_role" {
  for_each = var.github_repositories

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = each.value.subjects
    }
  }
}

resource "aws_iam_role" "github" {
  for_each = var.github_repositories

  name               = "${var.env}-${var.name}-github-oidc-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role[each.key].json
  max_session_duration = each.value.max_session_duration

  tags = merge(
    var.tags,
    {
      Name       = "${var.env}-${var.name}-github-${each.key}"
      Repository = each.key
    }
  )
}

resource "aws_iam_role_policy_attachment" "github_managed" {
  for_each = {
    for item in flatten([
      for repo_key, repo in var.github_repositories : [
        for policy in repo.managed_policy_arns : {
          key        = "${repo_key}-${policy}"
          role       = repo_key
          policy_arn = policy
        }
      ]
    ]) : item.key => item
  }

  role       = aws_iam_role.github[each.value.role].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_policy" "github_inline" {
  for_each = {
    for repo_key, repo in var.github_repositories :
    repo_key => repo
    if repo.inline_policy_json != null
  }

  name   = "${var.env}-${var.name}-github-${each.key}-policy"
  policy = each.value.inline_policy_json

  tags = merge(
    var.tags,
    {
      Name       = "${var.env}-${var.name}-github-${each.key}-policy"
      Repository = each.key
    }
  )
}

resource "aws_iam_role_policy_attachment" "github_inline" {
  for_each = {
    for repo_key, repo in var.github_repositories :
    repo_key => repo
    if repo.inline_policy_json != null
  }

  role       = aws_iam_role.github[each.key].name
  policy_arn = aws_iam_policy.github_inline[each.key].arn
}
