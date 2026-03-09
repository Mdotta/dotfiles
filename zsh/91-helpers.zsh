

reload_ssh(){
  eval "$(ssh-agent -s)"
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519_gitlab
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github
}