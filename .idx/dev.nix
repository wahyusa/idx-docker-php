{ pkgs, ... }: {
  channel = "stable-24.05";

  # 1) Docker CLI & Compose
  packages = [
    pkgs.docker            # Docker Engine client
    pkgs.docker-compose    # Docker Compose v1
  ];

  # 2) Enable the Docker daemon
  services.docker.enable = true;
}
