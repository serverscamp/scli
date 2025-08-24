# scli

`scli` is a lightweight command‑line client for the **ServersCamp API**. It’s designed for humans (nice tables) and for automation (stable JSON/CSV/TSV, exit codes, and a quiet mode).

It is a console utility for managing virtual servers at [ServersCamp](https://serverscamp.com).

---

## Requirements

Install script and most examples assume you have:

- `sh`, `curl`
- `grep`, `awk` (optional, used in examples)
- `sudo` (optional, for installing into system folders like `/usr/local/bin`)

> macOS and most Linux distributions already include these.

---

## Installation

### One‑line install (recommended)

```sh
curl -fsSL https://raw.githubusercontent.com/serverscamp/scli/main/install.sh | sh
```

- The script detects your OS/arch, downloads the latest release, verifies checksum if available, and installs `scli` to a suitable location (`$HOME/.local/bin` when possible or `/usr/local/bin` with `sudo`).
- To avoid password prompts on macOS, prefer the no‑sudo path:  
  `export SCLI_DEST="$HOME/.local/bin"` before running the installer and ensure this dir is in your `PATH`.

### Manual install

1) Download a binary for your platform from **Releases**.  
2) Make it executable and place it in `PATH`:

```sh
chmod +x ./scli
mkdir -p "$HOME/.local/bin"
mv ./scli "$HOME/.local/bin/"
# ensure PATH contains ~/.local/bin
```

3) Check:

```sh
scli version
```

---

## Configuration

`scli` needs an **API key**. You can provide it in three ways:

- **Environment variable** (best for CI):
  ```sh
  export SCAMP_API_KEY="your_api_key_here"
  ```
- **Inline flag**:
  ```sh
  scli flavors --api-key "your_api_key_here"
  ```
- **Local config file** (`~/.scli/config`):
  ```sh
  # quick non-interactive
  scli config init --api-key "your_api_key_here"

  # or interactive
  scli config configure
  ```
  The config file stores your API key only (the API URL is hard‑coded inside the binary).

---

## Commands overview

```text
scli version
scli config init --api-key <KEY>
scli config configure
scli flavors [--page N] [--per-page N] [--sort CSV] [--order asc|desc]
             [--fields CSV] [--columns CSV]
             [--format table|csv|tsv|json|jsonl] [--no-header] [--no-color]
             [--silent] [--api-key KEY]
```

- `--fields` controls which fields the API is asked to return.
- `--columns` controls which columns you print locally (subset of the fields).
- `--format` switches the printer: a **pretty table** by default, or machine‑friendly outputs.

---

## Real‑world examples

> The samples below mimic the actual output you see in a typical terminal.  
> Prices are **EUR per month**; units for RAM/DISK are **GB** and CPU is **vcores**.

### 1) List available flavors (pretty table)

```sh
scli flavors
```

```
ID  NAME        VCORES  RAM (GB)  DISK (GB)  PRICE (EUR/per_month)
──  ──────────  ──────  ────────  ─────────  ──────────────────────
1   sc-micro    1       4         35         5
2   sc-mini     2       8         70         10
3   sc-medium   4       16        140        20
4   sc-large    6       32        280        40
5   sc-pro      8       64        540        80
6   sc-max      12      128       1080       160
7   sc-ultra    16      256       2160       320
```

Tips:
- The `sc` prefix in the *NAME* may be colorized green when colors are enabled.

### 2) Sort by price descending

```sh
scli flavors --sort price --order desc
```

```
ID  NAME       VCORES  RAM (GB)  DISK (GB)  PRICE (EUR/per_month)
──  ─────────  ──────  ────────  ─────────  ──────────────────────
7   sc-ultra   16      256       2160       320
6   sc-max     12      128       1080       160
5   sc-pro     8       64        540        80
4   sc-large   6       32        280        40
3   sc-medium  4       16        140        20
2   sc-mini    2       8         70         10
1   sc-micro   1       4         35         5
```

### 3) Ask fewer fields from API (bandwidth‑friendly)

```sh
scli flavors --fields id,name,price
```

```
ID  NAME        PRICE (EUR/per_month)
──  ──────────  ─────────────────────
1   sc-micro    5
2   sc-mini     10
3   sc-medium   20
…
```

### 4) Print only specific columns locally

```sh
scli flavors --columns name,price
```

```
NAME        PRICE (EUR/per_month)
──────────  ─────────────────────
sc-micro    5
sc-mini     10
sc-medium   20
…
```

### 5) Machine‑readable formats

CSV:

```sh
scli flavors --format csv --no-header
```

```
1,sc-micro,1,4,35,5
2,sc-mini,2,8,70,10
…
```

TSV:

```sh
scli flavors --format tsv --no-header
```

```
1	sc-micro	1	4	35	5
2	sc-mini	2	8	70	10
…
```

JSON (pretty):

```sh
scli flavors --format json
```

```json
{
  "data": {
    "date": "2025-08-23T10:02:07Z",
    "request_id": "f8738107ca15ac42",
    "from_cache": false,
    "price_unit": "per_month",
    "currency": "EUR",
    "currency_unit": "EUR",
    "cpu_unit": "vcores",
    "ram_unit": "GB",
    "disk_unit": "GB",
    "count": 7,
    "total": 7,
    "page": 1,
    "per_page": 100,
    "flavors": [
      { "id": 1, "name": "sc-micro",  "vcores": 1,  "ram": 4,   "disk": 35,   "price": 5 },
      { "id": 2, "name": "sc-mini",   "vcores": 2,  "ram": 8,   "disk": 70,   "price": 10 },
      { "id": 3, "name": "sc-medium", "vcores": 4,  "ram": 16,  "disk": 140,  "price": 20 },
      { "id": 4, "name": "sc-large",  "vcores": 6,  "ram": 32,  "disk": 280,  "price": 40 },
      { "id": 5, "name": "sc-pro",    "vcores": 8,  "ram": 64,  "disk": 540,  "price": 80 },
      { "id": 6, "name": "sc-max",    "vcores": 12, "ram": 128, "disk": 1080, "price": 160 },
      { "id": 7, "name": "sc-ultra",  "vcores": 16, "ram": 256, "disk": 2160, "price": 320 }
    ]
  },
  "ok": true
}
```

JSON Lines (one flavor per line):

```sh
scli flavors --format jsonl --no-header
```

```
{"id":1,"name":"sc-micro","vcores":1,"ram":4,"disk":35,"price":5}
{"id":2,"name":"sc-mini","vcores":2,"ram":8,"disk":70,"price":10}
…
```

### 6) Quiet mode for scripts

```sh
# prints only the table (no extra info lines); works for all formats
scli flavors --silent
```

### 7) Using environment variable

```sh
export SCAMP_API_KEY="your_api_key_here"
scli flavors --format csv --no-header | grep sc-mini
```

### 8) Extract just the cheapest flavor id (portable tools)

```sh
scli flavors --format tsv --no-header \
  | awk -F '\t' 'NR==1{min=$6; id=$1} NR>1 && $6<min{min=$6; id=$1} END{print id}'
```

---

## Limits

Query your account limits with usage and remaining counters. Color rules in the table:
- **Green** `USED` when `used &lt; remaining`
- **Yellow** `USED` when `used ≥ remaining` and `used &lt; limit`
- **Red** `USED` when `used == limit`

**Usage**

```sh
scli limits [--page N] [--per-page N] [--sort CSV] [--order asc|desc]
            [--fields CSV] [--columns CSV]
            [--format table|csv|tsv|json|jsonl] [--no-header] [--no-color]
            [--silent] [--api-key KEY]
scli limits search &lt;query&gt; [same flags as above]
```

**Examples**

```sh
scli limits
```

```
ID  TYPE       LIMIT  USED  REMAINING
──  ─────────  ─────  ────  ─────────
67  instances      5      1        4
68  ssh_keys       5      5        0
```

Sort by type descending, print JSONL without header:

```sh
scli limits --sort type --order desc --format jsonl --no-header --silent
```

Request fewer fields and print selected columns:

```sh
scli limits --fields id,type,limit,used --columns type,used
```

Search by substring (matches any column):

```sh
scli limits search ssh
```

---

## SSH keys

Manage public SSH keys used for instances. The table shows:
- **PROTECTED** — `Yes` (green) / `No`
- **DOWNLOAD AVAILABLE** — `Yes` (green) if the private key is stored and can be downloaded; `No (imported)` otherwise
- **SERVERS** — how many instances currently use the key
- **CREATED** — `dd/mm/yy HH:MM` (24‑hour)

> Safety rules enforced by API/CLI:
> - A key **in use by any server** cannot be unprotected or deleted.
> - A **protected** key cannot be deleted.
> - When creating/importing, if your **ssh_keys** limit is reached, you’ll get a clear error with a link to raise limits: https://my.serverscamp.com/limits/

**Usage**

```text
scli ssh-keys list [--page N] [--per-page N] [--sort CSV] [--order asc|desc]
                   [--fields CSV] [--columns CSV]
                   [--format table|csv|tsv|json|jsonl] [--no-header] [--no-color]
                   [--silent] [--api-key KEY]
scli ssh-keys search &lt;query&gt; [same flags as above]

scli ssh-keys import   --name NAME [--key 'ssh-rsa AAA...'] [--file PATH]
scli ssh-keys generate --name NAME [--wait] [--interval SECONDS]

scli ssh-keys protect   --id ID
scli ssh-keys unprotect --id ID        # fails if key is used by any server
scli ssh-keys delete    --id ID[,ID...] # fails if protected or used
scli ssh-keys download  --id ID [--out PATH]
```

**List**

```sh
scli ssh-keys list
```

```
ID  NAME         FINGERPRINT                                                                PROTECTED  DOWNLOAD AVAILABLE  SERVERS  CREATED
──  ───────────  ─────────────────────────────────────────────────────────────────────────  ─────────  ──────────────────  ───────  ──────────────
12  kyka         2048 MD5:b1:b1:f6:72:ea:09:9f:16:a4:f4:ad:b8:b4:10:7b:4d no comment (RSA)  No         No (imported)       0        24/03/25 04:16
37  kyka key 2   2048 MD5:27:a2:82:f1:37:48:64:9c:72:0a:73:7c:08:e3:ba:9e no comment (RSA)  No         Yes                 1        23/08/25 14:40
38  kyka key 3   3072 MD5:02:a9:ea:b8:15:4e:24:e3:91:b5:91:22:ac:34:98:b4 kukara4... (RSA)  No         No (imported)       0        23/08/25 14:42
```

**Import**

```sh
# from a file
scli ssh-keys import --name "ed25519-ci" --file ~/.ssh/id_ed25519.pub

# from a literal public key
scli ssh-keys import --name "laptop" --key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI.... user@host"
```

Output:

```
SSH key "ed25519-ci" imported successfully. ID: 42
```

**Generate**

```sh
# enqueue background generation (just show job id)
scli ssh-keys generate --name "ci-generated"

# wait and show progress with spinner, then print the created key
scli ssh-keys generate --name "ci-generated" --wait --interval 2
```

Example (with `--wait`):

```
ACTION    NAME         JOB ID                                STATUS URL                                   MESSAGE
────────  ───────────  ────────────────────────────────────  ───────────────────────────────────────────  ───────────────────────────────
GENERATE  ci-generated  16384511-37ca-4cf9-a539-1af4cda3f5f8  /tasks/16384511-37ca-4cf9-a539-1af4cda3f5f8  SSH key generation job enqueued

Tracking task status... (Ctrl+C to stop)

⠋  40%  running
⠙  60%  running
⠹  100% finished

ID  NAME           FINGERPRINT                                                                PROTECTED  DOWNLOAD AVAILABLE  SERVERS  CREATED
──  ─────────────  ─────────────────────────────────────────────────────────────────────────  ─────────  ──────────────────  ───────  ──────────────
63  ci-generated   2048 MD5:32:c2:29:01:8b:65:96:18:d2:07:b3:27:63:4f:9f:62 no comment (RSA)  No         Yes                 0        23/08/25 18:43

SSH key created successfully.
```

**Delete multiple ids**

```sh
scli ssh-keys delete --id 61,62,63
```

**Download private key (if available)**

```sh
scli ssh-keys download --id 63 --out ./ci-generated.key
chmod 600 ./ci-generated.key
```

---

## Images

List available OS images. Fields: `id`, `name`, `version`, `short_name`, `distro_family`.

**Usage**

```sh
scli images list [--page N] [--per-page N] [--sort CSV] [--order asc|desc]
                 [--fields CSV] [--columns CSV]
                 [--format table|csv|tsv|json|jsonl] [--no-header] [--no-color]
                 [--silent] [--api-key KEY]
scli images search &lt;query&gt; [same flags as above]
```

**Examples**

```sh
scli images list
```

```
ID  NAME           VERSION      SHORT_NAME   DISTRO_FAMILY
──  ─────────────  ───────────  ───────────  ─────────────
5   Alpine         3.22         alpine3      alpine
3   CentOS Stream  10           centos10     centos
2   Debian         12           debian12     debian
4   Fedora         41           fedora41     fedora
6   FreeBSD        14.2         freebsd14    freebsd
1   Ubuntu LTS     24.04        ubuntu24     ubuntu
7   Windows        server 2025  windows2025  windows
```

Search by substring:

```sh
scli images search ubuntu
```

Output respects `--fields`, `--columns`, and all `--format` options.

---

## CI usage

Minimal example (GitHub Actions):

```yaml
- name: Install scli
  run: curl -fsSL https://raw.githubusercontent.com/serverscamp/scli/main/install.sh | sh

- name: List flavors (JSON)
  env:
    SCAMP_API_KEY: ${{ secrets.SCAMP_API_KEY }}
  run: scli flavors --format json --silent > flavors.json
```

GitLab CI:

```yaml
script:
  - curl -fsSL https://raw.githubusercontent.com/serverscamp/scli/main/install.sh | sh
  - scli version
  - scli flavors --format csv --no-header --silent | tee flavors.csv
```

---

## Troubleshooting

- **Permission denied during install**: set a user destination `export SCLI_DEST="$HOME/.local/bin"` (ensure it’s in `PATH`).
- **No colors** in tables inside CI: many CI systems don’t allocate TTY; use `--no-color`.
- **Bandwidth** sensitive? Use `--fields` to request only needed keys.

---

Happy scripting!
