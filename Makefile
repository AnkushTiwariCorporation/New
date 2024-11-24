# Makefile to control CPU and memory usage of a binary

# Variables
BINARY = ./your_binary             # Path to your binary
CPU_LIMIT = 50                     # CPU limit percentage (0-100)
MEMORY_LIMIT = 500M                # Memory limit in Megabytes (e.g., 500M)
CGROUP_NAME = limited_resources    # CGroup name

# Targets
.PHONY: run limit_cpu limit_memory setup_cgroup clean

# Run the binary with CPU and memory limits
run: setup_cgroup
	@echo "Running $(BINARY) with CPU and Memory limits..."
	@cpulimit -l $(CPU_LIMIT) -- $(BINARY) &
	@cgexec -g memory:$(CGROUP_NAME) $(BINARY)

# Limit CPU usage with cpulimit
limit_cpu:
	@echo "Limiting CPU usage of $(BINARY) to $(CPU_LIMIT)%..."
	@cpulimit -l $(CPU_LIMIT) -- $(BINARY)

# Limit memory usage using cgroups
limit_memory: setup_cgroup
	@echo "Limiting memory usage of $(BINARY) to $(MEMORY_LIMIT)..."
	@cgexec -g memory:$(CGROUP_NAME) $(BINARY)

# Setup cgroup for memory limiting
setup_cgroup:
	@echo "Setting up cgroup..."
	@sudo cgcreate -g memory:$(CGROUP_NAME)
	@sudo cgset -r memory.limit_in_bytes=$(MEMORY_LIMIT) $(CGROUP_NAME)

# Clean up the cgroup
clean:
	@echo "Cleaning up cgroup..."
	@sudo cgdelete -g memory:$(CGROUP_NAME)