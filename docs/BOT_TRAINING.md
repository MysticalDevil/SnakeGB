# Bot Training (PyTorch)

This document defines the current imitation-learning baseline for NenoSerpent bot.

## Scope

- Source policy: existing rule bot (`safe|balanced|aggressive`).
- Training target: action class (`up|right|down|left`).
- Model: small MLP classifier.
- Runtime integration: wired via `ml` backend (`NENOSERPENT_BOT_ML_MODEL=<runtime-json>`).

Prerequisite:

- Python environment with `torch` installed.

## 1. Generate Dataset

Use fixed leaderboard suite as data source:

```bash
./scripts/dev.sh bot-dataset --output /tmp/nenoserpent_bot_dataset.csv
```

Optional knobs:

- `--profile debug|dev|release`
- `--suite /abs/path/to/suite.tsv`
- `--max-samples-per-case N`

Dataset schema is emitted by `bot-benchmark --dump-dataset` and includes:

- game snapshot features (`head`, `dir`, `food_delta`, powerup flags, danger around head, etc.)
- supervised label `action` (`0=up,1=right,2=down,3=left`)

## 2. Train Imitation Model

```bash
./scripts/dev.sh bot-train \
  --dataset /tmp/nenoserpent_bot_dataset.csv \
  --model /tmp/nenoserpent_bot_policy.pt \
  --metadata /tmp/nenoserpent_bot_policy_meta.json \
  --runtime-json /tmp/nenoserpent_bot_policy_runtime.json
```

Important args:

- `--epochs` (default `30`)
- `--batch-size` (default `256`)
- `--lr` (default `1e-3`)
- `--train-ratio` (default `0.9`)
- `--runtime-json` (default `/tmp/nenoserpent_bot_policy_runtime.json`)

## 3. Evaluate

```bash
./scripts/dev.sh bot-eval \
  --dataset /tmp/nenoserpent_bot_dataset.csv \
  --model /tmp/nenoserpent_bot_policy.pt \
  --report /tmp/nenoserpent_bot_eval_report.json
```

Current eval metric:

- action classification accuracy on provided dataset

Runtime backend can load the exported JSON directly:

```bash
NENOSERPENT_BOT_ML_MODEL=/tmp/nenoserpent_bot_policy_runtime.json ./build/dev/NenoSerpent
```

## 4. Offline Tuning + Training Loop

Recommended loop:

1. Run `bot-leaderboard` baseline
2. Run `bot-tune` to get stronger rule policy JSON
3. Re-generate dataset with tuned policy as teacher (set `NENOSERPENT_BOT_STRATEGY_FILE`)
4. Re-train and re-evaluate
5. Re-check leaderboard to ensure gameplay score did not regress

## 5. Next Integration Target

Planned next step is adding a runtime policy adapter so trained model can be selected as bot backend
for A/B comparison against rule bot.
