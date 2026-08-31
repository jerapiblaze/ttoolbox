#!/usr/bin/bash
#!/usr/bin/zsh
#!/usr/bin/sh

# Script to get GPU usage information from all vendors (Intel, AMD, NVIDIA)

# Check if there is intel/amd/nvidia GPU and set the appropriate monitoring command
VGA_LIST=$(lspci | grep -E "VGA|3D")
INTEL_AVAILABLE=$(echo "$VGA_LIST" | grep -i "Intel")
AMD_AVAILABLE=$(echo "$VGA_LIST" | grep -i "AMD")
NVIDIA_AVAILABLE=$(echo "$VGA_LIST" | grep -i "NVIDIA")
INTEL_GPU_TOP_AVAILABLE=$(command -v intel_gpu_top)
AMDGPU_TOP_AVAILABLE=$(command -v amdgpu_top)
NVIDIA_SMI_AVAILABLE=$(command -v nvidia-smi)

function run_once {
    if [ -n "$INTEL_AVAILABLE" ] && [ -n "$INTEL_GPU_TOP_AVAILABLE" ]; then
        sudo intel_gpu_top -n 1
    elif [ -n "$AMD_AVAILABLE" ] && [ -n "$AMDGPU_TOP_AVAILABLE" ]; then
        sudo amdgpu_top -J -l 1
    elif [ -n "$NVIDIA_AVAILABLE" ] && [ -n "$NVIDIA_SMI_AVAILABLE" ]; then
        nvidia-smi
    else
        echo "No supported GPU monitoring tool available"
    fi
}

# Parameter -n specifies the number of iterations for the GPU monitoring tools. Default is 1.
NumIterations=1
# Get parameter from args
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n)
            NumIterations="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

for ((i=0; i<NumIterations; i++)); do
    run_once
done