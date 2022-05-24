


1) If you specify neither EXPOSE nor -p, the service in the container will only be accessible from inside the container itself.

2) If you EXPOSE a port, the service in the container is not accessible from outside Docker, but from inside other Docker containers. So this is good for inter-container communication.

3) If you EXPOSE and -p a port, the service in the container is accessible from anywhere, even outside Docker.