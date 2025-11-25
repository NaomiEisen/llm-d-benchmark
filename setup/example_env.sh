# Replace with your namespace
export LLMDBENCH_VLLM_COMMON_NAMESPACE="<namespace-name>"
export LLMDBENCH_HARNESS_NAMESPACE="<namespace-name>"

# HuggingFace token (or leave blank and use a secret in the cluster)
export LLMDBENCH_HF_TOKEN="<replace-with-token>"

export LLMDBENCH_VLLM_GAIE_CHART_NAME="oci://us-central1-docker.pkg.dev/k8s-staging-images/gateway-api-inference-extension/charts/inferencepool"