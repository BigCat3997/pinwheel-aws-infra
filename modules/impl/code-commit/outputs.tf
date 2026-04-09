output "repository_ids" {
  value = {
    for name, repository in module.local_code_commit : name => repository.id
  }
}

output "clone_url_https" {
  value = {
    for name, repository in module.local_code_commit : name => repository.clone_url_http
  }
}

output "clone_url_sshs" {
  value = {
    for name, repository in module.local_code_commit : name => repository.clone_url_ssh
  }
}

