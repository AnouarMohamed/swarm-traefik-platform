# Those commands will remove unused containers also remove networks and images without at least one container associated to them.
# using -f insted of -y https://github.com/moby/moby/issues/34037
echo \| "$(date) : cleaning in progress..."
echo ------------------------------
echo \| docker system prune
docker system prune -f
echo ------------------------------
echo \| removing unused images
docker image prune -a --filter "until=72h" -f
echo ------------------------------
echo \| "$(date) : cleaning completed"