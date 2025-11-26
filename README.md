# Dear AI Platform team 🔥
I've made some small code modifications to enable installing the llm-d stack with **no admin privileges** :))
All you have to do is use additional flag when running the standup/teardown script: 
``` --non-admin```, or its shortcut ```-i``` (there were no letters left...).

You may see logs such as ```Error from server (Forbidden):``` but don't worry about them - these will not terminate your run.
I made the smallest possible changed to avoid the script failure and didn't fix every part that may output an unpleasant log.

Here are exactly the commands you need to execute in order to deploy llm-d stack on your cluster:

*Note: most of them are literally written here below, but I added few things that will hopefully help you avoid some problems along the way*

1. Clone my repo and switch to the `non-admin-standup` branch
```
git clone https://github.com/NaomiEisen/llm-d-benchmark.git
git switch non-admin-standup
cd llm-d-benchmark
```

2. Optional but helpful: create a python virtual environment
```
python3 -m venv venv
source venv/bin/activate
```

*Note: You can always deactivate by running:*
```deactivate```

3. Set up your environment:
```
./setup/install_deps.sh
```

4. Update the ```/setup/example_env.sh```:
This file contains configuration for your run. You can edit it as you wish, 
but I suggest keeping the minimum configs I included there. Also, **do not delete this variable:**
```LLMDBENCH_VLLM_GAIE_CHART_NAME```,or at least provide another chart, as the default doesn't work (looks like the llm-d-benchmark people are aware of this).

For the first run I suggest to just update the namespace, and provide HF token (you can ask me - maybe I'll share mine 😉)

5. Run the script:
```
./setup/standup.sh -c "$(pwd)/setup/example_env.sh" --non-admin
```
That's it!

Assuming you didn't change the configs, you should have these resources in your cluster:
```
oc get all
Warning: apps.openshift.io/v1 DeploymentConfig is deprecated in v4.14+, unavailable in v4.10000+
NAME                                                      READY   STATUS              RESTARTS   AGE
pod/access-to-harness-data-workload-pvc                   1/1     ContainerCreating   0          88s
pod/download-model-9lczq                                  0/1     Completed           0          2m17s
pod/infra-llmdbench-inference-gateway-586f4b6664-xhcs6    1/1     Running             0          75s
pod/qwen-qwe-c3a61186-en3-0-6b-decode-9889dcc89-d7qlq     2/2     Running             0          45s
pod/qwen-qwe-c3a61186-en3-0-6b-gaie-epp-f5c97c6c8-k7hsc   1/1     Running             0          60s
pod/qwen-qwe-c3a61186-en3-0-6b-prefill-5f4f5f9bc4-pb7xc   1/1     Running             0          45s

NAME                                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/infra-llmdbench-inference-gateway             NodePort    172.30.255.239   <none>        80:31882/TCP                 76s
service/llm-d-benchmark-harness                       ClusterIP   172.30.109.23    <none>        20873/TCP                    89s
service/qwen-qwe-c3a61186-en3-0-6b-gaie-epp           ClusterIP   172.30.61.226    <none>        9002/TCP,9090/TCP,5557/TCP   62s
service/qwen-qwe-c3a61186-en3-0-6b-gaie-ip-5e80028e   ClusterIP   None             <none>        54321/TCP                    61s

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/infra-llmdbench-inference-gateway     1/1     1            1           76s
deployment.apps/qwen-qwe-c3a61186-en3-0-6b-decode     1/1     1            1           46s
deployment.apps/qwen-qwe-c3a61186-en3-0-6b-gaie-epp   1/1     1            1           62s
deployment.apps/qwen-qwe-c3a61186-en3-0-6b-prefill    1/1     1            1           46s

NAME                                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/infra-llmdbench-inference-gateway-586f4b6664    1         1         1       76s
replicaset.apps/qwen-qwe-c3a61186-en3-0-6b-decode-9889dcc89     1         1         1       46s
replicaset.apps/qwen-qwe-c3a61186-en3-0-6b-gaie-epp-f5c97c6c8   1         1         1       61s
replicaset.apps/qwen-qwe-c3a61186-en3-0-6b-prefill-5f4f5f9bc4   1         1         1       46s

NAME                       STATUS     COMPLETIONS   DURATION   AGE
job.batch/download-model   Complete   1/1           27s        2m19s
```

For teardown run:
```
./setup/teardown.sh -c "$(pwd)/setup/example_env.sh" --non-admin
```

## `llm-d`-benchmark

This repository provides an automated workflow for benchmarking LLM inference using the `llm-d` stack. It includes tools for deployment, experiment execution, data collection, and teardown across multiple environments and deployment styles.

### Main Goal

Provide a single source of automation for repeatable and reproducible experiments and performance evaluation on `llm-d`.

### 📦 Repository Setup

```
git clone https://github.com/llm-d/llm-d-benchmark.git
cd llm-d-benchmark
./setup/install_deps.sh
```

## Quickstart

**Out of the box:** **`standup`** a `llm-d` stack (default method is `llm-d-modelservice`, serving `meta-llama/Llama-3.2-1B-Instruct` model), **`run`** a harness (default `inference-perf`) with a load profile (default `sanity_random`) and then **`teardown`** the deployed stack.

```
./e2e.sh
```

> [!TIP]
> The penultimate line on the output, starting with "ℹ️   The current work dir is" will indicate the current path for the generated standup files and collected performance data.

The same above example could be explicitly split in three separate parts.

```
./setup/standup.sh
./run.sh
./setup/teardown.sh
```

A user can elect to  **`standup`** an `llm-d` stack once, and then **`run`** the `inference-perf` harness with a different load profile (i.e., `chatbot_synthetic`)

```
./run.sh --harness inference-perf --workload chatbot_synthetic --methods <a string that matches a inference service or pod>`
```

> [!TIP]
> `./run.sh` can be used to run a particular workload against an already stood up stack (`llm-d` or otherwise)

An illustrative example on is present [here](docs/tutorials/run/run_against_existing_example.md)

> [!TIP]
> `./run.sh` can also be used in "interactive" (or "debug") mode (option `-d` or `--debug`)

An illustrative example on is present [here](docs/tutorials/run/run_interactively_example.md)

### News

-  KubeCon/NativeCloudCon 2025 North America Talk "A Cross-Industry Benchmarking Tutorial for Distributed LLMInference on Kubernetes", with the [accompanying tutorial](docs/tutorials/kubecon/README.md)

- Data from benchmarking experiments is made available on the [main project's Google drive](https://drive.google.com/drive/folders/1sqnibn_mFlciV3-qZIFgZYmk-p9zemzH)

- `llm-d-benchmark` supports all available [Well-Lit Path Guides](https://github.com/llm-d/llm-d/blob/main/guides/README.md)
```
scenarios/guides/pd-disaggregation.sh
scenarios/guides/inference-scheduling.sh
scenarios/guides/tiered-prefix-cache.sh
scenarios/guides/simulated-accelerators.sh
scenarios/guides/wide-ep-lws.sh
scenarios/guides/precise-prefix-cache-aware.sh
```

> [!WARNING]
> `scenarios/guides/wide-ep-lws.sh` is still a work in progress, not fully functional

### Architecture

`llm-d-benchmark` stands up a stack (currently, both `llm-d` and "standalone" are supported) with a specific set of [Standup Parameters](docs/standup.md), and the run a specific harness with a specific set of [Run Parameters](docs/run.md). Results are saved in the native format of the [harness](docs/run.md#harnesses) chosen, as well as a universal [Benchmark Report](docs/benchmark_report.md).

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)">
    <img alt="llm-d Logo" src="./docs/images/architecture.drawio.png" width=100%>
  </picture>
</p>

### Goals

#### [Reproducibility](docs/reproducibility.md)

Each benchmark run collects enough information to enable the execution on different clusters/environments with minimal setup effort.

#### [Flexibility](docs/flexibility.md)

Multiple load generators and multiple load profiles available, in a plugable architecture that allows expansion.

#### Well defined set of [Metrics](docs/run.md#metrics)

Define and measure a representative set of metrics that allows not only meaningful comparisons between different stacks, but also performance characterization for different components.

#### Relevant collection of [Workloads](docs/run.md#workloads)

Define a mix of workloads that express real-world use cases, allowing for `llm-d` performance characterization, evaluation, stress investigation.

### Design and Roadmap

`llm-d-benchmark` follows the practice of its parent project (`llm-d`) by having also it is own [Northstar design](https://docs.google.com/document/d/1DtSEMRu3ann5M43TVB3vENPRoRkqBr_UiuwFnzit8mw/edit?tab=t.0#heading=h.9a3894cbydjw) (a work in progress)

### Main concepts (identified by specific directories)

#### [Scenarios](docs/standup.md#scenarios)

Pieces of information identifying a particular cluster. This information includes, but it is not limited to, GPU model, large language model, and `llm-d` parameters (an environment file, and optionally a `values.yaml` file for modelservice helm charts).

#### [Harnesses](docs/run.md#harnesses)

A "harness" is a load generator (Python code) which drives the benchmark load. Today, llm-d-benchmark supports [inference-perf](https://github.com/kubernetes-sigs/inference-perf), [guidellm](https://github.com/vllm-project/guidellm.git), the benchmarks found on the `benchmarks` folder on [vllm](https://github.com/vllm-project/vllm.git), [inferencemax](https://github.com/InferenceMAX/InferenceMAX.git) and "no op" (internally designed "nop") for users interested in benchmarking mostly model load times. There are ongoing efforts to consolidate and provide an easier way to support different load generators.

#### (Workload) [Profiles](docs/run.md#profiles)

A (workload) profile is the actual benchmark load specification which includes the LLM use case to benchmark, traffic pattern, input / output distribution, and dataset. Supported workload profiles can be found under [`workload/profiles`](./workload/profiles).

> [!IMPORTANT]
> The triplet `<scenario>`,`<harness>`,`<(workload) profile>`, combined with the standup/teardown capabilities provided by [llm-d-infra](https://github.com/llm-d-incubation/llm-d-infra.git) and [llm-d-modelservice](https://github.com/llm-d/llm-d-model-service.git) should provide enough information to allow a single experiment to be reproduced.

#### [Experiments](docs/doe.md)
A file describing a series of parameters - both `standup` and `run` - to be executed automatically. This file follows the "Design of Experiments" (DOE) approach, where each parameter (`factor`) is listed alongside with the target values (`levels`) resulting into a list of combinations (`treatments`).

#### [Configuration Exploration](config_explorer/README.md)
The configuration explorer is a library that helps find the most cost-effective, optimal configuration for serving models on llm-d based on hardware specification, workload characteristics, and SLO requirements. A "Capacity Planner" is provided as an initial component to help determine if vLLM configuration is feasible for deployment.

### Dependencies

- [llm-d-infra](https://github.com/llm-d-incubation/llm-d-infra.git)
- [llm-d-modelservice](https://github.com/llm-d/llm-d-model-service.git)
- [inference-perf](https://github.com/kubernetes-sigs/inference-perf)
- [guidellm](https://github.com/vllm-project/guidellm.git)
- [vllm](https://github.com/vllm-project/vllm.git)
- [inferencemax](https://github.com/InferenceMAX/InferenceMAX.git)

## Topics

#### [Reproducibility](docs/reproducibility.md)
#### [Observability](docs/observability.md)
#### [Quickstart](docs/quickstart.md)
#### [Resource Requirements](docs/resource_requirements.md)
#### [FAQ](docs/faq.md)

## Contribute

- [Instructions on how to contribute](CONTRIBUTING.md) including details on our development process and governance.
- We use Slack to discuss development across organizations. Please join: [Slack](https://llm-d.ai/slack). There is a `sig-benchmarking` channel there.
- We host a bi-weekly standup for contributors on Tuesdays at 13:00 EST. Please join: [Meeting Details](https://calendar.google.com/calendar/u/0?cid=NzA4ZWNlZDY0NDBjYjBkYzA3NjdlZTNhZTk2NWQ2ZTc1Y2U5NTZlMzA5MzhmYTAyZmQ3ZmU1MDJjMDBhNTRiNEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t). The meeting notes can be found [here](https://docs.google.com/document/d/1njjeyBJF6o69FlyadVbuXHxQRBGDLcIuT7JHJU3T_og/edit?usp=sharing). Joining the [llm-d google groups](https://groups.google.com/g/llm-d-contributors) will grant you access.

## License

This project is licensed under Apache License 2.0. See the [LICENSE file](LICENSE) for details.
