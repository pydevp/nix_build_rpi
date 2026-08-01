{...}: {
  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets."ryan-password-hash".neededForUsers = true;
}
