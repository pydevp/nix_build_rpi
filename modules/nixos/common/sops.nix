{...}: {
  flake.modules.nixos.common-sops = {...}: {
    # Decrypt secrets using the host's own SSH host key instead of managing
    # a separate age key on disk - sops-nix converts it to an age identity
    # at activation time.
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };
}
