# Multi-Cloud NPB Testbench

This repository contains a multi-cloud testbench for running the NAS Parallel Benchmarks (NPB) Conjugate Gradient (CG) workload on small MPI clusters deployed to AWS, Azure, and GCP. The project automates provisioning, configuration, benchmark execution, and metric collection so different cloud environments can be exercised in a consistent way.

Although it was developed for an academic performance study, this repo is structured as a reusable example of how to stand up and automate comparable clusters across the three major cloud providers.



## Features

- **Multi-cloud infrastructure automation**
  - Separate Terraform configurations and Python drivers for AWS, Azure, and GCP (`aws/`, `azure/`, `gcp/`) to provision equivalent NPB test clusters.
  - Python setup scripts (`awsSetup.py`, `azureSetup.py`, `gcpSetup.py`) call Terraform, parse outputs, and generate a shared `hosts` file used by MPI and Ansible.

- **Cluster configuration with Ansible**
  - Central Ansible playbook (`ansible/playbook.yaml`) that waits for new instances to come online, installs required packages, and copies over benchmark and logging scripts to the nodes.

- **Logging and monitoring**
  - Node-local logging scripts in `logging/` sample CPU, memory, and disk statistics while jobs run, writing per-node CSV logs and summary files.
  - A `collect.sh` helper pulls summaries back from all nodes and computes both per-node and cluster-wide averages for the monitored metrics.

- **Benchmark harness for NAS CG**
  - `tests/baseTest.sh` runs a lightweight `mpirun` job (sleep) with logging enabled to establish baseline utilization and I/O overhead for the cluster.
  - `tests/cgTest.sh` launches the NPB CG benchmark for a specified suite (A, B, C, etc.) across the cluster while monitoring scripts run on each node.
  - `tests/testScript.sh` orchestrates a full campaign of CG runs (multiple repetitions for suites A, B, and C), appending test metadata and log output into `results.txt` for later analysis.

> Note: This repository focuses on automation and test harness design. Any specific performance numbers or analysis results are intentionally omitted from this README.



## Repository Layout

```text
.
├── ansible
│   ├── inventory.ini        # Ansible inventory template/grouping
│   ├── keys/                # SSH keypair used to reach provisioned nodes
│   └── playbook.yaml        # Node configuration and file distribution
├── aws
│   ├── awsSetup.py          # Terraform + Ansible driver for AWS
│   ├── main.tf              # AWS infrastructure definition
│   ├── outputs.tf
│   ├── terraform.tf
│   └── variables.tf
├── azure
│   ├── azureSetup.py        # Terraform + Ansible driver for Azure
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfstate.backup
│   └── variables.tf
├── gcp
│   ├── gcpSetup.py          # Terraform + Ansible driver for GCP
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── variables.tf
├── logging
│   ├── baseline.sh          # Baseline resource sampling script
│   ├── collect.sh           # Fetch & aggregate metrics from all nodes
│   └── monitor_node.sh      # Per-node monitoring during CG runs
└── tests
    ├── baseTest.sh          # Baseline MPI test with logging
    ├── cgTest.sh            # Single CG run for a specified suite
    └── testScript.sh        # Batch runner for multiple CG suites
```



## Typical Workflow

1. **Choose a cloud provider**

   Change into one of the provider directories:

   ```bash
   cd aws        # or azure, gcp
   ```

   Configure the corresponding `variables.tf` with your project-specific values (region, instance types, key names, etc.).

2. **Provision the cluster and configure nodes**

   Use the provider-specific setup script to run Terraform and Ansible end-to-end:

   ```bash
   python3 awsSetup.py    # or azureSetup.py, gcpSetup.py
   ```

   The script will:
   - Initialize and apply the Terraform configuration.
   - Read the Terraform outputs (e.g., node IPs).
   - Generate a `../hosts` file listing the cluster nodes in MPI hostfile format.
   - Invoke Ansible to install dependencies and copy tests/logging scripts to the instances.

3. **Run baseline and benchmark tests**

   From the `tests/` directory on the control machine:

   ```bash
   cd tests

   # Baseline cluster utilization (no CG workload)
   ./baseTest.sh

   # Single CG run for a given suite (e.g., A, B, C)
   ./cgTest.sh A

   # Full scripted campaign across several suites
   ./testScript.sh
   ```

   The tests trigger per-node monitoring scripts and gather metrics into log files and `results.txt`.

4. **Inspect logs and summaries**

   - Per-node metrics and summaries are stored under the logging output directories on each node.
   - `logging/collect.sh` aggregates these into centralized summaries and calculates cluster-wide averages for key metrics.



## Educational Focus

This project was also used as a learning vehicle for cloud automation. Building the testbench involved:

- Designing equivalent Terraform stacks for AWS, Azure, and GCP.
- Using Python scripting to orchestrate Terraform and Ansible, glue together different tooling layers, and drive repeatable workflows from a single entry point.
- Automating the full path from raw cloud accounts to configured MPI clusters with reproducible benchmarks and monitoring.

Together, the Terraform modules, Ansible playbooks, and Python orchestration scripts provide a concrete, multi-cloud example of infrastructure-as-code plus lightweight automation that can be adapted for other distributed or HPC workloads.

## Credits
[sonofoven](https://github.com/sonofoven) - Ansible & Terraform infrastructure automation.  
[dbstreif](https://github.com/dbstreif) - Data acquisition & logging.  
dwatanabe - Data analysis & write up.
