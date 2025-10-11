## Enhanced Docker Section

Replace the existing Docker shortcuts section with this expanded version:

```bash
# Docker shortcuts and enhancements (if docker is available).
if command -v docker &>/dev/null; then
    # --- Basic Docker Aliases ---
    alias d='docker'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias dpsq='docker ps -q'
    alias di='docker images'
    alias dv='docker volume ls'
    alias dn='docker network ls'
    alias dex='docker exec -it'
    alias dlog='docker logs -f'
    alias dins='docker inspect'
    alias drm='docker rm'
    alias drmi='docker rmi'
    alias dpull='docker pull'
    
    # --- Docker Compose v2 Aliases ---
    alias dc='docker compose'
    alias dcu='docker compose up -d'
    alias dcup='docker compose up'
    alias dcd='docker compose down'
    alias dcr='docker compose restart'
    alias dcl='docker compose logs -f'
    alias dcp='docker compose ps'
    alias dcpull='docker compose pull'
    alias dcb='docker compose build'
    alias dcbn='docker compose build --no-cache'
    alias dce='docker compose exec'
    alias dcstop='docker compose stop'
    alias dcstart='docker compose start'
    
    # --- Docker System Management ---
    alias dprune='docker system prune -f'
    alias dprunea='docker system prune -af'
    alias ddf='docker system df'
    alias dvprune='docker volume prune -f'
    alias diprune='docker image prune -af'
    
    # --- Docker Info Aliases ---
    alias dstats='docker stats --no-stream'
    alias dstatsa='docker stats'
    alias dtop='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"'
    
    # --- Docker Functions ---
    
    # Stop all running containers
    dstopall() {
        local containers=$(docker ps -q)
        if [ -n "$containers" ]; then
            docker stop $containers
            echo "Stopped all running containers"
        else
            echo "No running containers to stop"
        fi
    }
    
    # Remove all stopped containers
    drmall() {
        local containers=$(docker ps -aq -f status=exited)
        if [ -n "$containers" ]; then
            docker rm $containers
            echo "Removed all stopped containers"
        else
            echo "No stopped containers to remove"
        fi
    }
    
    # Enter container shell (bash or sh fallback)
    dsh() {
        if [ -z "$1" ]; then
            echo "Usage: dsh <container-name-or-id>"
            return 1
        fi
        docker exec -it "$1" bash 2>/dev/null || docker exec -it "$1" sh
    }
    
    # Docker Compose enter shell (bash or sh fallback)
    dcsh() {
        if [ -z "$1" ]; then
            echo "Usage: dcsh <service-name>"
            return 1
        fi
        docker compose exec "$1" bash 2>/dev/null || docker compose exec "$1" sh
    }
    
    # Follow logs for a specific container
    dfollow() {
        if [ -z "$1" ]; then
            echo "Usage: dfollow <container-name-or-id>"
            return 1
        fi
        docker logs -f --tail 100 "$1"
    }
    
    # Show container IP addresses
    dip() {
        if [ -z "$1" ]; then
            docker ps -q | xargs -I {} docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' {}
        else
            docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"
        fi
    }
    
    # Clean up everything (use with caution!)
    dnuke() {
        printf "This will remove ALL containers, images, volumes, and networks.\n"
        printf "Are you sure? (yes/no): "
        read -r confirm
        if [ "$confirm" = "yes" ]; then
            docker compose down -v 2>/dev/null
            docker stop $(docker ps -aq) 2>/dev/null
            docker rm $(docker ps -aq) 2>/dev/null
            docker rmi $(docker images -q) 2>/dev/null
            docker volume rm $(docker volume ls -q) 2>/dev/null
            docker network prune -f
            docker system prune -af --volumes
            echo "Docker cleanup complete!"
        else
            echo "Cancelled."
        fi
    }
    
    # Show disk usage by containers
    dsize() {
        printf "Container\t\t\tSize\n"
        printf "═════════════════════════════════════════════\n"
        docker ps -a --format '{{.Names}}' | while read container; do
            size=$(docker ps -a --filter "name=$container" --format "table {{.Size}}" | tail -n 1)
            printf "%-30s\t%s\n" "$container" "$size"
        done
    }
    
    # Restart a compose service
    dcrestart() {
        if [ -z "$1" ]; then
            echo "Usage: dcrestart <service-name>"
            return 1
        fi
        docker compose restart "$1"
        docker compose logs -f "$1"
    }
    
    # Show which containers are using a specific volume
    dvusage() {
        if [ -z "$1" ]; then
            echo "Usage: dvusage <volume-name>"
            return 1
        fi
        docker ps -a --filter volume="$1" --format '{{.Names}}'
    }
    
    # Show Docker Compose services status with detailed info
    dcstatus() {
        printf "\n=== Docker Compose Status ===\n\n"
        docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
        printf "\n=== Resource Usage ===\n\n"
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    }
    
    # Watch Docker Compose logs for specific service with grep
    dcgrep() {
        if [ -z "$1" ] || [ -z "$2" ]; then
            echo "Usage: dcgrep <service-name> <search-pattern>"
            return 1
        fi
        docker compose logs -f "$1" | grep --color=auto -i "$2"
    }
    
    # Backup a volume (useful for bind mounts)
    dbackup() {
        if [ -z "$1" ] || [ -z "$2" ]; then
            echo "Usage: dbackup <volume-name> <backup-path>"
            echo "Example: dbackup myvolume /backups/myvolume-backup.tar.gz"
            return 1
        fi
        docker run --rm -v "$1:/source" -v "$(dirname "$2"):/backup" alpine tar czf "/backup/$(basename "$2")" -C /source .
        echo "Backup created: $2"
    }
    
    # Restore a volume from backup
    drestore() {
        if [ -z "$1" ] || [ -z "$2" ]; then
            echo "Usage: drestore <backup-path> <volume-name>"
            echo "Example: drestore /backups/myvolume-backup.tar.gz myvolume"
            return 1
        fi
        docker run --rm -v "$2:/target" -v "$(dirname "$1"):/backup" alpine sh -c "cd /target && tar xzf /backup/$(basename "$1")"
        echo "Restored from backup: $1 to volume: $2"
    }
    
    # Show all bind mounts for running containers
    dbinds() {
        printf "\nContainer Bind Mounts:\n"
        printf "═══════════════════════════════════════════════════════════════\n"
        docker ps --format '{{.Names}}' | while read container; do
            printf "\n${GREEN}%s${NC}:\n" "$container"
            docker inspect "$container" | grep -A 5 '"Binds"' | grep -v "Binds" | sed 's/^[ \t]*/  /'
        done
        printf "\n"
    }
    
    # Quick container resource limits check
    dlimits() {
        if [ -z "$1" ]; then
            echo "Usage: dlimits <container-name-or-id>"
            return 1
        fi
        docker inspect "$1" | grep -A 10 "HostConfig" | grep -E "Memory|Cpu"
    }
    
    # Update and restart a single compose service
    dcupdate() {
        if [ -z "$1" ]; then
            echo "Usage: dcupdate <service-name>"
            return 1
        fi
        docker compose pull "$1"
        docker compose up -d "$1"
        docker compose logs -f "$1"
    }
    
    # Show docker compose config (useful for debugging)
    dcconfig() {
        docker compose config
    }
    
    # Validate docker compose file
    dcvalidate() {
        docker compose config --quiet && echo "✓ docker-compose.yml is valid" || echo "✗ docker-compose.yml has errors"
    }
    
    # Show environment variables for a container
    denv() {
        if [ -z "$1" ]; then
            echo "Usage: denv <container-name-or-id>"
            return 1
        fi
        docker inspect "$1" | grep -A 100 '"Env"' | grep -v "Env" | sed 's/^[ \t]*//' | grep -v '^]'
    }
fi
```

## Additional Quality-of-Life Enhancements for Docker Workflows

Add this to your aliases section for quick directory navigation to common Docker project locations:

```bash
# Docker project shortcuts (customize paths as needed)
# Uncomment and modify these based on your setup:
# alias cdapps='cd ~/docker/apps'
# alias cddata='cd ~/docker/data'
# alias cdlogs='cd ~/docker/logs'
```

## Color Variables for Functions

Add these color definitions near the top of your `.bashrc` (after the interactive check) to support colored output in the Docker functions:

```bash
# --- Color Definitions for Scripts ---
# Define colors for use in functions
if [ -x /usr/bin/tput ] && tput setaf 1 &>/dev/null; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    NC=''
fi
```

## Key Features

### Docker Compose v2 Support
All aliases use `docker compose` (not `docker-compose`) for v2 compatibility. Quick commands like `dcu` (up detached), `dcl` (follow logs), and `dcr` (restart) speed up daily operations.

### Bind Mount Management
- **`dbinds`**: Shows all bind mounts across running containers - crucial for tracking your volume mappings
- **`dbackup`** and **`drestore`**: Easy backup/restore for volumes and bind mounts
- **`dvusage`**: Check which containers use specific volumes

### Service-Specific Operations
- **`dcsh <service>`**: Jump into a service shell instantly
- **`dcrestart <service>`**: Restart and follow logs in one command
- **`dcupdate <service>`**: Pull latest image and restart specific service
- **`dcgrep <service> <pattern>`**: Real-time log filtering

### Maintenance and Cleanup
- **`dstopall`**: Stop all containers safely
- **`dprune`** and **`dprunea`**: Clean up disk space
- **`dsize`**: See which containers consume most space
- **`dnuke`**: Complete cleanup with confirmation (use carefully!)

### Monitoring
- **`dcstatus`**: Combined view of service status and resource usage
- **`dstats`**: Quick snapshot of container resources
- **`dtop`**: Formatted stats table
